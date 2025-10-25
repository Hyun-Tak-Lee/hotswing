import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/options.dart';
import 'package:hotswing/src/services/court_assign_service.dart';
import 'package:hotswing/src/services/player_service.dart';
import 'package:realm/realm.dart';

class PlayersProvider with ChangeNotifier {
  final CourtAssignService _courtService = CourtAssignService();
  final PlayerService _playerService = PlayerService();

  final Random _random = Random();

  final Map<ObjectId, Player> _players = {};
  final List<List<Player?>> _assignedPlayers = [];
  final List<Player> _unassignedPlayers = [];

  PlayersProvider() {
    final List<int> skillRates = skillLevelToRate.values.toList();

    for (int i = 1; i <= 32; i++) {
      String playerName = '플레이어 $i';
      String role = _random.nextBool() ? "manager" : "user";
      int playerRate = skillRates[_random.nextInt(skillRates.length)];
      String gender = _random.nextBool() ? '남' : '여';
      int played = 0;
      int waited = 0;
      int lated = 0;
      addPlayer(
        name: playerName,
        role: role,
        rate: playerRate,
        gender: gender,
        played: played,
        waited: waited,
        lated: lated,
        groups: [],
      );
    }

    _loadInitialAssignedPlayersCount();
  }

  Future<void> _loadInitialAssignedPlayersCount() async {
    OptionsRepository optionsRepository = OptionsRepository.instance;

    final int initialCount = optionsRepository.getOptions().numberOfSections;
    updateAssignedPlayersListCount(initialCount);
  }

  Map<ObjectId, Player> get players => Map.unmodifiable(_players);

  Player? getPlayerById(int id) {
    return _players[id];
  }

  void addPlayer({
    required String name,
    required String role,
    required int rate,
    required String gender,
    required int played,
    required int waited,
    required int lated,
    required List<ObjectId> groups,
  }) {
    if (name.length > 7) return;
    if (_players.values.any((player) => player.name == name)) return;
    final ObjectId newId = ObjectId();

    Player newPlayer = Player(
      newId,
      name,
      role,
      rate,
      gender,
      played: played,
      waited: waited,
      lated: lated,
      gamesPlayedWith: {},
      groups: RealmList<ObjectId>(groups),
    );
    _playerService.addPlayer(newPlayer);
    _players[newId] = newPlayer;
    _unassignedPlayers.add(newPlayer);

    if (groups.isNotEmpty) {
      _playerService.updateGroupPlayers(_players, groups, newId);
    }
    notifyListeners();
  }

  void removePlayer(ObjectId playerId) {
    if (_players.containsKey(playerId)) {
      Player? playerToRemove = _players[playerId];
      if (playerToRemove == null) return;
      if (playerToRemove.groups.isNotEmpty) {
        _playerService.removeGroupPlayers(
          _players,
          playerToRemove.groups,
          playerId,
        );
      }
      for (int i = 0; i < _assignedPlayers.length; i++) {
        for (int j = 0; j < _assignedPlayers[i].length; j++) {
          if (_assignedPlayers[i][j] == playerToRemove) {
            _assignedPlayers[i][j] = null;
          }
        }
      }
      _unassignedPlayers.remove(playerToRemove);
      _players.remove(playerId);
      notifyListeners();
    }
  }

  void updatePlayer({
    required ObjectId playerId,
    required String newName,
    required int newRate,
    required String newGender,
    required String newRole,
    required int newPlayed,
    required int newWaited,
    required List<ObjectId> newGroups,
  }) {
    if (newName.length > 7) return;
    if (!_players.containsKey(playerId)) return;
    Player playerToUpdate = _players[playerId]!;
    playerToUpdate.name = newName;
    playerToUpdate.rate = newRate;
    playerToUpdate.gender = newGender;
    playerToUpdate.role = newRole;
    playerToUpdate.played = newPlayed;
    playerToUpdate.waited = newWaited;

    if (playerToUpdate.groups.isNotEmpty) {
      _playerService.removeGroupPlayers(
        _players,
        playerToUpdate.groups,
        playerId,
      );
    }
    playerToUpdate.groups.clear();
    playerToUpdate.groups.addAll(newGroups);

    if (newGroups.isNotEmpty) {
      _playerService.updateGroupPlayers(_players, newGroups, playerId);
    }

    notifyListeners();
  }

  void resetPlayerStats() {
    for (Player player in _players.values) {
      player.played = 0;
      player.waited = 0;
      player.lated = 0;
      player.gamesPlayedWith.clear();
    }
    notifyListeners();
  }

  void clearPlayers() {
    _players.clear();
    _unassignedPlayers.clear();
    for (int i = 0; i < _assignedPlayers.length; i++) {
      _assignedPlayers[i] = [null, null, null, null];
    }
    notifyListeners();
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

  void incrementWaitedTimeForAllUnassignedPlayers() {
    for (var player in _unassignedPlayers) {
      player.waited++;
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

  void movePlayersFromCourtToUnassigned(int sectionIndex, [int played = 1]) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) {
      return;
    }
    List<Player?> playersInCourt = List.from(_assignedPlayers[sectionIndex]);

    for (int i = 0; i < playersInCourt.length; i++) {
      Player? player = playersInCourt[i];
      if (player != null) {
        player.waited = played != 0 ? 0 : player.waited;
        player.played += played;

        if (played == 1) {
          for (Player? otherPlayerInCourt in playersInCourt) {
            if (otherPlayerInCourt != null &&
                otherPlayerInCourt.id != player.id) {
              player.gamesPlayedWith[otherPlayerInCourt.id.toString()] =
                  (player.gamesPlayedWith[otherPlayerInCourt.id] ?? 0) + 1;
            }
          }
        }

        if (!_unassignedPlayers.contains(player)) {
          _unassignedPlayers.add(player);
        }
        _assignedPlayers[sectionIndex][i] = null;
      }
    }
    notifyListeners();
  }

  void assignPlayersToCourt(
    int sectionIndex, {
    required double skillWeight,
    required double genderWeight,
    required double waitedWeight,
    required double playedWeight,
    required double playedWithWeight,
  }) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) return;

    for (int i = 0; i < 4; i++) {
      if (_unassignedPlayers.isEmpty) break;

      if (_assignedPlayers[sectionIndex][i] == null) {
        Player? playerToAssign = _courtService.findBestPlayerForCourt(
          unassignedPlayers: _unassignedPlayers,
          currentPlayersOnCourt: _assignedPlayers[sectionIndex]
              .where((p) => p != null)
              .cast<Player>()
              .toList(),
          skillWeight: skillWeight,
          genderWeight: genderWeight,
          waitedWeight: waitedWeight,
          playedWeight: playedWeight,
          playedWithWeight: playedWithWeight,
        );

        if (playerToAssign != null) {
          _assignedPlayers[sectionIndex][i] = playerToAssign;
          _unassignedPlayers.remove(playerToAssign);
        }
      }
    }

    notifyListeners();
  }

  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  // 코트에 할당된 플레이어들의 수정 불가능한 목록 (리스트의 리스트 형태)을 반환합니다.
  List<List<Player?>> get assignedPlayers =>
      List.unmodifiable(_assignedPlayers);
}
