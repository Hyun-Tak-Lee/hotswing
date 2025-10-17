import 'package:flutter/material.dart';
import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/repository/realms/options.dart';
import 'package:realm/realm.dart';


class OptionsProvider with ChangeNotifier {
  late Realm _realm;
  late Options _options;

  static const int _minNumberOfSections = 1;
  static const int _maxNumberOfSections = 10;
  static const double _minWeight = 0.0;
  static const double _maxWeight = 2.0;

  int get numberOfSections => _options.numberOfSections;
  double get skillWeight => _options.skillWeight;
  double get genderWeight => _options.genderWeight;
  double get waitedWeight => _options.waitedWeight;
  double get playedWeight => _options.playedWeight;
  double get playedWithWeight => _options.playedWithWeight;

  OptionsProvider() {
    _loadOptions();
  }

  @override
  void dispose() {
    _realm.close();
    super.dispose();
  }

  void _loadOptions() {
    OptionsRepository options_repository = OptionsRepository.instance;
    _options = options_repository.getOptions();

    notifyListeners();
  }

  void setNumberOfSections(int newNumberOfSections) {
    _realm.write(() {
      _options.numberOfSections = newNumberOfSections.clamp(
        _minNumberOfSections,
        _maxNumberOfSections,
      );
    });
    notifyListeners();
  }

  void setSkillWeight(double newSkillWeight) {
    _realm.write(() {
      _options.skillWeight = newSkillWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }

  void setGenderWeight(double newGenderWeight) {
    _realm.write(() {
      _options.genderWeight = newGenderWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }

  void setWaitedWeight(double newWaitedWeight) {
    _realm.write(() {
      _options.waitedWeight = newWaitedWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }

  void setPlayedWeight(double newPlayedWeight) {
    _realm.write(() {
      _options.playedWeight = newPlayedWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }

  void setPlayedWithWeight(double newPlayedWithWeight) {
    _realm.write(() {
      _options.playedWithWeight =
          newPlayedWithWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }
}
