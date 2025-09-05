import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OptionsProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  bool _divideTeam = false;
  int _numberOfSections = 3;
  double _skillWeight = 1.0;
  double _genderWeight = 1.0;
  double _waitedWeight = 1.0;
  double _playedWeight = 1.0;
  double _playedWithWeight = 1.0;

  static const String _divideTeamKey = 'divideTeam';
  static const String _numberOfSectionsKey = 'numberOfSections';
  static const String _skillWeightKey = 'skillWeight';
  static const String _genderWeightKey = 'genderWeight';
  static const String _waitedWeightKey = 'waitedWeight';
  static const String _playedWeightKey = 'playedWeight';
  static const String _playedWithWeightKey = 'playedWithWeight';

  static const int _minNumberOfSections = 1;
  static const int _maxNumberOfSections = 8;
  static const double _minWeight = 0.0;
  static const double _maxWeight = 2.0;

  bool get divideTeam => _divideTeam;

  int get numberOfSections => _numberOfSections;

  double get skillWeight => _skillWeight;

  double get genderWeight => _genderWeight;

  double get waitedWeight => _waitedWeight;

  double get playedWeight => _playedWeight;

  double get playedWithWeight => _playedWithWeight;

  OptionsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _divideTeam = _prefs?.getBool(_divideTeamKey) ?? false;
    _numberOfSections = (_prefs?.getInt(_numberOfSectionsKey) ?? 3).clamp(
      _minNumberOfSections,
      _maxNumberOfSections,
    );
    _skillWeight = (_prefs?.getDouble(_skillWeightKey) ?? 1.0).clamp(
      _minWeight,
      _maxWeight,
    );
    _genderWeight = (_prefs?.getDouble(_genderWeightKey) ?? 1.0).clamp(
      _minWeight,
      _maxWeight,
    );
    _waitedWeight = (_prefs?.getDouble(_waitedWeightKey) ?? 1.0).clamp(
      _minWeight,
      _maxWeight,
    );
    _playedWeight = (_prefs?.getDouble(_playedWeightKey) ?? 1.0).clamp(
      _minWeight,
      _maxWeight,
    );
    _playedWithWeight = (_prefs?.getDouble(_playedWithWeightKey) ?? 1.0).clamp(
      _minWeight,
      _maxWeight,
    );
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
    await _prefs?.setDouble(_playedWithWeightKey, _playedWithWeight);
  }

  void toggleDivideTeam() {
    _divideTeam = !_divideTeam;
    _savePreferences();
    notifyListeners();
  }

  void setNumberOfSections(int newNumberOfSections) {
    _numberOfSections = newNumberOfSections.clamp(
      _minNumberOfSections,
      _maxNumberOfSections,
    );
    _savePreferences();
    notifyListeners();
  }

  void setSkillWeight(double newSkillWeight) {
    _skillWeight = newSkillWeight.clamp(_minWeight, _maxWeight);
    _savePreferences();
    notifyListeners();
  }

  void setGenderWeight(double newGenderWeight) {
    _genderWeight = newGenderWeight.clamp(_minWeight, _maxWeight);
    _savePreferences();
    notifyListeners();
  }

  void setWaitedWeight(double newWaitedWeight) {
    _waitedWeight = newWaitedWeight.clamp(_minWeight, _maxWeight);
    _savePreferences();
    notifyListeners();
  }

  void setPlayedWeight(double newPlayedWeight) {
    _playedWeight = newPlayedWeight.clamp(_minWeight, _maxWeight);
    _savePreferences();
    notifyListeners();
  }

  void setPlayedWithWeight(double newPlayedWithWeight) {
    _playedWithWeight = newPlayedWithWeight.clamp(_minWeight, _maxWeight);
    _savePreferences();
    notifyListeners();
  }
}
