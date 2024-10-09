// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:classroom/pages/loginpage.dart'; // Pastikan path ini benar
import 'package:classroom/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyDoWUC9mqOkE4cSQi3psRrP5XSGwONoNJ8',
          appId: '1:553575112331:web:a48a348166d91b23c27e8e',
          messagingSenderId: '553575112331',
          projectId: 'classroom-22f02')); // Initialize Firebase
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Transform.scale(
                scale: 2.5,
                child: Image.asset('assets/images/postman.png'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff35C5F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 150),
                ),
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffF43535),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 145),
                ),
                child: const Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
