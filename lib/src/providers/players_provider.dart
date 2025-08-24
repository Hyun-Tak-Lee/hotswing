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

  /// PlayersProvider 생성자입니다.
  /// 초기 플레이어 목록을 생성하고 저장된 섹션 수를 불러옵니다.
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

  /// SharedPreferences에서 초기 할당된 플레이어 목록(코트 섹션) 수를 로드합니다.
  Future<void> _loadInitialAssignedPlayersCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int initialCount = prefs.getInt("numberOfSections") ?? 3;
    updateAssignedPlayersListCount(initialCount);
  }

  /// 모든 플레이어의 수정 불가능한 맵을 반환합니다.
  Map<String, Player> get players => Map.unmodifiable(_players);

  /// 새 플레이어를 추가합니다. 플레이어 이름이 이미 존재하면 추가하지 않습니다.
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

  /// 지정된 이름의 플레이어를 제거합니다.
  /// 할당된 코트 및 미할당 목록에서도 플레이어를 제거합니다.
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

  /// 플레이어의 이름을 업데이트합니다.
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

  /// 모든 플레이어, 미할당된 플레이어, 할당된 코트의 플레이어를 지웁니다.
  void clearPlayers() {
    _players.clear();
    _unassignedPlayers.clear();
    for (int i = 0; i < _assignedPlayers.length; i++) {
      _assignedPlayers[i] = [null, null, null, null];
    }
    notifyListeners();
  }

  /// 모든 플레이어의 목록을 이름순으로 정렬하여 반환합니다.
  List<Player> getPlayers() {
    var playerList = _players.values.toList();
    playerList.sort((a, b) => a.name.compareTo(b.name));
    return playerList;
  }

  /// 할당된 플레이어 목록(코트 섹션)의 수를 업데이트합니다.
  /// 수가 줄어들면 제거된 목록의 플레이어는 미할당 목록으로 이동합니다.
  /// 수가 늘어나면 새 빈 목록이 추가됩니다.
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
        _assignedPlayers.add([null, null, null, null]);
      }
    }
    notifyListeners();
  }

  /// 플레이어를 특정 코트의 특정 위치에 할당합니다.
  /// 해당 위치에 이미 플레이어가 있는 경우, 기존 플레이어는 미할당 목록으로 이동하고 새 플레이어가 그 자리를 차지합니다.
  /// 해당 위치가 비어있는 경우, 새 플레이어가 추가됩니다.
  void swapPlayer({
    required Player playerToAssign,
    required int sectionIndex,
    required int playerIndexInSection,
  }) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) {
      return;
    }
    if (playerIndexInSection < 0 ||
        playerIndexInSection >= _assignedPlayers[sectionIndex].length) {
      return;
    }

    Player? currentAssignedPlayer =
        _assignedPlayers[sectionIndex][playerIndexInSection];

    if (currentAssignedPlayer == null) {
      // 코트에 플레이어 추가
      _unassignedPlayers.remove(playerToAssign);
      _assignedPlayers[sectionIndex][playerIndexInSection] = playerToAssign;
    } else {
      // 플레이어 교환
      _unassignedPlayers.remove(playerToAssign);
      _unassignedPlayers.add(currentAssignedPlayer);
      _assignedPlayers[sectionIndex][playerIndexInSection] = playerToAssign;
    }
    notifyListeners();
  }

  /// 특정 코트의 특정 위치에서 플레이어를 제거하고 미할당 목록에 추가합니다.
  void removePlayerFromCourt({
    required int sectionIndex,
    required int playerIndexInSection,
  }) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) {
      return;
    }
    if (playerIndexInSection < 0 ||
        playerIndexInSection >= _assignedPlayers[sectionIndex].length) {
      return;
    }

    Player? playerToRemove =
        _assignedPlayers[sectionIndex][playerIndexInSection];

    if (playerToRemove != null) {
      _assignedPlayers[sectionIndex][playerIndexInSection] = null;
      _unassignedPlayers.add(playerToRemove);
      notifyListeners();
    }
  }

  /// 미할당된 플레이어의 수정 불가능한 목록을 반환합니다.
  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  /// 코트에 할당된 플레이어들의 수정 불가능한 목록 (리스트의 리스트 형태)을 반환합니다.
  List<List<Player?>> get assignedPlayers =>
      List.unmodifiable(_assignedPlayers);
}
