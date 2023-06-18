import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _selectedImage;
  String? _avatarImageUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();

      setState(() {
        if (snapshot.exists) {
          _nameController.text = snapshot['name'];
          _phoneNumberController.text = snapshot['phone'];
          if (snapshot['avatarImageUrl'] != "") {
            _avatarImageUrl = snapshot['avatarImageUrl'];
          }
        }
          _emailController.text = user.email.toString();
      });
    }
  }

  Future<void> _selectImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImageToFirebaseStorage() async {
    if (_selectedImage == null) {
      return;
    }

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('avatars')
        .child('${DateTime.now()}.jpg');

    await ref.putFile(_selectedImage!);

    String imageUrl = await ref.getDownloadURL();

    setState(() {
      _avatarImageUrl = imageUrl;
    });
  }

  Future<void> _deletePreviousImageFromFirebaseStorage() async {
    if (_avatarImageUrl != null) {
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .refFromURL(_avatarImageUrl!);

      await storageReference.delete();

      setState(() {
        _avatarImageUrl = null;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Hapus file gambar sebelumnya dari Firebase Storage
      _deletePreviousImageFromFirebaseStorage().then((_) {
        // Upload gambar profil ke Firebase Storage
        _uploadImageToFirebaseStorage().then((_) {
          // Lakukan operasi lainnya setelah gambar profil diunggah
          // Misalnya, simpan data ke Firebase Firestore

          final User? user = _auth.currentUser;
          final userId = user!.uid;

          final userData = {
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneNumberController.text,
            'avatarImageUrl': _avatarImageUrl,
          };

          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set(userData)
              .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Update profile berhasil"),
                duration: Duration(seconds: 2),
                behavior:
                    SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
                backgroundColor: Colors.green,
              ),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Update profile gagal"),
                duration: Duration(seconds: 2),
                behavior:
                    SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
                backgroundColor: Colors.red,
              ),
            );
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _selectImageFromGallery,
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_avatarImageUrl != null
                            ? NetworkImage(_avatarImageUrl!)
                            : AssetImage('assets/images/logo.png')
                                as ImageProvider<Object>),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Konfirmasi"),
                        content: Text("Perbarui profile?"),
                        actions: [
                          TextButton(
                            child: Text("Batal"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          TextButton(
                            child: Text("Lanjutkan"),
                            onPressed: () {
                              // Panggil fungsi onDelete setelah konfirmasi
                              _submitForm();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  )
                },
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
