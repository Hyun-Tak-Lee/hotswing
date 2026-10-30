import 'package:flutter/material.dart';

/// 기기 활성화 여부를 보관하고, 활성화 완료 시 루트 앱 전환을 알리는 프로바이더.
class ActivationProvider with ChangeNotifier {
  bool _isActivated;

  /// 앱 시작 시 기기 검증 결과([isActivated])로 초기 상태를 설정합니다.
  ActivationProvider({required bool isActivated}) : _isActivated = isActivated;

  /// 현재 기기가 활성화되어 있는지 여부.
  bool get isActivated => _isActivated;

  /// 활성화 완료 상태로 전환하여 앱 재시작 없이 메인 화면을 표시합니다.
  void markActivated() {
    if (_isActivated) return;
    _isActivated = true;
    notifyListeners();
  }
}
