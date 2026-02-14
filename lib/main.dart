import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:hotswing/src/services/activation_service.dart';
import 'package:hotswing/src/app/activation_app.dart';
import 'package:hotswing/src/app/main_app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // SharedPreferences 초기화
  await SharedProvider().init();

  // 활성화 서비스 초기화 (자동 활성화 안 함)
  final activationService = ActivationService();
  final isActivated = activationService.isActivated();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayersProvider()),
        ChangeNotifierProvider(create: (_) => OptionsProvider()),
      ],
      child: isActivated ? const MainApp() : const ActivationApp(),
    ),
  );
}
