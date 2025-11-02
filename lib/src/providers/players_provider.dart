import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/options.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
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
    initialized();

    notifyListeners();
  }

  void initialized() async {
    try {
      await _loadInitialAssignedPlayersCount();
      await _sharedPreferencesInit();
      await _loadInitialPlayers();

      final List<int> skillRates = skillLevelToRate.values.toList();
      // _playerService.deleteAllPlayers();
      // for (int i = 1; i <= 32; i++) {
      //   String name = '플레이어 $i';
      //   String role = _random.nextBool() ? "manager" : "user";
      //   int rate = skillRates[_random.nextInt(skillRates.length)];
      //   String gender = _random.nextBool() ? '남' : '여';
      //   int played = 0;
      //   int waited = 0;
      //   int lated = 0;
      //   final ObjectId newId = ObjectId();
      //   Player newPlayer = Player(
      //     newId,
      //     name,
      //     role,
      //     rate,
      //     gender,
      //     played: played,
      //     waited: waited,
      //     lated: lated,
      //     gamesPlayedWith: {},
      //     groups: RealmList<ObjectId>([]),
      //   );
      //   _playerService.addPlayer(newPlayer);
      //   addPlayerInCourt(newPlayer, []);
      // }
      // _saveLoadedPlayers();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _sharedPreferencesInit() async {
    await SharedProvider().init();
  }

  Future<void> _loadInitialPlayers() async {
    List<String> unassignedIds = await SharedProvider().getStringList("unassignedPlayers") ?? [];
    List<ObjectId> unassignedObjectIds = unassignedIds.map((id) => ObjectId.fromHexString(id)).toList();
    if (unassignedIds.isNotEmpty) {
      _unassignedPlayers.clear();
      _unassignedPlayers.addAll(_playerService.findPlayersByIds(unassignedObjectIds).whereType<Player>().toList());
    }
    List<String> assignedIds = await SharedProvider().getStringList("assignedPlayers") ?? [];
    if (assignedIds.isNotEmpty) {
      _assignedPlayers.clear();
      _assignedPlayers.addAll(
        assignedIds.map((encodedList) {
          List<dynamic> decoded = jsonDecode(encodedList);
          List<ObjectId?> singleCourt = decoded.map((id) => (id == "") ? null : ObjectId.fromHexString(id)).toList();
          return _playerService.findPlayersByIds(singleCourt);
        }).toList(),
      );
    }
  }

  Future<void> _saveLoadedPlayers() async {
    final List<String> assignedPlayersIdListNested = _assignedPlayers
        .map((innerList) => innerList.map((player) => player?.id.toString() ?? "").toList())
        .map((idList) => jsonEncode(idList))
        .toList();
    final List<String> unassignedPlayersIdList = _unassignedPlayers.map((player) => player.id.toString()).toList();
    await SharedProvider().saveStringList("assignedPlayers", assignedPlayersIdListNested);
    await SharedProvider().saveStringList("unassignedPlayers", unassignedPlayersIdList);
  }

  Future<void> _loadInitialAssignedPlayersCount() async {
    OptionsRepository optionsRepository = OptionsRepository.instance;

    final int initialCount = optionsRepository.getOptions().numberOfSections;
    updateAssignedPlayersListCount(initialCount);
  }

  Map<ObjectId, Player> get players => Map.unmodifiable(_players);

  Player? getPlayerById(ObjectId id) {
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
    addPlayerInCourt(newPlayer, groups);

    _saveLoadedPlayers();
    notifyListeners();
  }

  void addPlayerInCourt(Player player, List<ObjectId> groups) {
    if (!_players.containsKey(player.id)) {
      _players[player.id] = player;
    }
    if (!unassignedPlayers.contains(player)) {
      _unassignedPlayers.add(player);
    }
    if (player.groups.isNotEmpty) {
      _playerService.removeGroupPlayers(_players, player.groups, player.id);
    }
    if (groups.isNotEmpty) {
      _playerService.updateGroupPlayers(_players, groups, player.id);
    }
  }

  void loadPlayer(Player player, List<ObjectId> groups) {
    addPlayerInCourt(player, groups);
    _playerService.updateGroups(player, groups);

    _saveLoadedPlayers();
    notifyListeners();
  }

  void removePlayer(ObjectId playerId) {
    if (_players.containsKey(playerId)) {
      Player? playerToRemove = _players[playerId];
      if (playerToRemove == null) return;
      if (playerToRemove.groups.isNotEmpty) {
        _playerService.removeGroupPlayers(_players, playerToRemove.groups, playerId);
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
      _saveLoadedPlayers();
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

    //기존 그룹 플레이어들의 그룹 제거
    if (playerToUpdate.groups.isNotEmpty) {
      _playerService.removeGroupPlayers(_players, playerToUpdate.groups, playerId);
    }

    _playerService.updatePlayer(
      playerToUpdate,
      newName,
      newRole,
      newRate,
      newGender,
      newPlayed,
      newWaited,
      playerToUpdate.lated,
      newGroups,
    );

    // 자신 이외의 플레이어들도 그룹 생성
    if (newGroups.isNotEmpty) {
      _playerService.updateGroupPlayers(_players, newGroups, playerId);
    }

    _saveLoadedPlayers();
    notifyListeners();
  }

  List<Player> findPlayersByPrefix(String name, int count) {
    RealmResults<Player> results = _playerService.findPlayersByPrefix(name);
    int actualLimit = results.length < count ? results.length : count;
    List<Player> limitedPlayers = results.take(actualLimit).toList();
    return limitedPlayers;
  }

  void resetPlayerStats() {
    for (Player player in _players.values) {
      _playerService.resetStats(player);
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
      return a.name.compareTo(b.name);
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
      _playerService.incrementWaited(player);
    }
    _saveLoadedPlayers();
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
    if (sectionIndex1 == sectionIndex2 && playerIndexInSection1 == playerIndexInSection2) {
      return;
    }

    Player? player1 = _assignedPlayers[sectionIndex1][playerIndexInSection1];
    Player? player2 = _assignedPlayers[sectionIndex2][playerIndexInSection2];

    _assignedPlayers[sectionIndex1][playerIndexInSection1] = player2;
    _assignedPlayers[sectionIndex2][playerIndexInSection2] = player1;

    _saveLoadedPlayers();
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
        targetCourtPlayerIndex >= _assignedPlayers[targetCourtSectionIndex].length) {
      return;
    }
    if (!_unassignedPlayers.contains(unassignedPlayerToAssign)) return;

    Player? playerCurrentlyInCourt = _assignedPlayers[targetCourtSectionIndex][targetCourtPlayerIndex];
    _assignedPlayers[targetCourtSectionIndex][targetCourtPlayerIndex] = unassignedPlayerToAssign;
    _unassignedPlayers.remove(unassignedPlayerToAssign);

    if (playerCurrentlyInCourt != null) {
      if (!_unassignedPlayers.contains(playerCurrentlyInCourt)) {
        _unassignedPlayers.add(playerCurrentlyInCourt);
      }
    }

    _saveLoadedPlayers();
    notifyListeners();
  }

  void removePlayerFromCourt({required int sectionIndex, required int playerIndexInSection}) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) return;
    if (playerIndexInSection < 0 || playerIndexInSection >= _assignedPlayers[sectionIndex].length) return;

    Player? playerToRemove = _assignedPlayers[sectionIndex][playerIndexInSection];

    if (playerToRemove != null) {
      _assignedPlayers[sectionIndex][playerIndexInSection] = null;
      if (!_unassignedPlayers.contains(playerToRemove)) {
        _unassignedPlayers.add(playerToRemove);
      }
      _saveLoadedPlayers();
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
        _playerService.playedFinish(player);
        if (played == 1) {
          _playerService.addGamesPlayedWith(player, playersInCourt, played);
        }

        if (!_unassignedPlayers.contains(player)) {
          _unassignedPlayers.add(player);
        }
        _assignedPlayers[sectionIndex][i] = null;
      }
    }
    _saveLoadedPlayers();
    notifyListeners();
  }

  // 자동 매칭
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
          currentPlayersOnCourt: _assignedPlayers[sectionIndex].where((p) => p != null).cast<Player>().toList(),
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

    _saveLoadedPlayers();
    notifyListeners();
  }

  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  // 코트에 할당된 플레이어들의 수정 불가능한 목록 (리스트의 리스트 형태)을 반환합니다.
  List<List<Player?>> get assignedPlayers => List.unmodifiable(_assignedPlayers);
}
