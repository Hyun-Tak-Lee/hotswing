/// 자동 매칭 알고리즘의 점수 계산 관련 도메인 상수
///
/// 각 점수는 서로 경합하도록 균형이 맞춰져 있으므로, 값을 조정할 때는 연관 항목의 설명을 함께 확인하세요.
abstract final class MatchingConstants {
  // ==========================================
  // 페어(2인) 점수
  // ==========================================

  /// 페어 실력 점수의 레이팅 차이 정규화 기준
  ///
  /// 레이팅 차이가 이 값만큼 나면 실력 점수가 1점 감소합니다.
  static const double pairRateDiffScale = 1000.0;

  /// 같은 성별 페어 가산점 (동성 페어를 우선 결성)
  static const double sameGenderPairBonus = 5.0;

  /// 대기 1턴당 가산점
  static const double waitedScorePerTurn = 0.2;

  /// 경기(지각 포함) 1회당 감점
  static const double playedPenaltyPerGame = 0.25;

  /// 같은 상대와 함께 경기한 1회당 페어 점수 감점
  static const double pairPlayedWithPenalty = 0.2;

  /// 레이팅 순 정렬 후 페어 후보를 탐색할 인접 선수 범위
  static const int pairSearchRange = 20;

  // ==========================================
  // 코트(2:2) 구성 점수
  // ==========================================

  /// 혼복 vs 혼복 코트 보너스
  ///
  /// 동성 페어 가산점([sameGenderPairBonus]) 차이를 넘어 혼복 코트가 우선 구성되도록 충분히 큰 값을 사용합니다.
  static const double mixedDoublesCourtBonus = 16.0;

  /// 혼복 vs 동성처럼 성별 구성이 어긋난 코트 감점
  static const double unbalancedGenderCourtPenalty = 16.0;

  /// 동성 팀끼리의 코트 구성 보너스 최대치 (성별 가중치에 비례)
  ///
  /// 작을수록 코트 성비 점수가 대기 1~2턴 차이 등과 유연하게 경합합니다.
  static const double sameGenderCourtMaxBonus = 4.0;

  /// 팀 평균 레이팅 차이 감점의 정규화 기준
  ///
  /// 작을수록 레이팅 차이에 대한 감점이 빨리 커집니다.
  static const double teamRateDiffScale = 1000.0;

  /// 상대팀 선수와 함께 경기한 1회당 감점 (중복 매칭 방지 가중치에 비례)
  static const double opponentPlayedWithPenalty = 0.25;

  // ==========================================
  // 운영진 대기 예약
  // ==========================================

  /// 대기열에 남길 운영진 선정 시 대기 1턴당 감점 계수
  static const double managerReserveWaitedFactor = 0.15;
}
