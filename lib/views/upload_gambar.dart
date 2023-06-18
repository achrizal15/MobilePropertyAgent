import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/controllers/image_contoller.dart';

class ImageUp extends StatefulWidget {
  const ImageUp({super.key});

  @override
  State<ImageUp> createState() => _ImageUpState();
}

class _ImageUpState extends State<ImageUp> {
  String? imagePath;

  @override
  Widget build(BuildContext context) {
    void selectImage() async {}

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Gambar'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (imagePath != null ) ? 
               Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(image: NetworkImage(imagePath!), fit: BoxFit.cover)
                ),
               )
            :
            ClipRRect(
              borderRadius: BorderRadius.circular(
                  10.0), // Mengatur sudut melengkung untuk membuat gambar menjadi persegi
              child: Image.network(
                'https://st2.depositphotos.com/47577860/49695/v/450/depositphotos_496957738-stock-illustration-camera-settings-focus-icon-in.jpg', // URL gambar avatar
                width: 100.0, // Lebar gambar
                height: 100.0, // Tinggi gambar
                fit: BoxFit
                    .cover, // Menyesuaikan gambar agar sesuai dengan ukuran kotak
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(onPressed: () {}, child: Text('Unggah')),
          ],
        ),
      ),
    );
  }
}
