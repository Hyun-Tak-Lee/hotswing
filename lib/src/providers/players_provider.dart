import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/options.dart';
import 'package:hotswing/src/services/court_assign_service.dart';
import 'package:hotswing/src/services/player_service.dart';
import 'package:hotswing/src/services/player_session_service.dart';
import 'package:realm/realm.dart';

class PlayersProvider with ChangeNotifier {
  late final CourtAssignService _courtService;
  final PlayerSessionService _sessionService = PlayerSessionService();
  final PlayerService _playerService = PlayerService();

  late final Options _options;

  final Map<ObjectId, Player> _players = {};
  final List<List<Player?>> _assignedPlayers = [];
  final List<List<Player?>> _standbyPlayers = [];
  final List<Player> _unassignedPlayers = [];

  PlayersProvider() {
    _options = OptionsRepository.instance.getOptions();
    _courtService = CourtAssignService(_options);
    initialized();
    notifyListeners();
  }

  void initialized() async {
    try {
      _playerService.cleanupInactivePlayers(_options.inactiveDaysThreshold);
      await _loadInitialAssignedPlayersCount();
      await _loadInitialPlayers();
      _saveLoadedPlayers();
    } finally {
      notifyListeners();
    }
  }

  Future<void> _loadInitialPlayers() async {
    final playerIds = await _sessionService.loadPlayerIds();
    if (playerIds.isNotEmpty) {
      _players.clear();
      final loadedPlayers = _playerService
          .findPlayersByIds(playerIds)
          .whereType<Player>();
      _players.addEntries(loadedPlayers.map((p) => MapEntry(p.id, p)));
    }

    final unassignedIds = await _sessionService.loadUnassignedPlayerIds();
    if (unassignedIds.isNotEmpty) {
      _unassignedPlayers.clear();
      _unassignedPlayers.addAll(
        _playerService.findPlayersByIds(unassignedIds).whereType<Player>(),
      );
    }

    final assignedIds = await _sessionService.loadAssignedPlayerIds();
    if (assignedIds.isNotEmpty) {
      _assignedPlayers.clear();
      _assignedPlayers.addAll(
        assignedIds.map((ids) => _playerService.findPlayersByIds(ids)),
      );
    }

    final standbyIds = await _sessionService.loadStandbyPlayerIds();
    if (standbyIds.isNotEmpty) {
      _standbyPlayers.clear();
      _standbyPlayers.addAll(
        standbyIds.map((ids) => _playerService.findPlayersByIds(ids)),
      );
    }
  }

  Future<void> _loadInitialAssignedPlayersCount() async {
    final int initialCount = _options.numberOfSections;
    updateAssignedPlayersListCount(initialCount);
  }

  Future<void> _saveLoadedPlayers() async {
    await _sessionService.saveSession(
      players: _players,
      unassignedPlayers: _unassignedPlayers,
      assignedPlayers: _assignedPlayers,
      standbyPlayers: _standbyPlayers,
    );
  }

  Map<ObjectId, Player> get players => Map.unmodifiable(_players);

  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  List<List<Player?>> get assignedPlayers =>
      List.unmodifiable(_assignedPlayers);

  List<List<Player?>> get standbyPlayers => List.unmodifiable(_standbyPlayers);

  List<Player> getPlayers() {
    var playerList = _players.values.toList();
    playerList.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    return playerList;
  }

  Player? getPlayerById(ObjectId id) {
    return _players[id];
  }

  List<Player> findPlayersByPrefix(String name, int count) {
    RealmResults<Player> results = _playerService.findPlayersByPrefix(name);
    int actualLimit = results.length < count ? results.length : count;
    List<Player> limitedPlayers = results.take(actualLimit).toList();
    return limitedPlayers;
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
    if (name.length > 10) return;
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
      recentMatchDate: DateTime.now(),
    );
    _playerService.addPlayer(newPlayer);
    addPlayerInCourt(newPlayer, groups);

