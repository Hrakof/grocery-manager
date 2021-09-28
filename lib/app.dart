import 'package:flutter/material.dart';
import 'package:projekt/screens/login/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Manager',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const LoginScreen(),
    );
  }
}