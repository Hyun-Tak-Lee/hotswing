import 'package:flutter/material.dart';
import 'package:hotswing/src/screens/home/home_screen.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matching',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB0E0E6)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
