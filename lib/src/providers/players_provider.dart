import 'dart:math';

import 'package:flutter/foundation.dart';

class Player {
  String name;
  bool manager;
  int rate;
  String gender;
  int played;
  int waited;

  Player({
    required this.rate,
    required this.manager,
    required this.name,
    required this.gender,
    required this.played,
    required this.waited,
  });
}

class PlayersProvider with ChangeNotifier {
  final Map<String, Player> _players = {};
  List<List<Player?>> _assignedPlayers = [];
  List<Player> _unassignedPlayers = [];
  final Random _random = Random();

  PlayersProvider() {
    for (int i = 1; i <= 24; i++) {
      String playerName = 'Player $i';
      bool manager = _random.nextBool();
      int playerRate = 1000 + ((i - 1) * 50);
      String gender = _random.nextBool() ? '남' : '여';
      int played = 0;
      int waited = 0;
      Player newPlayer = Player(
        name: playerName,
        manager: manager,
        rate: playerRate,
        gender: gender,
        played: played,
        waited: waited,
      );
      _players[playerName] = newPlayer;
      _unassignedPlayers.add(newPlayer);
    }
  }

  Map<String, Player> get players => Map.unmodifiable(_players);

  // 새로운 플레이어 추가
  void addPlayer({
    required String name,
    required bool manager, // Bool -> bool
    required int rate,
    required String gender,
    required int played,
    required int waited,
  }) {
    if (!_players.containsKey(name)) {
      Player newPlayer = Player(
        name: name,
        manager: manager,
        rate: rate,
        gender: gender,
        played: played,
        waited: waited,
      );
      _players[name] = newPlayer;
      _unassignedPlayers.add(newPlayer);
      notifyListeners();
    }
  }

  // 지정된 이름의 플레이어 제거
  void removePlayer(String name) {
    if (_players.containsKey(name)) {
      Player playerToRemove = _players[name]!;
      for (int i = 0; i < _assignedPlayers.length; i++) {
        for (int j = 0; j < _assignedPlayers[i].length; j++) {
          if (_assignedPlayers[i][j] == playerToRemove) {
            _assignedPlayers[i][j] = null;
          }
        }
      }
      _unassignedPlayers.remove(playerToRemove);
      _players.remove(name);
      notifyListeners();
    }
  }

  // 플레이어 이름 변경
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
    _unassignedPlayers.clear();
    _assignedPlayers.clear();
    notifyListeners();
  }

  // 플레이어 리스트 반환 (이름으로 정렬)
  List<Player> getPlayers() {
    var playerList = _players.values.toList();
    playerList.sort((a, b) => a.name.compareTo(b.name));
    return playerList;
  }

  // 할당되지 않은 플레이어 목록 반환 (읽기 전용)
  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);
}
