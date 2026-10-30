import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/app/activation_app.dart';
import 'package:hotswing/src/app/main_app.dart';
import 'package:hotswing/src/providers/activation_provider.dart';

/// 활성화 상태에 따라 [ActivationApp] 또는 [MainApp]을 표시하는 루트 위젯.
///
/// 활성화가 완료되면 앱 재시작 없이 [MainApp]으로 전환됩니다.
class AppRoot extends StatelessWidget {
  /// [AppRoot] 생성자.
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final isActivated = context.watch<ActivationProvider>().isActivated;
    return isActivated ? const MainApp() : const ActivationApp();
  }
}
