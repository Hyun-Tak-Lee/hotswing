enum PlayerRole{
  manager("manager"),
  user("user"),
  guest("guest");

  final String value;
  const PlayerRole(this.value);
}

enum PlayerSectionKind{
  unassigned("unassigned"),
  assigned("assigned"),
  drop("drop");

  final String value;
  const PlayerSectionKind(this.value);
}