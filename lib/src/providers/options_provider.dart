import 'package:flutter/material.dart';
import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/repository/realms/options.dart';
import 'package:realm/realm.dart';

/// 앱 운영 옵션(코트 수, 매칭 가중치, 매니저 예약 등)을 관리하고 변경 사항을 전파하는 프로바이더.
class OptionsProvider with ChangeNotifier {
  static const int _minNumberOfSections = 1;
  static const int _maxNumberOfSections = 10;
  static const double _minWeight = 0.0;
  static const double _maxWeight = 2.0;
  static const int _minInactiveDays = 30;
  static const int _maxInactiveDays = 180;
  static const int _minRandomPoolSize = 1;
  static const int _maxRandomPoolSize = 5;

  late Realm _realm;
  late Options _options;

  /// [OptionsProvider] 생성자. 저장소로부터 옵션 값을 불러옵니다.
  OptionsProvider() {
    _loadOptions();
  }

  /// 활성화된 진행 코트 수.
  int get numberOfSections => _options.numberOfSections;

  /// 실력 차이에 따른 가중치.
  double get skillWeight => _options.skillWeight;

  /// 성별 구성 매칭 가중치.
  double get genderWeight => _options.genderWeight;

  /// 대기 시간에 따른 매칭 우선순위 가중치.
  double get waitedWeight => _options.waitedWeight;

  /// 경기 횟수에 따른 매칭 감점 가중치.
  double get playedWeight => _options.playedWeight;

  /// 기 매칭 플레이어와의 중복 매칭 방지 가중치.
  double get playedWithWeight => _options.playedWithWeight;

  /// 매니저 최소 1명 대기열 잔류 예약 여부.
  bool get reserveManager => _options.reserveManager;

  /// 비활동 선수 자동 정리 기준 일수.
  int get inactiveDaysThreshold => _options.inactiveDaysThreshold;

  /// 매칭 시 최상위 후보군 무작위 풀 크기.
  int get randomPoolSize => _options.randomPoolSize;

  /// 진행 코트 수를 변경합니다.
  void setNumberOfSections(int newNumberOfSections) {
    _realm.write(() {
      _options.numberOfSections = newNumberOfSections.clamp(
        _minNumberOfSections,
        _maxNumberOfSections,
      );
    });
    notifyListeners();
  }

  /// 실력 가중치를 변경합니다.
  void setSkillWeight(double newSkillWeight) {
    _realm.write(() {
      _options.skillWeight = newSkillWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }

  /// 성별 가중치를 변경합니다.
  void setGenderWeight(double newGenderWeight) {
    _realm.write(() {
      _options.genderWeight = newGenderWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }

  /// 대기 시간 가중치를 변경합니다.
  void setWaitedWeight(double newWaitedWeight) {
    _realm.write(() {
      _options.waitedWeight = newWaitedWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }

  /// 경기 수 가중치를 변경합니다.
  void setPlayedWeight(double newPlayedWeight) {
    _realm.write(() {
      _options.playedWeight = newPlayedWeight.clamp(_minWeight, _maxWeight);
    });
    notifyListeners();
  }

  /// 중복 매칭 방지 가중치를 변경합니다.
  void setPlayedWithWeight(double newPlayedWithWeight) {
    _realm.write(() {
      _options.playedWithWeight = newPlayedWithWeight.clamp(
        _minWeight,
        _maxWeight,
      );
    });
    notifyListeners();
  }

  /// 매니저 예약 옵션 활성화 여부를 변경합니다.
  void setReserveManager(bool newValue) {
    _realm.write(() {
      _options.reserveManager = newValue;
    });
    notifyListeners();
  }

  /// 비활동 회원 정리 기준 일수를 변경합니다.
  void setInactiveDaysThreshold(int newValue) {
    _realm.write(() {
      _options.inactiveDaysThreshold = newValue.clamp(
        _minInactiveDays,
        _maxInactiveDays,
      );
    });
    notifyListeners();
  }

  /// 최상위 매칭 후보 풀 크기를 변경합니다.
  void setRandomPoolSize(int newValue) {
    _realm.write(() {
      _options.randomPoolSize = newValue.clamp(
        _minRandomPoolSize,
        _maxRandomPoolSize,
      );
    });
    notifyListeners();
  }

  // ==========================================
  // Private Helper Methods
  // ==========================================

  void _loadOptions() {
    OptionsRepository optionsRepository = OptionsRepository.instance;
    _realm = optionsRepository.realm;
    _options = optionsRepository.getOptions();

    notifyListeners();
  }
}
