import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart'; // 공통 skill_utils.dart 파일 import

/// 플레이어 정보를 나타내는 클래스입니다.
class Player {
  String name;
  bool manager;
  int rate;
  String gender;
  int played;
  int waited;

  /// Player 객체를 생성합니다.
  Player({
    required this.rate,
    required this.manager,
    required this.name,
    required this.gender,
    required this.played,
    required this.waited,
  });

  /// 두 Player 객체가 동일한지 비교합니다. 이름이 같으면 동일한 것으로 간주합니다.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && name == other.name;

  /// Player 객체의 해시 코드를 반환합니다. 이름의 해시 코드를 사용합니다.
  @override
  int get hashCode => name.hashCode;
}

/// 플레이어 목록 및 코트 할당 상태를 관리하는 클래스입니다.
class PlayersProvider with ChangeNotifier {
  final Map<String, Player> _players = {};
  List<List<Player?>> _assignedPlayers = [];
  List<Player> _unassignedPlayers = [];
  final Random _random = Random();

  /// PlayersProvider 객체를 생성하고 초기 플레이어 데이터를 로드합니다.
  PlayersProvider() {
    final List<int> skillRates = skillLevelToRate.values.toList();

    for (int i = 1; i <= 24; i++) {
      String playerName = 'Player $i';
      bool manager = _random.nextBool();
      int playerRate = skillRates[_random.nextInt(skillRates.length)];
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

  /// SharedPreferences에서 초기 할당된 플레이어 섹션 수를 로드합니다.
  Future<void> _loadInitialAssignedPlayersCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int initialCount = prefs.getInt("numberOfSections") ?? 3;
    updateAssignedPlayersListCount(initialCount);
  }

  /// 모든 플레이어의 수정 불가능한 맵을 반환합니다.
  Map<String, Player> get players => Map.unmodifiable(_players);

  /// 새로운 플레이어를 추가합니다. 이미 존재하는 이름의 플레이어는 추가하지 않습니다.
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
  void removePlayer(String name) {
    if (_players.containsKey(name)) {
      Player? playerToRemove = _players[name];
      if (playerToRemove == null) return;
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

  /// 플레이어의 이름을 변경합니다. 기존 이름과 새 이름이 같거나 새 이름이 이미 존재하면 변경하지 않습니다.
  void updatePlayerName(String oldName, String newName) {
    if (oldName == newName) return;
    if (_players.containsKey(newName)) return;
    if (_players.containsKey(oldName)) {
      Player? player = _players.remove(oldName);
      if (player != null) {
        player.name = newName;
        _players[newName] = player;
        notifyListeners();
      }
    }
  }

  /// 모든 플레이어 정보를 초기화합니다.
  void clearPlayers() {
    _players.clear();
    _unassignedPlayers.clear();
    for (int i = 0; i < _assignedPlayers.length; i++) {
      _assignedPlayers[i] = [null, null, null, null];
    }
    notifyListeners();
  }

  /// 모든 플레이어의 목록을 played, waited 순으로 정렬하여 반환합니다.
  List<Player> getPlayers() {
    var playerList = _players.values.toList();
    playerList.sort((a, b) {
      int playedCompare = a.played.compareTo(b.played);
      if (playedCompare != 0) {
        return playedCompare;
      }
      return a.waited.compareTo(b.waited);
    });
    return playerList;
  }

  /// 할당된 플레이어 목록(코트)의 수를 업데이트합니다.
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

  /// 두 코트 위치에 있는 플레이어를 서로 교환합니다.
  void exchangePlayersInCourts({
    required int sectionIndex1,
    required int playerIndexInSection1,
    required int sectionIndex2,
    required int playerIndexInSection2,
  }) {
    if (sectionIndex1 < 0 ||
        sectionIndex1 >= _assignedPlayers.length ||
        playerIndexInSection1 < 0 ||
        playerIndexInSection1 >= _assignedPlayers[sectionIndex1].length ||
        sectionIndex2 < 0 ||
        sectionIndex2 >= _assignedPlayers.length ||
        playerIndexInSection2 < 0 ||
        playerIndexInSection2 >= _assignedPlayers[sectionIndex2].length) {
      return;
    }
    if (sectionIndex1 == sectionIndex2 &&
        playerIndexInSection1 == playerIndexInSection2) {
      return;
    }

    Player? player1 = _assignedPlayers[sectionIndex1][playerIndexInSection1];
    Player? player2 = _assignedPlayers[sectionIndex2][playerIndexInSection2];

    _assignedPlayers[sectionIndex1][playerIndexInSection1] = player2;
    _assignedPlayers[sectionIndex2][playerIndexInSection2] = player1;

    notifyListeners();
  }

  /// 미할당 플레이어와 코트의 특정 위치에 있는 플레이어를 교환합니다.
  void exchangeUnassignedPlayerWithCourtPlayer({
    required Player unassignedPlayerToAssign,
    required int targetCourtSectionIndex,
    required int targetCourtPlayerIndex,
  }) {
    if (targetCourtSectionIndex < 0 ||
        targetCourtSectionIndex >= _assignedPlayers.length ||
        targetCourtPlayerIndex < 0 ||
        targetCourtPlayerIndex >=
            _assignedPlayers[targetCourtSectionIndex].length) {
      return;
    }
    if (!_unassignedPlayers.contains(unassignedPlayerToAssign)) return;

    Player? playerCurrentlyInCourt =
        _assignedPlayers[targetCourtSectionIndex][targetCourtPlayerIndex];
    _assignedPlayers[targetCourtSectionIndex][targetCourtPlayerIndex] =
        unassignedPlayerToAssign;
    _unassignedPlayers.remove(unassignedPlayerToAssign);

    if (playerCurrentlyInCourt != null) {
      if (!_unassignedPlayers.contains(playerCurrentlyInCourt)) {
        _unassignedPlayers.add(playerCurrentlyInCourt);
      }
    }
    notifyListeners();
  }

  /// 특정 코트의 특정 위치에서 플레이어를 제거하고 미할당 목록에 추가합니다.
  void removePlayerFromCourt({
    required int sectionIndex,
    required int playerIndexInSection,
  }) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) return;
    if (playerIndexInSection < 0 ||
        playerIndexInSection >= _assignedPlayers[sectionIndex].length)
      return;

    Player? playerToRemove =
        _assignedPlayers[sectionIndex][playerIndexInSection];

    if (playerToRemove != null) {
      _assignedPlayers[sectionIndex][playerIndexInSection] = null;
      if (!_unassignedPlayers.contains(playerToRemove)) {
        _unassignedPlayers.add(playerToRemove);
      }
      notifyListeners();
    }
  }

  /// 미할당된 플레이어의 수정 불가능한 목록을 반환합니다.
  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  /// 코트에 할당된 플레이어들의 수정 불가능한 목록 (리스트의 리스트 형태)을 반환합니다.
  List<List<Player?>> get assignedPlayers =>
      List.unmodifiable(_assignedPlayers);
}
