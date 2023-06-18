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

class AddData extends StatefulWidget {
  @override
  _AddDataState createState() => _AddDataState();
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

class _AddDataState extends State<AddData> {
  final _priceController = TextEditingController();
  double price = 0.0;
  String title = '';
  String location = '';
  Position? currentPosition;
  bool submitText = false;
  File? _imageFile;
  final picker = ImagePicker();

  void _selectImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _uploadImage() async {
    submitText = true;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gambar belum dipilih'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child(DateTime.now().toString());

      firebase_storage.UploadTask uploadTask = ref.putFile(_imageFile!);
      await uploadTask.whenComplete(() async {
        String imageUrl = await ref.getDownloadURL();
        saveData(imageUrl);
      });
    } catch (e) {
      submitText = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Terjadi kesalahan coba lagi. Upload gambar gagal ${e.toString()}"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.fixed, // Mengubah behavior menjadi fixed
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void saveData(imageUrl) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('property');
    // Data yang ingin disimpan
    Map<String, dynamic> data = {
      "title": title,
      "image": imageUrl,
      "price": double.tryParse(_priceController.text) ?? 0.0,
      "cordinates":
          GeoPoint(currentPosition!.latitude, currentPosition!.longitude)
    };
    // Tambahkan data ke koleksi
    await collectionRef.add(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil disimpan'),
        duration: Duration(seconds: 2),
      ),
    );
    return Navigator.pop(context);
  }

  Future<Position> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }

  void _onMapCreated(HereMapController hereMapController) {
    hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
        (MapError? error) async {
      if (error != null) {
        print('Failed to load map: ${error.toString()}');
      }
      currentPosition = await _getCurrentLocation();
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
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Data'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul Input
            TextField(
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

            // Harga Input
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

            // Lokasi Map

            // Image Input
            ElevatedButton(
              onPressed: _selectImage,
              child: Text('Ambil Gambar dari Kamera'),
            ),

            SizedBox(height: 16.0),

            // Display Selected Image
            if (_imageFile != null)
              Image.file(
                File(_imageFile!.path),
                height: 200,
                width: 200,
              ),

            SizedBox(height: 16.0),

            // Tambah Data Button
            ElevatedButton(
              onPressed: submitText ? null : _uploadImage,
              child: submitText
                  ? CircularProgressIndicator()
                  : Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
