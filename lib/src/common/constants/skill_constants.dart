/// 배드민턴 실력 등급 관련 도메인 상수
abstract final class SkillConstants {
  /// 실력 등급과 기준 레이팅(점수) 간의 매핑 테이블 (낮은 등급부터 오름차순)
  static const Map<String, int> levelToRate = {
    '초심': 0,
    '초심+': 500,
    'D': 1000,
    'D+': 1500,
    'C': 2000,
    'B': 3000,
    'A': 4000,
    'S': 5000,
  };
}
