import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart';

class Player {
  final int id;
  String name;
  bool manager;
  int rate;
  String gender;
  int played;
  int waited;
  int lated;

  Player({
    required this.id,
    required this.rate,
    required this.manager,
    required String name,
    required this.gender,
    required this.played,
    required this.waited,
    required this.lated,
  }) : this.name = name.length > 7 ? name.substring(0, 7) : name;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'manager': manager,
    'rate': rate,
    'gender': gender,
    'played': played,
    'waited': waited,
    'lated': lated,
  };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] as int,
    // Expect int ID from JSON
    name: json['name'] as String,
    manager: json['manager'] as bool,
    rate: json['rate'] as int,
    gender: json['gender'] as String,
    played: json['played'] as int? ?? 0,
    waited: json['waited'] as int? ?? 0,
    lated: json['lated'] as int? ?? 0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id; // Compare by ID

  @override
  int get hashCode => id.hashCode; // Hash by ID
}

class PlayersProvider with ChangeNotifier {
  final Map<int, Player> _players = {}; // Key changed to int (playerId)
  List<List<Player?>> _assignedPlayers = [];
  List<Player> _unassignedPlayers = [];
  final Random _random = Random();
  int _nextPlayerId = 0; // For generating unique integer IDs

  PlayersProvider() {
    // final List<int> skillRates = skillLevelToRate.values.toList();
    //
    // for (int i = 1; i <= 32; i++) {
    //   int id = i;
    //   String playerName = '플레이어 $i';
    //   bool manager = _random.nextBool();
    //   int playerRate = skillRates[_random.nextInt(skillRates.length)];
    //   String gender = _random.nextBool() ? '남' : '여';
    //   int played = 0;
    //   int waited = 0;
    //   int lated = 0;
    //   Player newPlayer = Player(
    //     name: playerName,
    //     manager: manager,
    //     rate: playerRate,
    //     gender: gender,
    //     played: played,
    //     waited: waited,
    //     lated: lated,
    //   );
    //   _players[playerName] = newPlayer;
    //   _unassignedPlayers.add(newPlayer);
    // }
    _loadInitialAssignedPlayersCount();
    _loadPlayersFromPrefs();
  }

  Future<void> _loadInitialAssignedPlayersCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int initialCount = prefs.getInt("numberOfSections") ?? 3;
    updateAssignedPlayersListCount(initialCount);
  }

  Future<void> _savePlayersToPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Convert Map<int, Player> to Map<String, String> for JSON encoding
    Map<String, String> playersJsonMap = _players.map((playerId, player) {
      return MapEntry(playerId.toString(), jsonEncode(player.toJson()));
    });
    String encodedPlayers = jsonEncode(playersJsonMap);
    await prefs.setString('players_list', encodedPlayers);
  }

  Future<void> _loadPlayersFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedPlayers = prefs.getString('players_list');
    int maxIdFound = -1;

    if (encodedPlayers != null) {
      Map<String, dynamic> playersJsonMap = jsonDecode(
        encodedPlayers,
      ); // Outer map: Map<String(id), String(playerJson)>
      playersJsonMap.forEach((idString, playerJsonString) {
        Map<String, dynamic> playerMap = jsonDecode(playerJsonString as String);
        Player player = Player.fromJson(playerMap);
        _players[player.id] = player;
        _unassignedPlayers.add(player); // Add to unassigned by default
        if (player.id > maxIdFound) {
          maxIdFound = player.id;
        }
      });
    }
    _nextPlayerId = maxIdFound + 1;
    notifyListeners();
  }

  Map<int, Player> get players => Map.unmodifiable(_players);

  void addPlayer({
    required String name,
    required bool manager,
    required int rate,
    required String gender,
    required int played,
    required int waited,
    required int lated,
  }) {
    if (name.length > 7) return;
    if (_players.values.any((player) => player.name == name)) return;

    int newPlayerId = _nextPlayerId++;
    Player newPlayer = Player(
      id: newPlayerId,
      name: name,
      manager: manager,
      rate: rate,
      gender: gender,
      played: played,
      waited: waited,
      lated: lated,
    );
    _players[newPlayerId] = newPlayer;
    _unassignedPlayers.add(newPlayer);
    notifyListeners();
    _savePlayersToPrefs();
  }

  void removePlayer(int playerId) {
    if (_players.containsKey(playerId)) {
      Player? playerToRemove = _players[playerId];
      if (playerToRemove == null) return;
      for (int i = 0; i < _assignedPlayers.length; i++) {
        for (int j = 0; j < _assignedPlayers[i].length; j++) {
          if (_assignedPlayers[i][j] == playerToRemove) {
            _assignedPlayers[i][j] = null;
          }
        }
      }
      _unassignedPlayers.remove(playerToRemove); // Equality uses ID
      _players.remove(playerId);
      notifyListeners();
      _savePlayersToPrefs();
    }
  }

  void updatePlayer({
    required int playerId, // Changed to int playerId
    required String newName,
    required int newRate,
    required String newGender,
    required bool newManager,
  }) {
    if (newName.length > 7) return;
    if (!_players.containsKey(playerId)) return;
    Player playerToUpdate = _players[playerId]!;
    playerToUpdate.name = newName;
    playerToUpdate.rate = newRate;
    playerToUpdate.gender = newGender;
    playerToUpdate.manager = newManager;

    notifyListeners();
    _savePlayersToPrefs();
  }

  void clearPlayers() {
    _players.clear();
    _unassignedPlayers.clear();
    for (int i = 0; i < _assignedPlayers.length; i++) {
      _assignedPlayers[i] = [null, null, null, null];
    }
    _nextPlayerId = 0;
    notifyListeners();
    _savePlayersToPrefs();
  }

  List<Player> getPlayers() {
    var playerList = _players.values.toList();
    playerList.sort((a, b) {
      int playedCompare = (a.played + a.lated).compareTo(b.played + b.lated);
      if (playedCompare != 0) {
        return playedCompare;
      }
      return b.waited.compareTo(a.waited);
    });
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
          if (player != null && !_unassignedPlayers.contains(player)) {
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

  void incrementWaitedTimeForAllUnassignedPlayers() {
    for (var player in _unassignedPlayers) {
      player.waited++;
    }
    notifyListeners();
    _savePlayersToPrefs();
  }

  void movePlayersFromCourtToUnassigned(int sectionIndex, [int played = 1]) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) {
      return;
    }
    List<Player?> playersInCourt = _assignedPlayers[sectionIndex];
    for (int i = 0; i < playersInCourt.length; i++) {
      Player? player = playersInCourt[i];
      if (player != null) {
        player.waited = played != 0 ? 0 : player.waited;
        player.played += played;
        if (!_unassignedPlayers.contains(player)) {
          _unassignedPlayers.add(player);
        }
        _assignedPlayers[sectionIndex][i] = null;
      }
    }
    notifyListeners();
    _savePlayersToPrefs();
  }

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
        unassignedManagersCount == 1 &&
        _unassignedPlayers.any((p) => !p.manager);

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
          int playedCompare = (a.played + a.lated).compareTo(
            b.played + b.lated,
          );
          if (playedCompare != 0) return playedCompare;
          return b.waited.compareTo(a.waited);
        });

      if (sortedCandidates.isEmpty) return null;

      final topPlayer = sortedCandidates.first;
      final topTierPlayers = sortedCandidates
          .where(
            (p) =>
                (p.played + p.lated) == (topPlayer.played + topPlayer.lated) &&
                p.waited == topPlayer.waited,
          )
          .toList();

      final randomIndex = _random.nextInt(topTierPlayers.length);
      return topTierPlayers[randomIndex];
    }

    // If court is not empty, sort all unassigned players by score
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
        return scoreB.compareTo(scoreA); // Higher score is better
      });

    if (sortedUnassignedPlayers.isEmpty) return null;
    Player bestPlayer = sortedUnassignedPlayers.first;
    
    if (isLastManagerCondition && bestPlayer.manager) {
      Player? bestNonManager = null;
      for (final pInList in sortedUnassignedPlayers) { // 변수명 p가 이미 사용 중일 수 있으므로 pInList로 변경
        if (!pInList.manager) {
          bestNonManager = pInList;
          break;
        }
      }
      if (bestNonManager != null) {
        return bestNonManager;
      }
    }
    return bestPlayer;
  }

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

    if (player.gender == "여") {
      womenCount++;
    } else {
      menCount++;
    }
    double mixScore = 0.25;
    double singleGenderScore = 0.25;

    if (menCount == 2 && womenCount == 2) {
      mixScore = 2.0;
    } else if (womenCount == 1 && menCount == 1) {
      mixScore = 1.5;
    } else if ((menCount == 2 && womenCount == 1) ||
        (womenCount == 2 && menCount == 1)) {
      mixScore = 1.5;
    }
    if (menCount == 4 || womenCount == 4) {
      singleGenderScore = 2.0;
    } else if ((womenCount == 0) || (menCount == 0)) {
      singleGenderScore = 1.5;
    }

    double weightForMix = (2.0 - genderWeight);
    double weightForSingle = genderWeight;

    double genderScore =
        (mixScore * weightForMix) + (singleGenderScore * weightForSingle);

    // 순차적으로 배치 했다고 가정 할 때 (대기인원 / 4) 만큼은 반드시 기다려야 하므로 해당 waited 를 1.0 으로 기준
    double waitedScore =
        player.waited.toDouble() /
        (_unassignedPlayers.length == 0 ? 1 : _unassignedPlayers.length) *
        4;

    // 4. 플레이 횟수 점수 계산
    final double avgPlayed = _unassignedPlayers.isEmpty
        ? 0.0
        : _unassignedPlayers.map((p) => p.played).reduce((a, b) => a + b) /
              _unassignedPlayers.length;
    double playedScore = avgPlayed - (player.played + player.lated);

    // 최종 점수 = 각 점수 * 가중치의 합
    return (skillScore * skillWeight) +
        (genderScore * genderWeight) +
        (waitedScore * waitedWeight) +
        (playedScore * playedWeight);
  }

  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  // 코트에 할당된 플레이어들의 수정 불가능한 목록 (리스트의 리스트 형태)을 반환합니다.
  List<List<Player?>> get assignedPlayers =>
      List.unmodifiable(_assignedPlayers);
}
