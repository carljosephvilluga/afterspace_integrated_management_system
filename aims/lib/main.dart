import 'package:flutter/material.dart';
import 'screens/login/admin_login_screen.dart'; // or manager/staff depending on which you want first

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AfterSpace',
      debugShowCheckedModeBanner: false,
      home: const AdminLoginScreen(), // start directly at Admin login
    );
  }
}