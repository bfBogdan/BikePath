import 'package:bikepath/firebase_options.dart';
import 'package:bikepath/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const black = Color.fromARGB(255, 41, 47, 51);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BikePath',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const Home(),
    );
  }
}