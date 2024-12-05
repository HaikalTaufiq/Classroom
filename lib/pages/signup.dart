import 'package:classroom/pages/loginpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool showProgress = false;
  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController noIndukController = TextEditingController();

  bool _isObscure = true;
  bool _isObscure2 = true;

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
                    _buildInputField('Nama', nameController),
                    const SizedBox(height: 10),
                    _buildInputField('No Induk', noIndukController),
                    const SizedBox(height: 10),
                    _buildInputField(
                      'Email',
                      emailController,
                      isEmail: true,
                    ),
                    const SizedBox(height: 10),
                    _buildPasswordField('Password', passwordController),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      'Confirm Password',
                      confirmpassController,
                      confirm: true,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            showProgress = true;
                          });
                          signUp(emailController.text, passwordController.text);
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
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Colors.black54,
                          fontFamily: 'poppins',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 360,
          height: 57,
          margin: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            color: Color(0xffEBFDFC),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "$label tidak boleh kosong";
              }
              if (isEmail &&
                  !RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                      .hasMatch(value)) {
                return "Masukkan email yang valid";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller,
      {bool confirm = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 360,
          height: 57,
          margin: const EdgeInsets.only(top: 10),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            color: Color(0xffEBFDFC),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: confirm ? _isObscure2 : _isObscure,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: Icon(confirm
                    ? (_isObscure2 ? Icons.visibility_off : Icons.visibility)
                    : (_isObscure ? Icons.visibility_off : Icons.visibility)),
                onPressed: () {
                  setState(() {
                    if (confirm) {
                      _isObscure2 = !_isObscure2;
                    } else {
                      _isObscure = !_isObscure;
                    }
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "$label tidak boleh kosong";
              }
              if (!confirm && value.length < 3) {
                return "Password minimal 3 karakter";
              }
              if (confirm && value != passwordController.text) {
                return "Password tidak cocok";
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  void signUp(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await postDetailsToFirestore(
          email,
          nameController.text,
          noIndukController.text,
        );
        setState(() {
          showProgress = false;
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          showProgress = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Terjadi kesalahan")),
        );
      }
    }
  }

  Future<void> postDetailsToFirestore(
      String email, String name, String noInduk) async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;

    if (user != null) {
      await firebaseFirestore.collection('users').doc(user.uid).set({
        'email': email,
        'name': name,
        'noInduk': noInduk,
        'role': 'Student',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
}
