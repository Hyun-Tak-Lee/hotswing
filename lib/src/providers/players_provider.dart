import 'dart:math';

import 'package:flutter/foundation.dart';

class Player {
  String name;
  int rate;
  String gender;
  int played;

  Player({
    required this.rate,
    required this.name,
    required this.gender,
    required this.played,
  });
}

class PlayersProvider with ChangeNotifier {
  final Map<String, Player> _players = {};
  final Random _random = Random();

  PlayersProvider() {
    for (int i = 1; i <= 24; i++) {
      String playerName = 'Player $i';
      int playerRate = 1000 + ((i - 1) * 50);
      String gender = _random.nextBool() ? '남' : '여';
      int attempts = 0;
      _players[playerName] = Player(
        name: playerName,
        rate: playerRate,
        gender: gender,
        played: attempts,
      );
    }
  }

  Map<String, Player> get players => Map.unmodifiable(_players);

  // 새로운 플레이어 추가
  void addPlayer({
    required String name,
    required int rate,
    required String gender,
    required int played,
  }) {
    if (!_players.containsKey(name)) {
      Player newPlayer = Player(name: name, rate: rate, gender: gender, played: played);
      _players[name] = newPlayer;
      notifyListeners();
    }
  }

  // 지정된 이름의 플레이어 제거
  void removePlayer(String name) {
    if (_players.containsKey(name)) {
      _players.remove(name);
      notifyListeners();
    }
  }

  // 플레이어 이름 변경 (성별은 이름 변경과 직접적인 관련이 없으므로 이 함수는 수정할 필요가 없습니다)
  void updatePlayerName(String oldName, String newName) {
    if (_players.containsKey(oldName)) {
      Player? player = _players.remove(oldName);
      if (player != null) {
        player.name = newName;
        _players[newName] = player;
        notifyListeners();
      }
    }
  }

  // 모든 플레이어 제거
  void clearPlayers() {
    _players.clear();
    notifyListeners();
  }

  // 플레이어 리스트 반환 (이름으로 정렬)
  List<Player> getPlayers() {
    var playerList = _players.values.toList();
    playerList.sort((a, b) => a.name.compareTo(b.name));
    return playerList;
  }
}
