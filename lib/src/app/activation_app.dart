import 'package:flutter/material.dart';
import 'package:hotswing/src/screens/activation/activation_screen.dart';

/// 활성화 앱 (비밀번호 입력 화면)
class ActivationApp extends StatelessWidget {
  const ActivationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '앱 활성화',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB0E0E6)),
        useMaterial3: true,
      ),
      home: const ActivationScreen(),
    );
  }
}
