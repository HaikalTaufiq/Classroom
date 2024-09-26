// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:classroom/main.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:classroom/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Mendefinisikan _scaffoldKey

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
      key: _scaffoldKey, // Menghubungkan GlobalKey dengan Scaffold
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80), // Set height of the AppBar
        child: AppBar(
          flexibleSpace: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Text(
                'Task',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 24, // Adjust font size as needed
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.menu), // Hamburger menu icon
            onPressed: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // Menggunakan GlobalKey untuk membuka Drawer
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
                Navigator.pop(context); // Menutup drawer
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
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffE8E9E7),
                borderRadius:
                    BorderRadius.circular(20), // Set the border radius
              ),
              height: 300, // Adjust height as needed for the content
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
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Center(
                      child: Text(
                        "Is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14, // Adjust text size as needed
                          fontWeight:
                              FontWeight.w400, // Optional: make the text bold
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.only(bottom: 10, right: 20, top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 50),
                            child: Transform.rotate(
                              angle: -1.5708,
                              child: IconButton(
                                icon: Icon(
                                  Icons
                                      .arrow_back_ios, // Menggunakan ikon panah ke bawah
                                  size: 30, // Atur ukuran ikon sesuai kebutuhan
                                ),
                                onPressed: () {
                                  // Tambahkan aksi yang diinginkan ketika ikon ditekan
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                              width: 8), // Tambahkan jarak antara ikon dan teks
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "See more",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize:
                                      21, // Sesuaikan ukuran teks sesuai kebutuhan
                                  fontWeight: FontWeight
                                      .w700, // Opsional: menjadikan teks tebal
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
