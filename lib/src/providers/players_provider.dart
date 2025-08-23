import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _loadInitialAssignedPlayersCount();
  }

  Future<void> _loadInitialAssignedPlayersCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int initialCount = prefs.getInt("numberOfSections") ?? 3;
    updateAssignedPlayersListCount(initialCount);
  }

  Map<String, Player> get players => Map.unmodifiable(_players);

  void addPlayer({
    required String name,
    required bool manager,
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

  void clearPlayers() {
    _players.clear();
    _unassignedPlayers.clear();
    for (final list in _assignedPlayers) {
      list.clear();
    }
    notifyListeners();
  }

  List<Player> getPlayers() {
    var playerList = _players.values.toList();
    playerList.sort((a, b) => a.name.compareTo(b.name));
    return playerList;
  }

  void updateAssignedPlayersListCount(int newCount) {
    if (newCount < 0) {
      return;
    }

    int currentCount = _assignedPlayers.length;

    if (newCount < currentCount) {
      for (int i = newCount; i < currentCount; i++) {
        List<Player?> playersInList = _assignedPlayers[i];
        for (Player? player in playersInList) {
          if (player != null) {
            _unassignedPlayers.add(player);
          }
        }
      }
      _assignedPlayers.removeRange(newCount, currentCount);
    } else if (newCount > currentCount) {
      for (int i = 0; i < newCount - currentCount; i++) {
        _assignedPlayers.add([]);
      }
    }
    notifyListeners();
  }

  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  List<List<Player?>> get assignedPlayers =>
      List.unmodifiable(_assignedPlayers);
}
