// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AddData extends StatelessWidget {
//   final TextEditingController nameC = TextEditingController();
//   final TextEditingController ketC = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     CollectionReference property = firestore.collection('property');

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tambah Data'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: nameC,
//               decoration: const InputDecoration(
//                 labelText: "Nama",
//               ),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               controller: ketC,
//               decoration: const InputDecoration(
//                 labelText: "Keterangan",
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 property.add({
//                   'name': nameC.text,
//                   'ket': ketC.text,
//                 });

//                 nameC.text = '';
//                 ketC.text = '';
//               },
//               child: const Text('Tambah'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
