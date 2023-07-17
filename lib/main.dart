import 'package:flutter/material.dart';
import 'package:to_do/screens/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Taskmanagers',
      home: Home(),
    );
  }
}
