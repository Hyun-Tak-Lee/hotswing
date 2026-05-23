import 'package:flutter/material.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';

/// 애플리케이션의 테마 모드(시스템, 라이트, 다크)를 관리하고 유지합니다.
class ThemeProvider with ChangeNotifier {
  static const String _keyThemeMode = 'theme_mode';
  final SharedProvider _sharedProvider = SharedProvider();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  /// 로컬 저장소(SharedPreferences)로부터 설정값을 불러옵니다.
  Future<void> _loadThemeMode() async {
    try {
      final String? themeStr = await _sharedProvider.getString(_keyThemeMode);
      if (themeStr != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.name == themeStr,
          orElse: () => ThemeMode.system,
        );
        notifyListeners();
      }
    } catch (_) {
      // 로드 실패 시 기본값 유지
    }
  }

  /// 새로운 테마 모드를 설정하고 비동기로 저장합니다.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      await _sharedProvider.saveString(_keyThemeMode, mode.name);
    } catch (_) {
      // 저장 실패 로그 처리 등을 추가할 수 있습니다.
    }
  }
}
