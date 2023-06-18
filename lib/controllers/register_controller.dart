// register_controller.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> register() async {
    try {
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        // Tampilkan pesan error jika email atau password kosong
        return;
      }

      // Membuat akun menggunakan email dan password
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Akun berhasil dibuat
      // Lakukan navigasi ke halaman selanjutnya, atau tampilkan pesan sukses
    } catch (e) {
      // Terjadi kesalahan saat membuat akun
      // Tampilkan pesan error atau lakukan penanganan kesalahan lainnya
    }
  }
}
