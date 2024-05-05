import 'package:flutter/material.dart';
import 'package:livestream_player/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livestream Player',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}
