class Player {
  final int id;
  String name;
  String role;
  int rate;
  String gender;
  int played;
  int waited;
  int lated;
  Map<int, int> gamesPlayedWith;

  Player({
    required this.id,
    required this.rate,
    required this.role,
    required String name,
    required this.gender,
    required this.played,
    required this.waited,
    required this.lated,
    Map<int, int>? gamesPlayedWith,
  }) : this.name = name.length > 7 ? name.substring(0, 7) : name,
        this.gamesPlayedWith = gamesPlayedWith ?? {};

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'rate': rate,
    'gender': gender,
    'played': played,
    'waited': waited,
    'lated': lated,
    'gamesPlayedWith': gamesPlayedWith.map(
          (key, value) => MapEntry(key.toString(), value),
    ),
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as int,
    name: json['name'] as String,
    role: json['role'] as String,
    rate: json['rate'] as int,
    gender: json['gender'] as String,
    played: json['played'] as int? ?? 0,
    waited: json['waited'] as int? ?? 0,
    lated: json['lated'] as int? ?? 0,
    gamesPlayedWith:
    (json['gamesPlayedWith'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(int.parse(key), value as int),
    ) ??
        {},
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}