/// 대기열 플레이어 정렬 기준 (게임 수/대기 수 기준 또는 이름순).
enum SortCriterion {
  played,
  name,
}

/// 코트 화면에서 표시할 뷰 섹션 종류 (진행 코트 뷰 또는 대기 코트 뷰).
enum CourtViewSection {
  assignedView,
  standbyView,
}