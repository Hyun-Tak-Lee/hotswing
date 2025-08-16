import 'package:flutter/foundation.dart';

class Player {
  String name;
  int rate;
  

  Player({required this.rate, required this.name});
}

class PlayersProvider with ChangeNotifier {
  final Map<String, Player> _players = {};

  PlayersProvider() {
    for (int i = 1; i <= 24; i++) {
      String playerName = 'Player $i';
      int playerRate = 1000 + ((i - 1) * 50);
      _players[playerName] = Player(name: playerName, rate: playerRate);
    }
  }

  Map<String, Player> get players => Map.unmodifiable(_players);

  // 새로운 플레이어 추가
  void addPlayer({required String name, required int rate}) {
    if (!_players.containsKey(name)) {
      Player newPlayer = Player(name: name, rate: rate);
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
    notifyListeners();
  }

  // 플레이어 리스트 반환
  List<String> getPlayers() {
    return _players.keys.toList();
  }
}
