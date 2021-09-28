import 'package:flutter/material.dart';
import 'package:projekt/screens/login/login_screen.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Manager',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: const LoginScreen(),
    );
  }
}