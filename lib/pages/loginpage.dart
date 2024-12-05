import 'package:classroom/pages/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController noIndukController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isObscure = true;
  bool showProgress = false;
  String _errorMessage =
      ''; // Tambahkan variabel untuk menyimpan pesan kesalahan

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 100),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Input No Induk
                TextFormField(
                  controller: noIndukController,
                  decoration: InputDecoration(
                    labelText: 'No Induk',
                    labelStyle: TextStyle(
                        fontFamily: 'poppins',
                        color: Color(0xff95D8EE)), // Label dengan warna tombol
                    filled: true,
                    fillColor: Color(0xff95D8EE)
                        .withOpacity(0.2), // Warna dengan opacity
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xff95D8EE).withOpacity(
                            0.5), // Border dengan warna tombol dan opacity
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'No Induk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Input Password
                TextFormField(
                  controller: passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(
                        fontFamily: 'poppins',
                        color: Color(0xff95D8EE)), // Label dengan warna tombol
                    filled: true,
                    fillColor: Color(0xff95D8EE)
                        .withOpacity(0.2), // Warna dengan opacity
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 27, 115, 144).withOpacity(
                            0.5), // Border dengan warna tombol dan opacity
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Tampilkan error message
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        showProgress = true;
                        _errorMessage = ''; // Reset pesan error
                      });
                      login(noIndukController.text, passwordController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: const Color(0xff95D8EE),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login(String noInduk, String password) async {
    try {
      // Cari user berdasarkan No Induk
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('noInduk', isEqualTo: noInduk)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          _errorMessage = 'No Induk tidak ditemukan';
        });
        return;
      }

      // Ambil email dari dokumen pengguna
      var userDoc = query.docs.first;
      String email = userDoc['email'];

      // Verifikasi password dengan menggunakan Firebase Authentication
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Jika login berhasil, navigasi ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } catch (e) {
      setState(() {
        _errorMessage =
            'No Induk atau Password salah'; // Tampilkan pesan kesalahan
      });
    } finally {
      setState(() {
        showProgress = false;
      });
    }
  }
}
