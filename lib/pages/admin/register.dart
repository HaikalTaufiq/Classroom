import 'package:classroom/pages/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool showProgress = false;
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // New controllers for Nama and No Induk
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noIndukController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;

  // Daftar opsi untuk dropdown
  var options = ['Student', 'Teacher', 'Admin'];
  var _currentItemSelected = 'Student';
  var role = 'Student';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 35, right: 35),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Register Now',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // New input for Nama
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Nama',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 320,
                      height: 57,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Color(0xffEBFDFC),
                      ),
                      child: TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Nama cannot be empty";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // New input for No Induk
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'No Induk',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 320,
                      height: 57,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Color(0xffEBFDFC),
                      ),
                      child: TextFormField(
                        controller: noIndukController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "No Induk cannot be empty";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Email Input
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 320,
                      height: 57,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Color(0xffEBFDFC),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Email cannot be empty";
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return "Please enter a valid email";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Password Input
                    const Padding(
                      padding: EdgeInsets.only(left: 8, top: 10),
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 320,
                      height: 57,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Color(0xffEBFDFC),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password cannot be empty";
                          }
                          if (value.length < 3) {
                            return "Please enter a valid password with at least 3 characters";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Confirm Password Input
                    const Padding(
                      padding: EdgeInsets.only(left: 8, top: 10),
                      child: Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 320,
                      height: 57,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        color: Color(0xffEBFDFC),
                      ),
                      child: TextFormField(
                        controller: confirmpassController,
                        obscureText: _isObscure2,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure2
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure2 = !_isObscure2;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                        ),
                        validator: (value) {
                          if (confirmpassController.text !=
                              passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dropdown untuk Role
                    const Padding(
                      padding: EdgeInsets.only(left: 8, top: 10),
                      child: Text(
                        'Role',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 320,
                      height: 57,
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xffEBFDFC),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Color(0xffEBFDFC),
                          isDense: true,
                          isExpanded: true,
                          iconEnabledColor: Colors.black,
                          items: options.map((String dropDownStringItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(
                                dropDownStringItem,
                                style: const TextStyle(
                                  fontFamily: "poppins",
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            setState(() {
                              _currentItemSelected = newValueSelected!;
                              role = newValueSelected;
                            });
                          },
                          value: _currentItemSelected,
                          style: const TextStyle(
                            color: Colors
                                .black, // Text color for the selected item
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          borderRadius: BorderRadius.circular(
                              14), // Border radius for the dropdown
                          // Padding to make it fit nicely inside the container
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            showProgress = true;
                          });
                          signUp(
                            emailController.text,
                            passwordController.text,
                            role,
                            nameController.text,
                            noIndukController.text,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff95D8EE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Link to Login Page
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password, String role, String name,
      String studentId) async {
    if (_formkey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        postDetailsToFirestore(email, role, name, studentId);
      } catch (e) {
        print(e);
      }
    }
  }

  postDetailsToFirestore(
      String email, String role, String name, String noInduk) async {
    // Call Firestore to add user data
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    User? user = _auth.currentUser;
    await firebaseFirestore.collection("users").doc(user!.uid).set({
      'email': email,
      'name': name,
      'noInduk': noInduk,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    }).then((value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }
}
