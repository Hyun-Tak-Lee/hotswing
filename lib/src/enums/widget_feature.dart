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

/// 화면 방향 고정 모드 (0: 자동 회전, 1: 세로 고정, 2: 가로 고정).
enum ScreenOrientationMode {
  auto(0),
  portrait(1),
  landscape(2);

  final int value;
  const ScreenOrientationMode(this.value);

  static ScreenOrientationMode fromValue(int value) => switch (value) {
    1 => ScreenOrientationMode.portrait,
    2 => ScreenOrientationMode.landscape,
    _ => ScreenOrientationMode.auto,
  };
}
