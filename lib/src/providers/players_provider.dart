import 'dart:convert'; // Import for jsonEncode
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart';

class Player {
  String name;
  bool manager;
  int rate;
  String gender;
  int played;
  int waited;

  // Player 객체를 생성합니다.
  Player({
    required this.rate,
    required this.manager,
    required String name,
    required this.gender,
    required this.played,
    required this.waited,
  }) : this.name = name.length > 7 ? name.substring(0, 7) : name;

  // Add this method to convert Player to Map
  Map<String, dynamic> toJson() => {
    'name': name,
    'manager': manager,
    'rate': rate,
    'gender': gender,
    'played': played,
    'waited': waited,
  };

  // Add this factory constructor to create Player from Map (for loading later)
  factory Player.fromJson(Map<String, dynamic> json) => Player(
    name: json['name'],
    manager: json['manager'],
    rate: json['rate'],
    gender: json['gender'],
    played: json['played'],
    waited: json['waited'],
  );

  // 두 Player 객체가 동일한지 비교합니다. 이름이 같으면 동일한 것으로 간주합니다.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && name == other.name;

  // Player 객체의 해시 코드를 반환합니다. 이름의 해시 코드를 사용합니다.
  @override
  int get hashCode => name.hashCode;
}

// 플레이어 목록 및 코트 할당 상태를 관리하는 클래스입니다.
class PlayersProvider with ChangeNotifier {
  final Map<String, Player> _players = {};
  List<List<Player?>> _assignedPlayers = [];
  List<Player> _unassignedPlayers = [];
  final Random _random = Random();

  // PlayersProvider 객체를 생성하고 초기 플레이어 데이터를 로드합니다.
  PlayersProvider() {
    // final List<int> skillRates = skillLevelToRate.values.toList();
    //
    // for (int i = 1; i <= 24; i++) {
    //   String playerName = '플레이어 $i';
    //   bool manager = _random.nextBool();
    //   int playerRate = skillRates[_random.nextInt(skillRates.length)];
    //   String gender = _random.nextBool() ? '남' : '여';
    //   int played = 0;
    //   int waited = 0;
    //   Player newPlayer = Player(
    //     name: playerName,
    //     manager: manager,
    //     rate: playerRate,
    //     gender: gender,
    //     played: played,
    //     waited: waited,
    //   );
    //   _players[playerName] = newPlayer;
    //   _unassignedPlayers.add(newPlayer);
    // }
    _loadInitialAssignedPlayersCount();
    _loadPlayersFromPrefs();
  }

