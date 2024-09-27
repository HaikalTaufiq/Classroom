import 'package:classroom/main.dart';
import 'package:classroom/pages/admin/register.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:classroom/pages/profile.dart';
import 'package:classroom/pages/task/addtask.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> _isExpandedList = [];
  String? userRole; // Variabel untuk menyimpan role pengguna

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Ambil role pengguna saat halaman dimuat
  }

  // Fungsi untuk mengambil role pengguna dari Firestore
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

  // Fungsi untuk menghapus task dari Firestore
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
                'Task',
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
                'Dashboard',
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
            Divider(),
            ListTile(
              title: Text(
                'Task',
                style: TextStyle(
                  fontFamily: 'poppins',
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TaskPage()), // Ganti TaskPage() dengan nama halaman yang ingin Anda tuju
                ).then((_) {
                  Navigator.pop(context); // Menutup drawer setelah navigasi
                });
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
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
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

          return ListView.builder(
            padding: EdgeInsets.all(20),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index].data() as Map<String, dynamic>;
              final taskId = tasks[index].id; // Dapatkan ID dokumen

              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Color(0xffE8E9E7),
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                height: _isExpandedList[index] ? 500 : 200,
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
                            icon:
                                Icon(Icons.book, size: 30, color: Colors.black),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Profile pressed')),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                              // Tampilkan ikon delete hanya untuk Teacher dan Admin
                              if (userRole == 'Teacher' || userRole == 'Admin')
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
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
                                                  Navigator.of(context)
                                                      .pop(), // Tutup dialog
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                _deleteTask(taskId);
                                                Navigator.of(context)
                                                    .pop(); // Tutup dialog setelah menghapus
                                              },
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
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
                    Spacer(),
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
                            angle: _isExpandedList[index] ? 1.5708 : -1.5708,
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
}
