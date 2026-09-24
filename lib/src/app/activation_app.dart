import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/theme_provider.dart';
import 'package:hotswing/src/screens/activation/activation_screen.dart';
import 'package:hotswing/src/common/theme/app_theme.dart';

/// 미활성화 상태일 때 사용자에게 라이센스 인증 화면을 제공하는 루트 애플리케이션 위젯.
class ActivationApp extends StatelessWidget {
  /// [ActivationApp] 생성자.
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
