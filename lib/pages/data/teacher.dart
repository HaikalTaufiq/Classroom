// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:classroom/pages/admin/register.dart';
import 'package:classroom/pages/data/task-data.dart';
import 'package:classroom/pages/home.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:classroom/main.dart';
import 'package:classroom/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Teacher extends StatefulWidget {
  const Teacher({super.key});

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? userRole;

  @override
  void initState() {
    super.initState();
    _getUserRole();
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
          userRole = userDoc['role'];
        });
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
  }

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

  Future<void> _deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: ${e.toString()}')),
      );
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
                'Teacher Data',
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
              padding: const EdgeInsets.only(right: 16.0),
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
            if (userRole == 'Teacher') Divider(),
            if (userRole == 'Teacher')
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
                  );
                },
              ),
            if (userRole == 'Teacher') Divider(),
            if (userRole == 'Teacher')
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
                    MaterialPageRoute(builder: (context) => TaskData()),
                  ).then((_) {
                    Navigator.pop(context);
                  });
                },
              ),
            Divider(),
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
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  ).then((_) {
                    Navigator.pop(context);
                  });
                },
              ),
            if (userRole == 'Admin') Divider(),
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
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Teacher')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No teacher data found',
                style: TextStyle(fontFamily: 'poppins', fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot studentDoc = snapshot.data!.docs[index];

              String name = studentDoc['name'];
              String noInduk = studentDoc['noInduk'];

              return Container(
                decoration: BoxDecoration(
                  color: Color(0xffE8E9E7),
                  borderRadius: BorderRadius.circular(50),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.grey,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Delete User'),
                                content: Text(
                                    'Are you sure you want to delete this user?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      String userId = studentDoc.id;
                                      await _deleteUser(userId);
                                      Navigator.of(context).pop();
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
              );
            },
          );
        },
      ),
    );
  }
}