  // SharedPreferences에서 초기 할당된 플레이어 섹션 수를 로드합니다.
  Future<void> _loadInitialAssignedPlayersCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int initialCount = prefs.getInt("numberOfSections") ?? 3;
    updateAssignedPlayersListCount(initialCount);
  }

  // Function to save players to SharedPreferences
  Future<void> _savePlayersToPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> playersJsonMap = _players.map((key, player) {
      return MapEntry(key, jsonEncode(player.toJson()));
    });
    String encodedPlayers = jsonEncode(playersJsonMap);
    await prefs.setString('players_list', encodedPlayers);
  }

  Future<void> _loadPlayersFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedPlayers = prefs.getString('players_list');
    if (encodedPlayers != null) {
      Map<String, dynamic> playersJsonMap = jsonDecode(encodedPlayers);
      playersJsonMap.forEach((key, playerJsonString) {
        Map<String, dynamic> playerMap = jsonDecode(playerJsonString);
        Player player = Player.fromJson(playerMap);
        _players[key] = player;
        _unassignedPlayers.add(player);
      });
      notifyListeners();
    }
  }

  // 모든 플레이어의 수정 불가능한 맵을 반환합니다.
  Map<String, Player> get players => Map.unmodifiable(_players);

  // 새로운 플레이어를 추가합니다. 이미 존재하는 이름의 플레이어는 추가하지 않습니다.
  void addPlayer({
    required String name,
    required bool manager,
    required int rate,
    required String gender,
    required int played,
    required int waited,
  }) {
    if (name.length > 7) return;
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
      _savePlayersToPrefs();
    }
  }

  // 지정된 이름의 플레이어를 제거합니다.
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
      _savePlayersToPrefs();
    }
  }

  // 플레이어 정보를 업데이트합니다.
  void updatePlayer({
    required String oldName,
    required String newName,
    required int newRate,
    required String newGender,
    required bool newManager,
  }) {
    if (newName.length > 7) return;
    if (!_players.containsKey(oldName)) return;
    if (oldName != newName && _players.containsKey(newName)) return;

    Player? playerToUpdate = _players[oldName];
    if (playerToUpdate == null) return;

    playerToUpdate.rate = newRate;
    playerToUpdate.gender = newGender;
    playerToUpdate.manager = newManager;

    if (oldName != newName) {
      _players.remove(oldName);
      playerToUpdate.name = newName;
      _players[newName] = playerToUpdate;
    }

    notifyListeners();
    _savePlayersToPrefs();
  }

  // 모든 플레이어 정보를 초기화합니다.
  void clearPlayers() {
    _players.clear();
    _unassignedPlayers.clear();
    for (int i = 0; i < _assignedPlayers.length; i++) {
      _assignedPlayers[i] = [null, null, null, null];
    }
    notifyListeners();
    _savePlayersToPrefs();
  }

  // 모든 플레이어의 목록을 played가 낮은 순으로, waited가 많은 순으로 정렬하여 반환합니다.
  List<Player> getPlayers() {
    var playerList = _players.values.toList();
    playerList.sort((a, b) {
      int playedCompare = a.played.compareTo(b.played);
      if (playedCompare != 0) {
        return playedCompare;
      }
      return b.waited.compareTo(a.waited);
    });
    return playerList;
  }

  // 할당된 플레이어 목록(코트)의 수를 업데이트합니다.
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

  // 두 코트 위치에 있는 플레이어를 서로 교환합니다.
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

  // 미할당 플레이어와 코트의 특정 위치에 있는 플레이어를 교환합니다.
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

  // 특정 코트의 특정 위치에서 플레이어를 제거하고 미할당 목록에 추가합니다.
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

  // 미할당 구역의 모든 플레이어의 waited 를 1 더합니다.
  void incrementWaitedTimeForAllUnassignedPlayers() {
    for (var player in _unassignedPlayers) {
      player.waited++;
    }
    notifyListeners();
  }

  // 해당 코트의 플레이어들을 미할당 구역으로 이동시킵니다.
  void movePlayersFromCourtToUnassigned(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) {
      return;
    }
    List<Player?> playersInCourt = _assignedPlayers[sectionIndex];
    for (int i = 0; i < playersInCourt.length; i++) {
      Player? player = playersInCourt[i];
      if (player != null) {
        player.waited = 0;
        player.played++;
        if (!_unassignedPlayers.contains(player)) {
          _unassignedPlayers.add(player);
        }
        _assignedPlayers[sectionIndex][i] = null;
      }
    }
    notifyListeners();
    _savePlayersToPrefs();
  }

  // 특정 코트에 4명의 플레이어를 할당합니다. (점수 기반 시스템)
  void assignPlayersToCourt(
    int sectionIndex, {
    required double skillWeight,
    required double genderWeight,
    required double waitedWeight,
    required double playedWeight,
  }) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) return;

    for (int i = 0; i < 4; i++) {
      if (_unassignedPlayers.isEmpty) break;

      if (_assignedPlayers[sectionIndex][i] == null) {
        Player? playerToAssign = _findBestPlayerForCourt(
          sectionIndex,
          skillWeight: skillWeight,
          genderWeight: genderWeight,
          waitedWeight: waitedWeight,
          playedWeight: playedWeight,
        );

        if (playerToAssign != null) {
          _assignedPlayers[sectionIndex][i] = playerToAssign;
          _unassignedPlayers.remove(playerToAssign);
        }
      }
    }

    notifyListeners();
  }

  Player? _findBestPlayerForCourt(
    int sectionIndex, {
    required double skillWeight,
    required double genderWeight,
    required double waitedWeight,
    required double playedWeight,
  }) {
    if (_unassignedPlayers.isEmpty) return null;

    final currentPlayersOnCourt = _assignedPlayers[sectionIndex]
        .where((p) => p != null)
        .cast<Player>()
        .toList();

    final int unassignedManagersCount = _unassignedPlayers
        .where((p) => p.manager)
        .length;
    final bool isLastManagerCondition =
        unassignedManagersCount == 1 && _unassignedPlayers.length > 1;

    if (currentPlayersOnCourt.isEmpty) {
      List<Player> candidatePlayers = _unassignedPlayers;
      if (isLastManagerCondition) {
        final nonManagers = _unassignedPlayers
            .where((p) => !p.manager)
            .toList();
        if (nonManagers.isNotEmpty) {
          candidatePlayers = nonManagers;
        }
      }

      final sortedCandidates = List.of(candidatePlayers)
        ..sort((a, b) {
          int playedCompare = a.played.compareTo(b.played);
          if (playedCompare != 0) return playedCompare;
          return b.waited.compareTo(a.waited);
        });

      if (sortedCandidates.isEmpty) return null;

      final topPlayer = sortedCandidates.first;
      final topTierPlayers = sortedCandidates
          .where(
            (p) => p.played == topPlayer.played && p.waited == topPlayer.waited,
          )
          .toList();

      if (topTierPlayers.length == 1) {
        return topPlayer;
      } else {
        final randomIndex = _random.nextInt(topTierPlayers.length);
        return topTierPlayers[randomIndex];
      }
    }

    final sortedUnassignedPlayers = List.of(_unassignedPlayers)
      ..sort((a, b) {
        double scoreA = _calculatePlayerScoreForCourt(
          a,
          currentPlayersOnCourt,
          skillWeight: skillWeight,
          genderWeight: genderWeight,
          waitedWeight: waitedWeight,
          playedWeight: playedWeight,
        );
        double scoreB = _calculatePlayerScoreForCourt(
          b,
          currentPlayersOnCourt,
          skillWeight: skillWeight,
          genderWeight: genderWeight,
          waitedWeight: waitedWeight,
          playedWeight: playedWeight,
        );
        return scoreB.compareTo(scoreA);
      });

    final Player bestPlayer = sortedUnassignedPlayers.first;

    if (isLastManagerCondition && bestPlayer.manager) {
      if (sortedUnassignedPlayers.length > 1) {
        return sortedUnassignedPlayers[1];
      }
    }
    return bestPlayer;
  }

  // 플레이어의 최종 점수를 계산하는 함수
  double _calculatePlayerScoreForCourt(
    Player player,
    List<Player> currentPlayersOnCourt, {
    required double skillWeight,
    required double genderWeight,
    required double waitedWeight,
    required double playedWeight,
  }) {
    // 1. 실력 점수 계산
    double avgRate = currentPlayersOnCourt.isEmpty
        ? player.rate.toDouble()
        : currentPlayersOnCourt.map((p) => p.rate).reduce((a, b) => a + b) /
              currentPlayersOnCourt.length;
    double rateDiff = (player.rate - avgRate).abs();
    double skillScore = 2.0 - rateDiff / 500.0;

    // 2. 성별 점수 계산
    int menCount = currentPlayersOnCourt.where((p) => p.gender == '남').length;
    int womenCount = currentPlayersOnCourt.where((p) => p.gender == '여').length;

    double genderScore = 0.5;
    if (player.gender == '여') {
      if (womenCount == 1 && menCount == 2) {
        genderScore = 1.0;
      } else if (womenCount > 0 && menCount == 0) {
        genderScore = 1.5;
      } else if (womenCount > 2) {
        genderScore = 2.0;
      }
    } else {
      if (menCount == 1 && womenCount == 2) {
        genderScore = 1.0;
      } else if (menCount > 0 && womenCount == 0) {
        genderScore = 1.5;
      } else if (menCount > 2) {
        genderScore = 2.0;
      }
    }

    // 순차적으로 배치 했다고 가정 할 때 (대기인원 / 4) 만큼은 반드시 기다려야 하므로 해당 waited 를 1.0 으로 기준
    double waitedScore =
        player.waited.toDouble() /
        (_unassignedPlayers.length == 0 ? 1 : _unassignedPlayers.length) *
        4;

    // 4. 플레이 점수 계산
    final double avgPlayed = _unassignedPlayers.isEmpty
        ? 0.0
        : _unassignedPlayers.map((p) => p.played).reduce((a, b) => a + b) /
              _unassignedPlayers.length;
    double playedScore = avgPlayed - player.played;

    // 최종 점수 = 각 점수 * 가중치의 합
    return (skillScore * skillWeight) +
        (genderScore * genderWeight) +
        (waitedScore * waitedWeight) +
        (playedScore * playedWeight);
  }

  // 미할당된 플레이어의 수정 불가능한 목록을 반환합니다.
  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  // 코트에 할당된 플레이어들의 수정 불가능한 목록 (리스트의 리스트 형태)을 반환합니다.
  List<List<Player?>> get assignedPlayers =>
      List.unmodifiable(_assignedPlayers);
}
