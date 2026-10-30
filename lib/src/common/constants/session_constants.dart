/// 경기 세션(코트 배정·대기열) 영속화 관련 도메인 상수
abstract final class SessionConstants {
  /// 연속 변경 시 저장을 모으는 디바운스 시간
  static const Duration saveDebounceDuration = Duration(milliseconds: 300);

  /// 디바운스 중이라도 저장을 강제하는 최대 대기 시간
  static const Duration saveMaxWait = Duration(seconds: 1);

  /// 진행 코트별 선수 ID SharedPreferences 저장 키
  static const String assignedPlayersKey = 'assignedPlayers';

  /// 대기 코트별 선수 ID SharedPreferences 저장 키
  static const String standbyPlayersKey = 'standbyPlayers';

  /// 미배정 대기열 선수 ID SharedPreferences 저장 키
  static const String unassignedPlayersKey = 'unassignedPlayers';

  /// 세션 전체 선수 ID SharedPreferences 저장 키
  static const String playersKey = 'players';

  /// 코트별 경기 시작 시각 SharedPreferences 저장 키
  static const String courtStartTimesKey = 'courtStartTimes';

  /// 동반 그룹 사용자 지정 이름 SharedPreferences 저장 키
  static const String customGroupNamesKey = 'customGroupNames';
}
