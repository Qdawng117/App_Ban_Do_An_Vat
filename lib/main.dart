import 'package:demoflutter_221402/models/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'models/widgets/Layout.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}
