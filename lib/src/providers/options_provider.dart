import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  bool _divideTeam = false;

  static const String _divideTeamKey = 'divideTeam'; // SharedPreferences 키

  bool get divideTeam => _divideTeam;

  // 생성자: OptionsProvider 객체가 생성될 때 _loadPreferences 호출
  OptionsProvider() {
    _loadPreferences();
  }

  // SharedPreferences에서 마지막으로 저장된 _divideTeam 값을 불러오는 메소드
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기 (비동기)
    // _divideTeamKey로 저장된 bool 값을 불러옴. 만약 값이 없으면(??) false를 기본값으로 사용
    _divideTeam = _prefs?.getBool(_divideTeamKey) ?? false;
    notifyListeners(); // 값이 로드되었음을 Provider를 구독하는 위젯들에게 알림
  }

  // 현재 _divideTeam 값을 SharedPreferences에 저장하는 메소드
  Future<void> _savePreferences() async {
    // _divideTeamKey를 사용하여 현재 _divideTeam 값을 bool 타입으로 저장 (비동기)
    await _prefs?.setBool(_divideTeamKey, _divideTeam);
  }

  // _divideTeam 값을 반전시키고, 변경된 값을 저장한 후, 구독 위젯들에게 알리는 메소드
  void toggleDivideTeam() {
    _divideTeam = !_divideTeam; // 현재 _divideTeam 값을 반전 (true -> false, false -> true)
    _savePreferences(); // 변경된 값을 SharedPreferences에 저장
    notifyListeners(); // 값이 변경되었음을 Provider를 구독하는 위젯들에게 알림
  }
}
