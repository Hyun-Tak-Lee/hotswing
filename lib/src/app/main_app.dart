import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/theme_provider.dart';
import 'package:hotswing/src/screens/main/main_wrapper.dart';
import 'package:hotswing/src/common/theme/app_theme.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Matching',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: const MainWrapper(),
    );
  }
}

