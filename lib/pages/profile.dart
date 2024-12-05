import 'package:classroom/main.dart';
import 'package:classroom/pages/home.dart';
import 'package:classroom/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  String? userCreate;
  String? firstAccess;
  String? lastAccess;

  TextEditingController nameController = TextEditingController();
  TextEditingController noIndukController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserData(); // Ambil data pengguna saat halaman dimuat
    _recordLoginActivity();
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
          setState(() {
            userName = userDoc['name'];
            userNoInduk = userDoc['noInduk'];
            userRole = userDoc['role'];
            userEmail = userDoc['email'];

            Timestamp? createdAtTimestamp = userDoc['createdAt'];
            if (createdAtTimestamp != null) {
              DateTime createdAtDate = createdAtTimestamp.toDate();
              userCreate = DateFormat('dd-MM-yyyy HH:mm').format(createdAtDate);
            }

            nameController.text = userName ?? '';
            noIndukController.text = userNoInduk ?? '';
            emailController.text = userEmail ?? '';
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

  Future<void> _recordLoginActivity() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final now = DateTime.now();
        final formattedDate =
            DateFormat('dd-MM-yyyy').format(now); // Format tanggal
        final formattedTime = DateFormat('HH:mm').format(now); // Format waktu

        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        DocumentSnapshot userDoc = await userDocRef.get();

        if (userDoc.exists) {
          // Update hanya last access time
          await userDocRef.update({
            'lastAccess': '$formattedDate $formattedTime',
          });
        } else {
          // Jika login pertama kali, inisialisasi firstAccess dan lastAccess
          await userDocRef.set({
            'firstAccess': '$formattedDate $formattedTime',
            'lastAccess': '$formattedDate $formattedTime',
            'name': userName ?? '',
            'noInduk': userNoInduk ?? '',
            'role': userRole ?? '',
            'email': userEmail ?? '',
          });
        }

        setState(() {
          lastAccess = '$formattedDate $formattedTime';
          if (firstAccess == null) {
            firstAccess = '$formattedDate $formattedTime';
          }
        });
      }
    } catch (e) {
      print('Error recording login activity: $e');
    }
  }

  // Fungsi untuk memperbarui data pengguna di Firestore
  Future<void> _updateUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update data di Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': nameController.text,
          'noInduk': noIndukController.text,
          'email': emailController.text,
        });

        setState(() {
          userName = nameController.text;
          userNoInduk = noIndukController.text;
          userEmail = emailController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating data')),
      );
    }
  }

  // Fungsi untuk menampilkan dialog konfirmasi hanya sekali
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xFFE6F1FF), // Warna biru cerah
              title: Text(
                'Confirm Changes',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF005F8C), // Biru lebih gelap
                ),
              ),
              content: Text(
                'Are you sure you want to update your data?',
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: Color(0xFF005F8C), // Biru lebih gelap
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No', style: TextStyle(fontFamily: 'poppins')),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Yes', style: TextStyle(fontFamily: 'poppins')),
                ),
              ],
            );
          },
        ) ??
        false;
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

  // Fungsi untuk menampilkan dialog edit dan meminta konfirmasi sebelum menyimpan data
  void _showEditDialog(String title, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFE6F1FF), // Warna biru cerah
          title: Text(
            'Edit $title',
            style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
              color: Color(0xFF005F8C), // Biru lebih gelap
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter $title',
              hintStyle: TextStyle(fontFamily: 'poppins'),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(fontFamily: 'poppins')),
            ),
            TextButton(
              onPressed: () async {
                bool shouldUpdate = await _showConfirmationDialog();
                if (shouldUpdate) {
                  Navigator.of(context).pop(); // Close edit dialog
                  _updateUserData(); // Save changes to Firestore
                }
              },
              child: Text('Save', style: TextStyle(fontFamily: 'poppins')),
            ),
          ],
        );
      },
    );
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
                'Account',
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
                  color: Color(0xFF8FD7FF),
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
                  ).then((_) {
                    Navigator.pop(context);
                  });
                },
              ),
            Divider(),
            ListTile(
              title: Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'poppins',
                ),
              ),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 30.0, horizontal: 20.0), // Padding lebih besar
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Transform.scale(
                  scale: 2.5,
                  child: Image.asset('assets/images/ava.png'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70, left: 10),
              child: Column(
                children: [
                  _buildListTile('Name', userName, nameController),
                  ListTile(
                    title: Text(
                      'Email',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Text(
                      userEmail ?? 'Unknown',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Role',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Text(
                      userRole ?? 'Unknown',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Identification Number',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Text(
                      userNoInduk ?? 'Unknown',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Login Activity :',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'First Access to app',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          subtitle: Text(
                            userCreate ?? 'Unknown',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Last Access to app',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          subtitle: Text(
                            lastAccess ?? 'Calculating...',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build ListTile with edit functionality
  ListTile _buildListTile(
      String title, String? value, TextEditingController controller) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        value ?? 'Loading...',
        style: TextStyle(fontFamily: 'poppins'),
      ),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Color(0xFF005F8C)), // Ikon edit
        onPressed: () => _showEditDialog(
            title, controller), // Menampilkan dialog edit saat ditekan
      ),
      onTap: () => _showEditDialog(title, controller),
    );
  }
}
