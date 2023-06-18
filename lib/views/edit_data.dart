import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

class EditData extends StatefulWidget {
  final String documentId;

  EditData({required this.documentId});

  @override
  _EditDataState createState() => _EditDataState();
}

class ImageData {
  final String imageUrl;

  ImageData({required this.imageUrl});

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
    };
  }
}

class _EditDataState extends State<EditData> {
  final _priceController = TextEditingController();
  final _titleController = TextEditingController();

  double price = 0.0;
  String title = '';
  String location = '';
  String imageUrlOld="";
  Position? currentPosition;

  File? _imageFile;
  final picker = ImagePicker();

  String currentImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentData();
  }

  void _fetchCurrentData() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('property')
        .doc(widget.documentId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        currentImageUrl = data['image'].toString();
        _titleController.text = data['title'] as String;
        imageUrlOld=data['image'];
        _priceController.text = (data['price'] ?? 0.0).toString();
        if (data['cordinates'] != null) {
          GeoPoint coordinates = data['cordinates'] as GeoPoint;
          currentPosition = Position(
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            accuracy: 0.0,
            altitude: 0.0,
            heading: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            timestamp: DateTime.now(),
          );
        }
      });
    }
  }

  void _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _uploadImage() async {
    if (_imageFile != null) {
      //  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
      // await storage.refFromURL(imageUrlOld).delete();
      if(imageUrlOld!=""){
         await firebase_storage.FirebaseStorage.instance.refFromURL(imageUrlOld).delete();
      }
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child(DateTime.now().toString());

      firebase_storage.UploadTask uploadTask = ref.putFile(_imageFile!);

      await uploadTask.whenComplete(() async {
        String imageUrl = await ref.getDownloadURL();
        saveData(imageUrl);
      });
      return;
    }
    saveData(currentImageUrl);
    return;
  }

  void saveData(imageUrl) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('property');
    Map<String, dynamic> data = {
      "title": _titleController.text,
      "image": imageUrl,
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "coordinates":
          GeoPoint(currentPosition!.latitude, currentPosition!.longitude),
    };

    try {
      await collectionRef.doc(widget.documentId).update(data);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Data berhasil dirubah"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan coba lagi."),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Position> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Data'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Nama Property',
              ),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Price',
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 300,
              child: HereMap(onMapCreated: _onMapCreated),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _selectImage,
              child: Text('Ambil Gambar dari Kamera'),
            ),
            SizedBox(height: 16.0),
            if (currentImageUrl.isNotEmpty)
              Image.network(
                currentImageUrl,
                height: 200,
                width: 200,
              ),
            if (_imageFile != null)
              Image.file(
                File(_imageFile!.path),
                height: 200,
                width: 200,
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Konfirmasi"),
                      content: Text("Perbarui item ini?"),
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
                            _uploadImage();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                )
              },
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(HereMapController hereMapController) async {
    // currentPosition=await _getCurrentLocation();
    hereMapController.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (MapError? error) async {
        if (error != null) {
          print('Map scene not loaded. MapError: ${error.toString()}');
          return;
        }

        if (currentPosition != null) {
          const double distanceToEarthInMeters = 8000;
          MapMeasure mapMeasureZoom =
              MapMeasure(MapMeasureKind.distance, distanceToEarthInMeters);
          GeoCoordinates location = GeoCoordinates(
            currentPosition!.latitude,
            currentPosition!.longitude,
          );

          hereMapController.camera
              .lookAtPointWithMeasure(location, mapMeasureZoom);
          addMapMarker(hereMapController, location);
        }
      },
    );
  }

  void addMapMarker(
      HereMapController hereMapController, GeoCoordinates location) async {
    ByteData fileData = await rootBundle.load("assets/images/circle.png");
    Uint8List pixelData = fileData.buffer.asUint8List();
    // Buat ikon marker
    MapImage markerImage =
        MapImage.withPixelDataAndImageFormat(pixelData, ImageFormat.png);
    // Create the map marker
    MapMarker mapMarker = MapMarker(location, markerImage);

    // Add the marker to the map
    hereMapController.mapScene.addMapMarker(mapMarker);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
