import 'package:classroom/main.dart';
import 'package:classroom/pages/admin/register.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:classroom/pages/task/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? userName; // Variabel untuk menyimpan nama pengguna
  String? userNoInduk; // Variabel untuk menyimpan no induk
  String? userRole; // Variabel untuk menyimpan role pengguna
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _getUserData(); // Ambil data pengguna saat halaman dimuat
  }

  // Fungsi untuk mengambil data pengguna dari Firestore
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
            userNoInduk = userDoc['noInduk']; // Ambil no induk
            userRole = userDoc['role']; // Ambil role
            userEmail = userDoc['email'];
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
                'Account',
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
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 90),
              child: Transform.scale(
                scale: 2.5,
                child: Image.asset('assets/images/ava.png'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100), // Mengurangi jarak
            child: Container(
              width: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName ??
                        'Loading...', // Tampilkan nama pengguna atau 'Loading...'
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Divider(),
                  Text(
                    userNoInduk ??
                        'Loading...', // Tampilkan no induk atau 'Loading...'
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Divider(),
                  Text(
                    userRole ??
                        'Loading...', // Tampilkan role atau 'Loading...'
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Divider(),
                  Text(
                    userEmail ??
                        'Loading...', // Tampilkan role atau 'Loading...'
                    style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
