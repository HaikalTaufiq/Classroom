import 'dart:io';

import 'package:classroom/main.dart';
import 'package:classroom/pages/admin/register.dart';
import 'package:classroom/pages/data/task-data.dart';
import 'package:classroom/pages/home.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:classroom/pages/profile.dart';
import 'package:classroom/pages/task/addtask.dart';
import 'package:classroom/pages/task/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MK13 extends StatefulWidget {
  const MK13({super.key});

  @override
  State<MK13> createState() => _TaskPageState();
}

class _TaskPageState extends State<MK13> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> _isExpandedList = [];
  String? userRole;
  String? fileName;
  String? userName;
  String? filePath;
  DateTime? uploadTime;
  String? selectedTaskTitle;

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Ambil role pengguna saat halaman dimuat
    _getUserData();
  }

  void saveChanges() async {
    // Pastikan kita memiliki userName sebelum mengupload file
    if (userName == null) {
      await _getUserData(); // Ambil data pengguna jika belum ada
    }

    User? user = FirebaseAuth.instance.currentUser; // Ambil user saat ini
    String? userId = user?.uid; // Dapatkan userId

    if (fileName != null &&
        filePath != null &&
        userName != null &&
        userId != null &&
        selectedTaskTitle != null) {
      // Pastikan title dari task yang dipilih tersedia
      // Dapatkan referensi ke Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();

      // Buat referensi untuk file yang akan diupload
      final fileRef = storageRef.child('uploads/$fileName');

      // Upload file
      try {
        // Menggunakan path file yang dipilih
        await fileRef.putFile(File(filePath!));

        // Ambil URL download dari file yang diupload
        String downloadURL = await fileRef.getDownloadURL();

        // Simpan data ke Firestore setelah upload berhasil
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('uploads').add({
          'userId': userId, // Tambahkan userId
          'userName': userName,
          'fileName': fileName,
          'uploadTime': Timestamp.now(),
          'title': selectedTaskTitle, // Gunakan title dari task yang dipilih
          'fileURL': downloadURL, // Simpan URL file
          'filePath': 'uploads/$fileName', // Simpan filePath
        });

        // Ambil data uploadTime dari Firestore
        DocumentSnapshot docSnapshot = await docRef.get();
        uploadTime = (docSnapshot['uploadTime'] as Timestamp)
            .toDate(); // Ambil waktu upload

        // Tampilkan snackbar atau notifikasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('File berhasil diunggah untuk task $selectedTaskTitle!'),
          ),
        );

        // Reset state
        setState(() {
          fileName =
              null; // Atau tidak mereset jika ingin tetap menampilkan nama file
          filePath = null; // Reset path file
        });
      } catch (e) {
        // Tangani kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengupload file: $e')),
        );
      }
    } else {
      // Jika file belum dipilih atau userName tidak tersedia
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Silakan pilih file dan pastikan task dan user terdaftar!'),
        ),
      );
    }
  }

  Future<void> _getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          // Memastikan dokumen ada sebelum mengambil data
          setState(() {
            userName = userDoc['name']; // Ambil nama pengguna
            userRole = userDoc['role']; // Ambil role
          });
        } else {
          print('User document does not exist.');
        }
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _getUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        setState(() {
          userRole = userDoc['role']; // Asumsikan 'role' disimpan di field ini
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Logout dari Firebase
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => HomeScreen()), // Ganti ke HomePage
        (Route<dynamic> route) => false, // Menghapus semua route sebelumnya
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void pickFile() async {
    // Menggunakan file picker untuk memilih file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType
          .any, // Anda dapat mengganti ini sesuai dengan tipe file yang diinginkan
      allowMultiple: false, // Mengizinkan pemilihan beberapa file
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        fileName = result.files.single.name; // Mengambil nama file
        filePath = result.files.single.path; // Mengambil path file
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File terpilih: $fileName')),
      );
    } else {
      // Jika tidak ada file yang dipilih
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada file yang dipilih')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // Set height of the AppBar
        child: AppBar(
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Biology - MK13',
                style: TextStyle(
                    fontFamily: "poppins",
                    fontSize: 24,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
                top: 0, // Adjust top padding as needed
              ),
              child: IconButton(
                icon: Icon(
                  Icons.person, // Use the desired profile icon
                  size: 30, // Adjust size as needed
                  color: Colors.black, // Change color if needed
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ProfilePage()), // Ganti TaskPage() dengan nama halaman yang ingin Anda tuju
                  ).then((_) {
                    Navigator.pop(context); // Menutup drawer setelah navigasi
                  });
                },
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 100, // Atur tinggi sesuai kebutuhan
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 143, 205, 255),
                ),
                child: Text(
                  'Classroom',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Home Page',
                style: TextStyle(
                  fontFamily: 'poppins',
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
              },
            ),
            if (userRole == 'Teacher' || userRole == 'Admin') Divider(),
            if (userRole == 'Teacher' || userRole == 'Admin')
              ListTile(
                title: Text(
                  'Add Task',
                  style: TextStyle(
                    fontFamily: 'poppins',
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HomePage()), // Ganti TaskPage() dengan nama halaman yang ingin Anda tuju
                  ).then((_) {
                    Navigator.pop(context); // Menutup drawer setelah navigasi
                  });
                },
              ),
            if (userRole == 'Teacher' || userRole == 'Admin') Divider(),
            if (userRole == 'Teacher' || userRole == 'Admin')
              ListTile(
                title: Text(
                  'Uploaded Task',
                  style: TextStyle(
                    fontFamily: 'poppins',
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TaskData()), // Ganti TaskPage() dengan nama halaman yang ingin Anda tuju
                  ).then((_) {
                    Navigator.pop(context); // Menutup drawer setelah navigasi
                  });
                },
              ),
            if (userRole == 'Student') Divider(),
            if (userRole == 'Student')
              ListTile(
                title: Text(
                  'Course',
                  style: TextStyle(
                    fontFamily: 'poppins',
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Course()),
                  ); // Menutup drawer
                },
              ),
            Divider(),
            ListTile(
              title: Text(
                'Log out',
                style: TextStyle(
                  fontFamily: 'poppins',
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Menutup drawer
                _logout(); // Memanggil fungsi logout
              },
            ),
            Divider(),
            // Tampilkan opsi Register hanya jika userRole adalah 'admin'
            if (userRole == 'Admin')
              ListTile(
                title: Text(
                  'Register',
                  style: TextStyle(
                    fontFamily: 'poppins',
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            RegisterPage()), // Arahkan ke halaman registrasi
                  ).then((_) {
                    Navigator.pop(context); // Menutup drawer setelah navigasi
                  });
                },
              ),
            if (userRole == 'Admin') Divider(),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('courseCode', isEqualTo: 'Biology-MK13')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching tasks: ${snapshot.error}'));
          }

          final tasks = snapshot.data!.docs;

          // Inisialisasi status ekspansi
          if (_isExpandedList.length != tasks.length) {
            _isExpandedList = List.filled(tasks.length, false);
          }

          return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('uploads')
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, uploadSnapshot) {
                if (uploadSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (uploadSnapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error fetching uploads: ${uploadSnapshot.error}'));
                }

                // Ambil semua upload dari pengguna saat ini
                final uploads = uploadSnapshot.data!.docs;
                final uploadedTitles =
                    uploads.map((doc) => doc['title'] as String).toSet();
                return ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index].data() as Map<String, dynamic>;
                    final taskId = tasks[index].id; // Dapatkan ID dokumen
                    final String? url = task['url'];
                    String title = task['title'] ??
                        'No Title'; // Ambil title dari data task

                    final hasUploaded = uploadedTitles.contains(title);

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Color(0xffE8E9E7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(15),
                      height: _isExpandedList[index] ? 550 : 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.book,
                                      size: 30, color: Colors.black),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text('Profile pressed')),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task['title'] ?? 'No Title',
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          "Assignment is Due - ${task['dueDate']?.toDate()?.toLocal().toString().split(' ')[0] ?? 'Unknown'}",
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (userRole == 'Student' && hasUploaded)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Text(
                                          'Done',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF06BD39),
                                          ),
                                        ),
                                      ),
                                    if (userRole == 'Teacher' ||
                                        userRole == 'Admin')
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.delete,
                                                color: Colors.black),
                                            onPressed: () {
                                              // Konfirmasi sebelum menghapus
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text('Delete Task'),
                                                    content: Text(
                                                        'Are you sure you want to delete this task?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _deleteTask(taskId);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Delete'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit,
                                                color: Colors.black),
                                            onPressed: () {
                                              // Konfirmasi sebelum menghapus
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      'Edit Task',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "Poppins"),
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to edit this task?',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              "Poppins"),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Poppins"),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          'Edit',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "Poppins"),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              task['description'] ?? 'No Description',
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Container(
                            child: ListTile(
                              subtitle: url != null
                                  ? GestureDetector(
                                      onTap: () => _launchUrl(
                                          url), // Memanggil fungsi dengan parameter url
                                      child: Text(
                                        url,
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      'No URL available'), // Menangani kasus jika URL tidak ada
                            ),
                          ),
                          Spacer(),
                          if (_isExpandedList[index])
                            GestureDetector(
                              onTap: () async {
                                // Panggil metode untuk memilih file
                                pickFile(); // Ganti ini dengan nama metode yang kamu gunakan
                                setState(() {
                                  selectedTaskTitle =
                                      title; // Simpan title dari task yang dipilih
                                });

                                // Tampilkan snackbar untuk konfirmasi task yang dipilih
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Task "$title" selected')),
                                );
                              },
                              child: Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: 300,
                                      height:
                                          210, // Tinggi ditingkatkan untuk memberikan ruang lebih
                                      decoration: BoxDecoration(
                                        color: Colors.grey[250],
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.grey, width: 1.2),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(
                                            16.0), // Padding untuk container utama
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center, // Memusatkan kolom
                                          crossAxisAlignment: CrossAxisAlignment
                                              .center, // Memusatkan kolom
                                          children: [
                                            Transform.scale(
                                              scale: 1.5,
                                              child: Image(
                                                image: AssetImage(
                                                    'assets/images/upload.png'),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    10), // Spasi antara gambar dan teks
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: Colors
                                                    .blue, // Anda bisa menambahkan warna atau properti lain di sini
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 8.0,
                                                    horizontal:
                                                        16.0), // Padding jika diperlukan
                                                child: Text(
                                                  'Upload Here',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: "Poppins",
                                                    color: Colors
                                                        .white, // Ubah warna teks agar lebih kontras
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    5), // Spasi antara teks dan deskripsi
                                            Text(
                                              'You can upload files here',
                                              textAlign: TextAlign
                                                  .center, // Memusatkan teks
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (_isExpandedList[index])
                            GestureDetector(
                              onTap: saveChanges,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 28, top: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors
                                            .blue, // Anda bisa menambahkan warna atau properti lain di sini
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                            horizontal:
                                                16.0), // Padding jika diperlukan
                                        child: Text(
                                          'Save Changes',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Poppins",
                                            color: Colors
                                                .white, // Ubah warna teks agar lebih kontras
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors
                                              .grey, // Anda bisa menambahkan warna atau properti lain di sini
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                              horizontal:
                                                  16.0), // Padding jika diperlukan
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Poppins",
                                              color: Colors
                                                  .white, // Ubah warna teks agar lebih kontras
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!_isExpandedList[index])
                                Padding(
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Text(
                                    "See more",
                                    style: TextStyle(
                                      fontFamily: 'poppins',
                                      fontSize: 21,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: Transform.rotate(
                                  angle:
                                      _isExpandedList[index] ? 1.5708 : -1.5708,
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back_ios, size: 30),
                                    onPressed: () {
                                      setState(() {
                                        _isExpandedList[index] =
                                            !_isExpandedList[index];
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              });
        },
      ),
      floatingActionButton: (userRole == 'Teacher' || userRole == 'Admin')
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTask()),
                );
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Colors.black,
              shape: CircleBorder(), // Mengatur bentuk menjadi bulat sempurna
            )
          : null, // Menyembunyikan FAB jika bukan Teacher/Admin
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
