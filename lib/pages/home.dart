// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:classroom/pages/admin/register.dart';
import 'package:classroom/pages/data/student.dart';
import 'package:classroom/pages/data/task-data.dart';
import 'package:classroom/pages/data/teacher.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:classroom/pages/task/course.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini untuk Firestore
import 'package:classroom/main.dart';
import 'package:classroom/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Menambahkan GlobalKey
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
                'Home Page',
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
                'Home Page',
                style: TextStyle(
                  fontFamily: 'poppins',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            if (userRole == 'Admin' || userRole == 'Teacher') Divider(),
            if (userRole == 'Admin' || userRole == 'Teacher')
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
                    MaterialPageRoute(builder: (context) => HomePage()),
                  ); // Menutup drawer
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
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xffECF1ED),
              borderRadius: BorderRadius.circular(30),
            ),
            width: 380,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Text(
                    "Search",
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 15,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                ),
              ],
            ),
          ),
          if (userRole == 'Student')
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Course(),
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffE8F9F8),
                    borderRadius:
                        BorderRadius.circular(20), // Set the border radius
                  ),
                  height: 150, // Adjust height as needed for the content
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Course",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 25, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w800, // Optional: make the text bold
                                ),
                              ),
                              Text(
                                "Student Course",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 15, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w400, // Optional: make the text bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (userRole == 'Teacher' || userRole == 'Admin')
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Student(),
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffE8F9F8),
                    borderRadius:
                        BorderRadius.circular(20), // Set the border radius
                  ),
                  height: 150, // Adjust height as needed for the content
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Student",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 25, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w800, // Optional: make the text bold
                                ),
                              ),
                              Text(
                                "Online Student Data",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 15, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w400, // Optional: make the text bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (userRole == 'Admin')
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Teacher(),
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffF9E8E8),
                    borderRadius:
                        BorderRadius.circular(20), // Set the border radius
                  ),
                  height: 150, // Adjust height as needed for the content
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Teacher",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 25, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w800, // Optional: make the text bold
                                ),
                              ),
                              Text(
                                "Online Teacher Data",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 15, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w400, // Optional: make the text bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (userRole == 'Teacher' || userRole == 'Admin')
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xffF9E8E8),
                    borderRadius:
                        BorderRadius.circular(20), // Set the border radius
                  ),
                  height: 150, // Adjust height as needed for the content
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 25, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w800, // Optional: make the text bold
                                ),
                              ),
                              Text(
                                "Add Task For Student",
                                style: TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 15, // Adjust text size as needed
                                  fontWeight: FontWeight
                                      .w400, // Optional: make the text bold
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
