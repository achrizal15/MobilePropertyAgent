import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/views/home.dart';
import 'package:project/views/register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
bool isLoading=false;
  Future<void> checkLoginStatus() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // Pengguna sudah login
      // Lakukan navigasi ke halaman Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> login() async {
    isLoading=true;
    try {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        // Tampilkan pesan error jika email atau password kosong
        return;
      }

      // Login menggunakan email dan password
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login berhasil
      // Lakukan navigasi ke halaman Home
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login berhasil, Selamat datang!"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      isLoading=false;
      // Terjadi kesalahan saat login
      // Tampilkan pesan error atau lakukan penanganan kesalahan lainnya
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenSize.height * 0.05),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Center(
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 2, 45, 119),
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Image.asset(
              "assets/images/welcome.png",
              width: screenSize.width, // Atur lebar gambar
              height: screenSize.height * 0.4, // Atur tinggi gambar
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: screenSize.width * 0.8,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: screenSize.width * 0.8,
                        child: TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Container(
                        width: screenSize.width * 0.8,
                        height: screenSize.height * 0.072,
                        child: ElevatedButton(
                          onPressed: isLoading?null:login,
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(16),
                              backgroundColor:
                                  const Color.fromARGB(255, 2, 45, 119),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5))),
                          child: Text(
                            isLoading?'Loading':'Login',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.14),
                        child: Container(
                          width: screenSize.width,
                          child: Row(
                            children: [
                              Text('Belum memiliki akun? '),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterScreen()),
                                  );
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 2, 45, 119),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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