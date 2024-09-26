// ignore_for_file: prefer_const_constructors

import 'package:classroom/main.dart';
import 'package:classroom/pages/admin/register.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:classroom/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isExpanded =
      false; // Menandakan apakah konten tambahan ditampilkan atau tidak

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Task',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
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
              padding: const EdgeInsets.only(right: 16.0, top: 0),
              child: IconButton(
                icon: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  ).then((_) {
                    Navigator.pop(context);
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
              height: 100,
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
                  MaterialPageRoute(builder: (context) => HomePage()),
                ).then((_) {
                  Navigator.pop(context);
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
                Navigator.pop(context);
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
                Navigator.pop(context);
                _logout();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300), // Durasi animasi
              decoration: BoxDecoration(
                color: Color(0xffE8E9E7),
                borderRadius: BorderRadius.circular(20),
              ),
              height: _isExpanded
                  ? 500
                  : 300, // Mengubah tinggi container berdasarkan state
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      top: 15, // Adjust top padding as needed
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 50, // Atur lebar sesuai kebutuhan
                          height: 50, // Atur tinggi sesuai kebutuhan
                          decoration: BoxDecoration(
                            color: Colors.grey[300], // Warna latar belakang
                            shape: BoxShape.circle, // Membuat bentuk lingkaran
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons
                                  .person, // Gunakan ikon profil yang diinginkan
                              size: 30, // Atur ukuran ikon sesuai kebutuhan
                              color: Colors.black, // Ubah warna jika diperlukan
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Profile pressed')),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Lorem Ipsum",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 20, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w800, // Optional: make the text bold
                                ),
                              ),
                              Text(
                                "Asignment is due - Thursday, 26 September 2024",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 10, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w300, // Optional: make the text bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ... kode bagian atas container tetap sama
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: Text(
                        "Is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Spacer(), // Memungkinkan ruang antara isi dan tombol panah
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!_isExpanded) // Tampilkan "See more" hanya jika tidak diperpanjang
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
                        padding: const EdgeInsets.only(right: 20, bottom: 10),
                        child: Transform.rotate(
                          angle: _isExpanded
                              ? 1.5708
                              : -1.5708, // Mengubah arah panah
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _isExpanded =
                                    !_isExpanded; // Toggle state saat ikon ditekan
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
