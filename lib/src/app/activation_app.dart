import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/theme_provider.dart';
import 'package:hotswing/src/screens/activation/activation_screen.dart';
import 'package:hotswing/src/common/theme/app_theme.dart';

/// 활성화 앱 (비밀번호 입력 화면)
class ActivationApp extends StatelessWidget {
  const ActivationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: '앱 활성화',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: const ActivationScreen(),
    );
  }
}