    _saveLoadedPlayers();
    notifyListeners();
  }

  void loadPlayer(Player player, List<ObjectId> groups, int lated) {
    addPlayerInCourt(player, groups);
    _playerService.resetStats(player, lated: lated);
    _playerService.updateGroups(player, groups);
    _playerService.updateRecentMatchDate(player);

    _saveLoadedPlayers();
    notifyListeners();
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
    if (newName.length > 10) return;
    if (!_players.containsKey(playerId)) return;
    Player playerToUpdate = _players[playerId]!;

    // 기존 그룹 플레이어들의 그룹 제거
    if (playerToUpdate.groups.isNotEmpty) {
      _playerService.removeGroupPlayers(
        _players,
        playerToUpdate.groups,
        playerId,
      );
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
      null,
    );

    // 자신 이외의 플레이어들도 그룹 생성
    if (newGroups.isNotEmpty) {
      _playerService.updateGroupPlayers(_players, newGroups, playerId);
    }

    _saveLoadedPlayers();
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
      for (var court in _assignedPlayers) {
        for (int i = 0; i < court.length; i++) {
          if (court[i] == playerToRemove) {
            court[i] = null;
          }
        }
      }
      _unassignedPlayers.remove(playerToRemove);
      _players.remove(playerId);
      _saveLoadedPlayers();
      notifyListeners();
    }
  }

  void clearPlayers() {
    // 게스트 유저 삭제
    _players.clear();
    _unassignedPlayers.clear();
    for (int i = 0; i < _assignedPlayers.length; i++) {
      _assignedPlayers[i] = List.filled(4, null);
    }
    notifyListeners();
  }

  void toggleIsActivate(Player player) {
    _playerService.updateActivate(player, !player.activate);
    _saveLoadedPlayers();
    notifyListeners();
  }

  void resetPlayerStats() {
    for (Player player in _players.values) {
      _playerService.resetStats(player);
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

  void updateAssignedPlayersListCount(int newCount) {
    if (newCount < 0) {
      return;
    }
    int currentCount = _assignedPlayers.length;
    if (newCount < currentCount) {
      for (int i = newCount; i < currentCount; i++) {
        for (final player in _assignedPlayers[i].whereType<Player>()) {
          if (!_unassignedPlayers.contains(player)) {
            _unassignedPlayers.add(player);
          }
        }
      }
      _assignedPlayers.removeRange(newCount, currentCount);
    } else if (newCount > currentCount) {
      _assignedPlayers.addAll(
        List.generate(newCount - currentCount, (_) => List.filled(4, null)),
      );
    }
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

  void addUnassignedPlayer(Player? player) {
    if (player == null) return;
    if (!_unassignedPlayers.contains(player)) {
      _unassignedPlayers.add(player);
      _saveLoadedPlayers();
      notifyListeners();
    }
  }

  void removeUnassignedPlayer(Player player) {
    if (_unassignedPlayers.contains(player)) {
      _unassignedPlayers.remove(player);
      _saveLoadedPlayers();
      notifyListeners();
    }
  }

  void addAssignedPlayer(Player? player, int courtIndex, int playerIndex) {
    if (player == null) return;
    if (courtIndex < 0 || courtIndex >= _assignedPlayers.length) return;
    if (playerIndex < 0 || playerIndex >= _assignedPlayers[courtIndex].length) {
      return;
    }
    _assignedPlayers[courtIndex][playerIndex] = player;
    _saveLoadedPlayers();
    notifyListeners();
  }

  Player? removeAssignedPlayer(int courtIndex, int playerIndex) {
    if (courtIndex < 0 || courtIndex >= _assignedPlayers.length) return null;
    if (playerIndex < 0 || playerIndex >= _assignedPlayers[courtIndex].length) {
      return null;
    }
    Player? removed = _assignedPlayers[courtIndex][playerIndex];
    _assignedPlayers[courtIndex][playerIndex] = null;

    if (removed != null) {
      _saveLoadedPlayers();
      notifyListeners();
    }
    return removed;
  }

  void addStandbyPlayer(Player? player, int courtIndex, int playerIndex) {
    if (player == null) return;
    if (courtIndex < 0 || courtIndex >= _standbyPlayers.length) return;
    if (playerIndex < 0 || playerIndex >= _standbyPlayers[courtIndex].length) {
      return;
    }
    _standbyPlayers[courtIndex][playerIndex] = player;
    _saveLoadedPlayers();
    notifyListeners();
  }

  Player? removeStandbyPlayer(int courtIndex, int playerIndex) {
    if (courtIndex < 0 || courtIndex >= _standbyPlayers.length) return null;
    if (playerIndex < 0 || playerIndex >= _standbyPlayers[courtIndex].length) {
      return null;
    }
    Player? removed = _standbyPlayers[courtIndex][playerIndex];
    _standbyPlayers[courtIndex][playerIndex] = null;

    if (removed != null) {
      _saveLoadedPlayers();
      notifyListeners();
    }
    return removed;
  }

  void addStandByPlayers() {
    _standbyPlayers.add(List.filled(4, null));
    _saveLoadedPlayers();
    notifyListeners();
  }

  void removeStandByPlayers(int index) {
    final removedList = _standbyPlayers.removeAt(index);
    _unassignedPlayers.addAll(removedList.whereType<Player>());

    _saveLoadedPlayers();
    notifyListeners();
  }

  bool popStandByPlayers(int assignedIndex) {
    if (assignedIndex < 0 || assignedIndex >= _assignedPlayers.length) {
      return false;
    }

    final List<Player?> currentAssignedTeam = _assignedPlayers[assignedIndex];
    if (currentAssignedTeam.any((player) => player != null)) {
      return false;
    }

    if (_standbyPlayers.isNotEmpty) {
      final List<Player?> playerToAssign = _standbyPlayers.first;
      final bool isFullTeam = playerToAssign.every((player) => player != null);
      if (isFullTeam) {
        _assignedPlayers[assignedIndex] = _standbyPlayers.removeAt(0);
        _saveLoadedPlayers();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void movePlayersFromCourtToUnassigned({
    required int sectionIndex,
    required String targetCourtKind,
    int played = 1,
  }) {
    List<List<Player?>> targetCourtPlayers = targetCourtKind == "assigned"
        ? _assignedPlayers
        : _standbyPlayers;

    if (sectionIndex < 0 || sectionIndex >= targetCourtPlayers.length) {
      return;
    }
    List<Player?> playersInCourt = List.from(targetCourtPlayers[sectionIndex]);

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
        targetCourtPlayers[sectionIndex][i] = null;
      }
    }
    _saveLoadedPlayers();
    notifyListeners();
  }

  List<Player> getAssignedPlayersInCourt(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) {
      return [];
    }
    return _assignedPlayers[sectionIndex]
        .where((p) => p != null)
        .cast<Player>()
        .toList();
  }

  List<Player> getStandbyPlayersInCourt(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= _standbyPlayers.length) {
      return [];
    }
    return _standbyPlayers[sectionIndex]
        .where((p) => p != null)
        .cast<Player>()
        .toList();
  }

  List<Player> getRecommendedPlayers(List<Player> currentPlayersOnCourt) {
    return _courtService.getRecommendedPlayersForCourt(
      unassignedPlayers: _unassignedPlayers,
      currentPlayersOnCourt: currentPlayersOnCourt,
    );
  }

  void swapAssignedCourts(int indexA, int indexB) {
    if (indexA < 0 ||
        indexA >= _assignedPlayers.length ||
        indexB < 0 ||
        indexB >= _assignedPlayers.length) {
      return;
    }
    List<Player?> temp = _assignedPlayers[indexA];
    _assignedPlayers[indexA] = _assignedPlayers[indexB];
    _assignedPlayers[indexB] = temp;
    _saveLoadedPlayers();
    notifyListeners();
  }

  void assignNextPlayersToAssignedCourt(int sectionIndex) {
    if (popStandByPlayers(sectionIndex)) return;

    List<Player> currentPlayers = getAssignedPlayersInCourt(sectionIndex);
    List<Player> recommendedPlayers = getRecommendedPlayers(currentPlayers);
    addPlayersToAssignedCourt(sectionIndex, recommendedPlayers);
  }

  void assignNextPlayersToStandbyCourt(int sectionIndex) {
    List<Player> currentPlayers = getStandbyPlayersInCourt(sectionIndex);
    List<Player> recommendedPlayers = getRecommendedPlayers(currentPlayers);
    addPlayersToStandbyCourt(sectionIndex, recommendedPlayers);
  }

  void addPlayersToAssignedCourt(int sectionIndex, List<Player> playersToAdd) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) return;

    int addIndex = 0;
    for (int i = 0; i < 4; i++) {
      if (addIndex >= playersToAdd.length) break;

      if (_assignedPlayers[sectionIndex][i] == null) {
        Player player = playersToAdd[addIndex];
        _assignedPlayers[sectionIndex][i] = player;
        _unassignedPlayers.remove(player);
        addIndex++;
      }
    }
    _saveLoadedPlayers();
    notifyListeners();
  }

  void addPlayersToStandbyCourt(int sectionIndex, List<Player> playersToAdd) {
    if (sectionIndex < 0 || sectionIndex >= _standbyPlayers.length) return;

    int addIndex = 0;
    for (int i = 0; i < 4; i++) {
      if (addIndex >= playersToAdd.length) break;

      if (_standbyPlayers[sectionIndex][i] == null) {
        Player player = playersToAdd[addIndex];
        _standbyPlayers[sectionIndex][i] = player;
        _unassignedPlayers.remove(player);
        addIndex++;
      }
    }
    _saveLoadedPlayers();
    notifyListeners();
  }
}
