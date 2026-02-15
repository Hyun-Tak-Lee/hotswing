enum PlayerRole {
  manager("manager", "매니저"),
  user("user", "회원"),
  guest("guest", "게스트");

  final String value;
  final String label;
  const PlayerRole(this.value, this.label);
}

enum PlayerSectionKind {
  unassigned("unassigned"),
  assigned("assigned"),
  standby("standby"),
  drop("drop");

  final String value;
  const PlayerSectionKind(this.value);
}
