/// 앱 운영 옵션(코트 수, 매칭 가중치 등) 관련 도메인 상수
abstract final class OptionConstants {
  /// 진행 코트 수 기본값
  static const int defaultNumberOfSections = 3;

  /// 진행 코트 수 최소값
  static const int minNumberOfSections = 1;

  /// 진행 코트 수 최대값
  static const int maxNumberOfSections = 10;

  /// 매칭 가중치 기본값
  static const double defaultWeight = 1.0;

  /// 매칭 가중치 최소값
  static const double minWeight = 0.0;

  /// 매칭 가중치 최대값
  static const double maxWeight = 2.0;

  /// 매칭 가중치 슬라이더 구간 수 (0.1 단위)
  static const int weightDivisions = 20;

  /// 운영진 대기열 잔류 예약 기본값
  static const bool defaultReserveManager = true;

  /// 비활동 선수 정리 기준 일수 기본값
  static const int defaultInactiveDays = 90;

  /// 비활동 선수 정리 기준 일수 최소값
  static const int minInactiveDays = 30;

  /// 비활동 선수 정리 기준 일수 최대값
  static const int maxInactiveDays = 180;

  /// 비활동 선수 정리 기준 일수 슬라이더 단위 (일)
  static const int inactiveDaysStep = 5;

  /// 매칭 후보 무작위 풀 크기 기본값
  static const int defaultRandomPoolSize = 1;

  /// 매칭 후보 무작위 풀 크기 최소값
  static const int minRandomPoolSize = 1;

  /// 매칭 후보 무작위 풀 크기 최대값
  static const int maxRandomPoolSize = 5;

  /// 화면 상시 켜짐(Wakelock) 유지 기본값
  static const bool defaultKeepScreenOn = true;
}
