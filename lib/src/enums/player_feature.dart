/// 플레이어의 역할 구분 (매니저, 회원, 게스트).
enum PlayerRole {
  manager("manager", "매니저"),
  user("user", "회원"),
  guest("guest", "게스트");

  final String value;
  final String label;
  const PlayerRole(this.value, this.label);
}

/// 플레이어의 성별 구분 (남성, 여성).
enum PlayerGender {
  male("남", "남성"),
  female("여", "여성");

  final String value;
  final String label;
  const PlayerGender(this.value, this.label);
}

/// 코트 및 대기 화면 내 플레이어가 위치하는 섹션 종류.
enum PlayerSectionKind {
  unassigned("unassigned"),
  assigned("assigned"),
  standby("standby"),
  drop("drop");

  final String value;
  const PlayerSectionKind(this.value);
}
