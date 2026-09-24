import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/theme_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/services/system/activation_service.dart';
import 'package:hotswing/src/app/activation_app.dart';
import 'package:hotswing/src/app/main_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 애플리케이션 진입점 함수. 바인딩 초기화, 환경 변수 로드, 기기 활성화 검증 후 앱을 구동합니다.
void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // 활성화 서비스 초기화 및 기기 검증 (보안 강화)
  final activationService = ActivationService();
  final isActivated = await activationService.verifyDevice();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PlayersProvider()),
        ChangeNotifierProvider(create: (_) => OptionsProvider()),
      ],
      child: isActivated ? const MainApp() : const ActivationApp(),
    ),
  );
}
