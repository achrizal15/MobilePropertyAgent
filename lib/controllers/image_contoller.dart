import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class ImageController {
  // static CollectionReference property = firestore.instance.collection('property');

  static Future<String?> uploadImage(File imageFile) async {
    String fileName = basename(imageFile.path);
    FirebaseStorage storage = FirebaseStorage.instance;

    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(imageFile);

    return uploadTask.whenComplete(() {
      return ref.getDownloadURL().toString();
    }).catchError((onError) {
      return onError;
    }).toString();
  }
}
