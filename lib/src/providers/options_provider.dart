import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  bool _divideTeam = false;
  int _numberOfSections = 3;
  double _skillWeight = 2.0;
  double _genderWeight = 2.5;
  double _waitedWeight = 1.0;
  double _playedWeight = 1.0;

  static const String _divideTeamKey = 'divideTeam';
  static const String _numberOfSectionsKey = 'numberOfSections';
  static const String _skillWeightKey = 'skillWeight';
  static const String _genderWeightKey = 'genderWeight';
  static const String _waitedWeightKey = 'waitedWeight';
  static const String _playedWeightKey = 'playedWeight';

  bool get divideTeam => _divideTeam;

  int get numberOfSections => _numberOfSections;

  double get skillWeight => _skillWeight;

  double get genderWeight => _genderWeight;

  double get waitedWeight => _waitedWeight;

  double get playedWeight => _playedWeight;

  // 생성자: OptionsProvider 객체가 생성될 때 _loadPreferences 호출
  OptionsProvider() {
    _loadPreferences();
  }

  // SharedPreferences에서 마지막으로 저장된 값들을 불러오는 메소드
  Future<void> _loadPreferences() async {
    _prefs =
        await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기 (비동기)
    _divideTeam = _prefs?.getBool(_divideTeamKey) ?? false;
    _numberOfSections = _prefs?.getInt(_numberOfSectionsKey) ?? 3;
    _skillWeight = _prefs?.getDouble(_skillWeightKey) ?? 2.0;
    _genderWeight = _prefs?.getDouble(_genderWeightKey) ?? 2.5;
    _waitedWeight = _prefs?.getDouble(_waitedWeightKey) ?? 1.0;
    _playedWeight = _prefs?.getDouble(_playedWeightKey) ?? 1.0;
    notifyListeners();
  }

  // 현재 값들을 SharedPreferences에 저장하는 메소드
  Future<void> _savePreferences() async {
    // _divideTeamKey를 사용하여 현재 _divideTeam 값을 bool 타입으로 저장 (비동기)
    await _prefs?.setBool(_divideTeamKey, _divideTeam);
    await _prefs?.setInt(_numberOfSectionsKey, _numberOfSections);
    await _prefs?.setDouble(_skillWeightKey, _skillWeight);
    await _prefs?.setDouble(_genderWeightKey, _genderWeight);
    await _prefs?.setDouble(_waitedWeightKey, _waitedWeight);
    await _prefs?.setDouble(_playedWeightKey, _playedWeight);
  }

  void toggleDivideTeam() {
    _divideTeam = !_divideTeam;
    _savePreferences();
    notifyListeners();
  }

  void setNumberOfSections(int newNumberOfSections) {
    _numberOfSections = newNumberOfSections;
    _savePreferences();
    notifyListeners();
  }

  void setSkillWeight(double newSkillWeight) {
    _skillWeight = newSkillWeight;
    _savePreferences();
    notifyListeners();
  }

  void setGenderWeight(double newGenderWeight) {
    _genderWeight = newGenderWeight;
    _savePreferences();
    notifyListeners();
  }

  void setWaitedWeight(double newWaitedWeight) {
    _waitedWeight = newWaitedWeight;
    _savePreferences();
    notifyListeners();
  }

  void setPlayedWeight(double newPlayedWeight) {
    _playedWeight = newPlayedWeight;
    _savePreferences();
    notifyListeners();
  }
}
