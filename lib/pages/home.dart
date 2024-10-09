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
import 'package:flutter/cupertino.dart';
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
  final TextEditingController _controller = TextEditingController();
  List<String> _dataList = ['Homepage', 'Profile'];
  List<String> _filteredList = [];
  bool _isDropdownVisible = false;

  @override
  void initState() {
    super.initState();
    _getUserRole(); // Ambil role pengguna saat halaman dimuat
    _isDropdownVisible = false;
  }

  void _filterList(String query) {
    setState(() {
      _filteredList = _dataList
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _isDropdownVisible =
          _filteredList.isNotEmpty; // Show dropdown if list is not empty
    });
  }

  void _navigateToPage(String page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        switch (page) {
          case 'Homepage':
            return const HomePage();
          case 'Profile':
            return const ProfilePage();
          default:
            return const Scaffold(
              body: Center(child: Text('Page not found')),
            );
        }
      }),
    );
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isDropdownVisible = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(
                        0xffECF1ED), // Background color for the search bar
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: _filterList,
                          decoration: InputDecoration(
                            hintText: 'Search', // Hint text instead of label
                            hintStyle: TextStyle(
                                color: Colors.black), // Style for hint text
                            border: InputBorder.none, // Remove the border
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15), // Padding inside the TextField
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(Icons.search),
                      ), // Ikon pencarian
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isDropdownVisible ? 150 : 0,
                curve: Curves.easeIn,
                child: SingleChildScrollView(
                  child: Column(
                    children: _filteredList.map((item) {
                      return ListTile(
                        title: Text(item),
                        onTap: () {
                          _navigateToPage(
                              item); // Navigate to the selected page
                        },
                      );
                    }).toList(),
                  ),
                ),
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
            if (userRole == 'Teacher')
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
      ),
    );
  }
}
