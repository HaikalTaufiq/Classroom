// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

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
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MK13 extends StatefulWidget {
  const MK13({super.key});

  @override
  State<MK13> createState() => _TaskPageState();
}

class _TaskPageState extends State<MK13> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> _isExpandedList = [];
  String? userRole;
  String? userNoInduk;
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

      try {
        await fileRef.putFile(File(filePath!));

        String downloadURL = await fileRef.getDownloadURL();

        // Menambahkan field grade dengan nilai default "-"
        DocumentReference docRef =
            await FirebaseFirestore.instance.collection('uploads').add({
          'userId': userId, // Tambahkan userId
          'userName': userName,
          'fileName': fileName,
          'uploadTime': Timestamp.now(),
          'title': selectedTaskTitle, // Gunakan title dari task yang dipilih
          'fileURL': downloadURL, // Simpan URL file
          'filePath': 'uploads/$fileName', // Simpan filePath
          'grade': '-', // Menambahkan field grade dengan nilai default "-"
          'code': 'MK-13',
          'noInduk': userNoInduk,
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
            userNoInduk = userDoc['noInduk']; // Ambil ID
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

              final uploads = uploadSnapshot.data!.docs;
              // Map 'title' to its corresponding grade and fileURL
              final uploadData = {
                for (var doc in uploads)
                  doc['title']: {
                    'grade': doc['grade'] ??
                        '-', // Default to '-' if grade is not available
                    'fileURL': doc['fileURL'] ??
                        '', // Default to '' if fileURL is not available
                  }
              };

              return ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index].data() as Map<String, dynamic>;
                  final taskId = tasks[index].id;
                  final String? videoUrl = task['url'];
                  String title = task['title'] ?? 'No Title';
                  String description = task['description'] ?? 'No Description';

                  // Check if the task title is in uploads
                  final hasUploaded = uploadData.containsKey(title);
                  final String grade =
                      hasUploaded ? uploadData[title]!['grade'] : '-';
                  final String fileURL =
                      hasUploaded ? uploadData[title]!['fileURL'] : '';
                  // Extract video ID from URL
                  String? videoId =
                      YoutubePlayer.convertUrlToId(videoUrl ?? '');

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: Color(0xffE8E9E7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(15),
                    child: IntrinsicHeight(
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
                                          title,
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
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 0),
                                        child: IconButton(
                                          onPressed: () {
                                            // Memanggil fungsi _deleteTask untuk menghapus task
                                            _deleteTask(taskId);
                                          },
                                          icon: Icon(Icons.delete,
                                              size: 30, color: Colors.red),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Menambahkan deskripsi sebelum video player
                          Text(
                            description,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 20),
                          if (videoId != null)
                            YoutubePlayer(
                              controller: YoutubePlayerController(
                                initialVideoId: videoId,
                                flags: YoutubePlayerFlags(
                                  autoPlay: false,
                                  mute: false,
                                ),
                              ),
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.red,
                              onReady: () {
                                print('Video Ready');
                              },
                            )
                          else
                            Text(
                              'Invalid or Missing Video URL',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          // Tabel yang muncul saat dibuka
                          if (_isExpandedList[index])
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Table(
                                border: TableBorder.all(
                                    color: Colors.grey, width: 1),
                                children: [
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Grade',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          hasUploaded
                                              ? '$grade'
                                              : '-', // Ternary operator
                                          style: TextStyle(
                                            fontFamily: 'poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Uploaded Task',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: hasUploaded
                                              ? () => _launchUrl(fileURL)
                                              : null, // Null means it doesn't do anything if not uploaded
                                          child: Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // Ensures Row takes minimal space
                                            children: [
                                              if (hasUploaded &&
                                                  fileURL
                                                      .isNotEmpty) // Show icon only if file is uploaded
                                                // Add space between text and icon
                                                if (hasUploaded &&
                                                    fileURL.isNotEmpty)
                                                  Icon(
                                                    Icons
                                                        .download, // Icon for download
                                                    color: Colors
                                                        .blue, // Adjust color to match your design
                                                    size:
                                                        16, // Adjust size if needed
                                                  ),
                                              SizedBox(width: 5),
                                              Text(
                                                hasUploaded &&
                                                        fileURL.isNotEmpty
                                                    ? 'Download Task'
                                                    : '-', // Conditionally displayed text
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          if (_isExpandedList[index])
                            Column(
                              children: [
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
                                          content:
                                              Text('Task "$title" selected')),
                                    );
                                  },
                                  child: Center(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 185),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center, // Memusatkan kolom
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .end, // Memusatkan kolom
                                              children: [
                                                SizedBox(
                                                    height:
                                                        10), // Spasi antara gambar dan teks
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
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
                                                      'Add Submission',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "Poppins",
                                                        color: Colors
                                                            .white, // Ubah warna teks agar lebih kontras
                                                      ),
                                                    ),
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
                                  Align(
                                    alignment: Alignment
                                        .bottomRight, // Posisikan ke pojok kanan
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 16,
                                          top: 10), // Sesuaikan jarak
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .end, // Letakkan elemen di ujung kanan
                                        children: [
                                          GestureDetector(
                                            onTap: saveChanges,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors
                                                    .blue, // Anda bisa menambahkan warna atau properti lain di sini
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 16.0),
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
                                          ),
                                          SizedBox(
                                              width: 10), // Spasi antara tombol
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors
                                                    .grey, // Anda bisa menambahkan warna atau properti lain di sini
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0,
                                                        horizontal: 16.0),
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
                              ],
                            ),

                          // Gunakan Align untuk memposisikan panah di bagian bawah
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: Icon(
                                _isExpandedList[index]
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 30,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isExpandedList[index] =
                                      !_isExpandedList[index];
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
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
