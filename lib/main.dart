import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project/views/home.dart';
import 'package:project/views/login.dart';
import 'firebase_options.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/core.engine.dart';
import 'package:here_sdk/core.errors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
_initializeHERESDK();
  runApp(MyApp());
}
void _initializeHERESDK() async {
  // Needs to be called before accessing SDKOptions to load necessary libraries.
  SdkContext.init(IsolateOrigin.main);

  // Set your credentials for the HERE SDK.
  String accessKeyId = "ESv8lXTQMd7OHbiCDAvN4w";
  String accessKeySecret = "5cHS-OPHx2udsqEMOnlM76kWl5O2qkBS1BXWgLYOkRWLZaY3NJCByJnSX012ymnsp3qVeb-ZvwCLk0uqyCFwQw";
  SDKOptions sdkOptions = SDKOptions.withAccessKeySecret(accessKeyId, accessKeySecret);

  try {
    await SDKNativeEngine.makeSharedInstance(sdkOptions);
  } on InstantiationException {
    throw Exception("Failed to initialize the HERE SDK.");
  }
}
class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: 
      false,
      home: FutureBuilder<User?>(
        future: Future(() async {
          return _auth.currentUser;
        }),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading"); // Show a loading screen while checking the login status
          } else {
            if (snapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                // Replace the current route with the home screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => HomePage()),
                );
              });
            } else {
              return LoginScreen(); // User is not logged in, show the login page
            }
          }
          return Container(); // Return an empty container by default
        },
      ),
    );
  }
}