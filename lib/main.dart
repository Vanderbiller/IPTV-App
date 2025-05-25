import 'package:flutter/material.dart';
import 'package:sample_app/screens/profile_screen.dart';

void main() {
  runApp(const MyIPTVApp());
}

class MyIPTVApp extends StatelessWidget {
  const MyIPTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPTV Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      home: const ProfileScreen(),
    );
  }
}