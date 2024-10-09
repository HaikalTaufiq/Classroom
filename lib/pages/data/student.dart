// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:classroom/pages/admin/register.dart';
import 'package:classroom/pages/data/task-data.dart';
import 'package:classroom/pages/home.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini untuk Firestore
import 'package:classroom/main.dart';
import 'package:classroom/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
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
                'Student Data',
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
                    MaterialPageRoute(builder: (context) => HomePage()),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(
                'users') // Koleksi Firestore tempat menyimpan data pengguna
            .where('role',
                isEqualTo: 'Student') // Mengambil data dengan role 'Student'
            .snapshots(), // Mendapatkan stream data secara real-time
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Tampilkan loading
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No student data found',
                style: TextStyle(fontFamily: 'poppins', fontSize: 16),
              ),
            ); // Tampilkan pesan jika tidak ada data
          }

          // Tampilkan data dalam bentuk ListView
          return Expanded(
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot studentDoc = snapshot.data!.docs[index];

                // Ambil data dari setiap dokumen
                String name = studentDoc['name'];
                String noInduk = studentDoc['noInduk'];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 24, // Ukuran lingkaran profile
                    child: Icon(
                      Icons.person, // Icon profile
                      size: 30,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.grey, // Warna lingkaran
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    noInduk,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Agar row tidak melebar penuh
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit, // Icon edit
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete, // Icon delete
                          color: Colors.grey,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
