import 'package:flutter/material.dart';
import 'home_screen.dart';

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
      home: HomeScreen(),
    );
  }
}