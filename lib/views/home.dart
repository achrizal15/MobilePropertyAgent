import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/views/ProfilePage.dart';
import 'package:project/views/edit_data.dart';
import 'package:project/views/input_data.dart';
import 'package:project/views/login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Logout berhasil"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Tangani kesalahan yang terjadi saat logout
      print('Error during logout: $e');
    }
  }

  void _addProperty() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddData()));
  }

  Future<void> deleteDocumentAndImage(
      String documentId, String imageUrl) async {
    try {
      // Hapus gambar dari Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      await storage.refFromURL(imageUrl).delete();

      // Hapus dokumen dari Firestore
      await FirebaseFirestore.instance
          .collection('property')
          .doc(documentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hapus data berhasil"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan saat menghapus data"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
            padding: EdgeInsets.only(bottom: 16.0, right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: 'Logout',
                  child: FloatingActionButton(
                    heroTag: "addData",
                    onPressed: _addProperty,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.add),
                    tooltip: 'Tambah Property',
                  ),
                ),
              ],
            )),
      ),
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(); // Panggil fungsi logout saat opsi logout dipilih
              } else if (value == 'profile') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Text('Profile'),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("property").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Extract the document list from the snapshot
            final documents = snapshot.data!.docs;
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                // Access the data of each document
                final documentData =
                    documents[index].data() as Map<String, dynamic>;
                final title = documentData['title'] ?? '';
                final price = documentData['price'] ?? '';
                String documentId = documents[index].id;
                double latitude = documentData['cordinates'].latitude;
                double longitude = documentData['cordinates'].longitude;
                return PropertyCard(
                  title: title,
                  price: price.toStringAsFixed(2),
                  location: "Longtitude : $longitude  Latitude : $latitude",
                  imageUrl: documentData["image"] ?? "",
                  onDelete: (() => deleteDocumentAndImage(
                      documentId, documentData['image'])),
                  onEditPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditData(documentId: documentId),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

// SizedBox(height: 16.0),
class PropertyCard extends StatelessWidget {
  final String title;
  final String price;
  final String location;
  final String imageUrl;
  final VoidCallback onDelete;
  final VoidCallback onEditPressed;

  const PropertyCard(
      {super.key,
      required this.title,
      required this.price,
      required this.location,
      required this.imageUrl,
      required this.onDelete,
      required this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(8.0),
            ),
            child: Image.network(
              imageUrl,
              height: 150.0,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.amber),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Konfirmasi"),
                            content: Text(
                                "Apakah Anda yakin ingin merubah item ini?"),
                            actions: [
                              TextButton(
                                child: Text("Batal"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text("Edit"),
                                onPressed: () {
                                  // Panggil fungsi onDelete setelah konfirmasi
                                  Navigator.pop(context);
                                  onEditPressed.call();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Konfirmasi"),
                            content: Text(
                                "Apakah Anda yakin ingin menghapus item ini?"),
                            actions: [
                              TextButton(
                                child: Text("Batal"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text("Hapus"),
                                onPressed: () {
                                  // Panggil fungsi onDelete setelah konfirmasi
                                  onDelete.call();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                ])
              ],
            ),
          ),
        ],
      ),
    );
  }
}
