import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hotswing/src/common/constants/court_constants.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/group_info.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/repository/realms/options.dart';
import 'package:hotswing/src/services/court/court_assign_service.dart';
import 'package:hotswing/src/services/court/court_slot_service.dart';
import 'package:hotswing/src/services/player/player_service.dart';
import 'package:hotswing/src/services/player/player_session_service.dart';
import 'package:realm/realm.dart';

/// 코트 배정, 대기열, 동반 그룹, 세션 영속화 등 경기 운영 전반의 상태를 관리하는 프로바이더.
class PlayersProvider with ChangeNotifier {
  static const Duration _saveDebounceDuration = Duration(milliseconds: 300);
  static const Duration _saveMaxWait = Duration(seconds: 1);

  late final CourtAssignService _courtService;
  final CourtSlotService _courtSlotService = const CourtSlotService();
  final PlayerSessionService _sessionService = PlayerSessionService();
  final PlayerService _playerService = PlayerService();

  late final Options _options;

  final Map<ObjectId, Player> _players = {};
  final List<List<Player?>> _assignedPlayers = [];
  final List<List<Player?>> _standbyPlayers = [];
  final List<Player> _unassignedPlayers = [];
  final List<DateTime?> _courtStartTimes = [];
  Map<ObjectId, GroupInfo>? _cachedGroupInfo;
  List<Player>? _cachedSortedPlayers;
  final Map<String, String> _customGroupNames = {};
  Timer? _saveDebounce;
  DateTime? _pendingSince;

  /// [PlayersProvider] 생성자. 옵션 조회 및 서비스 초기화를 진행합니다.
  PlayersProvider() {
    _options = OptionsRepository.instance.getOptions();
    _courtService = CourtAssignService(_options);
    initialized();
    notifyListeners();
  }

  /// 진행 코트 또는 대기 코트에 1명 이상의 선수가 배정되어 있는지 여부.
  bool get hasActivePlayers {
    for (var court in _assignedPlayers) {
      if (court.any((p) => p != null)) return true;
    }
    for (var court in _standbyPlayers) {
      if (court.any((p) => p != null)) return true;
    }
    return false;
  }

  /// 현재 세션에 등록된 전체 선수 맵(읽기 전용).
  Map<ObjectId, Player> get players => Map.unmodifiable(_players);

  /// 대기열에 있는 미배정 선수 목록(읽기 전용).
  List<Player> get unassignedPlayers => List.unmodifiable(_unassignedPlayers);

  /// 진행 코트별 배치된 선수 목록(읽기 전용 2차원 리스트).
  List<List<Player?>> get assignedPlayers =>
      List.unmodifiable(_assignedPlayers);

  /// 대기 코트별 배치된 선수 목록(읽기 전용 2차원 리스트).
  List<List<Player?>> get standbyPlayers => List.unmodifiable(_standbyPlayers);

  /// 코트별 경기 시작 시각 목록(읽기 전용).
  List<DateTime?> get courtStartTimes => List.unmodifiable(_courtStartTimes);

  @override
  void notifyListeners() {
    _cachedGroupInfo = null;
    _cachedSortedPlayers = null;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    if (_pendingSince != null) {
      _pendingSince = null;
      _flushSave();
    }
    super.dispose();
  }

  /// 로컬 저장소로부터 세션 상태 및 플레이어 데이터를 불러와 초기화합니다.
  void initialized() async {
    try {
      await _loadCustomGroupNames();
      await _loadInitialAssignedPlayersCount();
      await _loadInitialPlayers();

      final activePlayerIds = _players.keys.toList();
      _playerService.cleanupInactivePlayers(
        _options.inactiveDaysThreshold,
        activePlayerIds,
      );
      _playerService.cleanupGuestPlayers(activePlayerIds);

      _saveLoadedPlayers();
    } finally {
      notifyListeners();
    }
  }

  /// [criterion] 기준 및 [ascending] 방향으로 정렬된 대기 선수 목록의 새 복사본을 반환합니다.
  List<Player> getSortedUnassignedPlayers({
    required SortCriterion criterion,
    required bool ascending,
  }) {
    return _playerService.sortWaitingPlayers(
      players: _unassignedPlayers,
      criterion: criterion,
      ascending: ascending,
    );
  }

  /// 전체 선수를 이름 가나다순으로 정렬하여 반환합니다. (캐싱 지원)
  List<Player> getPlayers() {
    if (_cachedSortedPlayers != null) {
      return _cachedSortedPlayers!;
    }
    var playerList = _players.values.toList();
    playerList.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    _cachedSortedPlayers = List.unmodifiable(playerList);
    return _cachedSortedPlayers!;
  }

  /// 식별자([id])에 해당하는 선수를 반환합니다.
  Player? getPlayerById(ObjectId id) {
    return _players[id];
  }

  /// 이름 접두어([name])로 시작하는 선수를 최대 [count]명 검색합니다.
  List<Player> findPlayersByPrefix(String name, int count) {
    RealmResults<Player> results = _playerService.findPlayersByPrefix(name);
    int actualLimit = results.length < count ? results.length : count;
    List<Player> limitedPlayers = results.take(actualLimit).toList();
    return limitedPlayers;
  }

  /// 신규 선수를 생성하여 DB 및 현재 세션에 추가합니다.
  void addPlayer({
    required String name,
    required String role,
    required int rate,
    required String grade,
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
      grade,
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

  /// 기존 선수를 세션에 불러오고 초기 통계를 설정합니다.
  void loadPlayer(Player player, List<ObjectId> groups, int lated) {
    addPlayerInCourt(player, groups);
    _playerService.resetStats(player, lated: lated);
    _playerService.updateGroups(player, groups);
    _playerService.updateRecentMatchDate(player);

    _saveLoadedPlayers();
    notifyListeners();
  }

  /// [playerId] 선수의 정보와 동반 그룹 관계를 갱신합니다.
  void updatePlayer({
    required ObjectId playerId,
    required String newName,
    required int newRate,
    required String newGrade,
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
      // 새 그룹에 포함되지 않는 기존 멤버들은 그룹에서 분리하므로 그룹을 비워줍니다.
      for (final oldMemberId in playerToUpdate.groups) {
        if (!newGroups.contains(oldMemberId)) {
          final Player? oldMember = _players[oldMemberId];
          if (oldMember != null) {
            _playerService.clearPlayerGroup(oldMember);
          }
        }
      }

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
      newGrade,
      newGender,
      newPlayed,
      newWaited,
      playerToUpdate.lated,
      playerToUpdate.playTime,
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

  /// 세션에서 [playerId] 선수를 제거하고 코트 및 대기열에서도 제외합니다.
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

  /// 세션의 모든 플레이어와 코트 배치를 초기화합니다.
  void clearPlayers() {
    _players.clear();
    _unassignedPlayers.clear();
    for (int i = 0; i < _assignedPlayers.length; i++) {
      _assignedPlayers[i] = List.filled(4, null);
    }
    _saveLoadedPlayers();
    notifyListeners();
  }

  /// [player]의 출석 활성화 상태를 토글합니다.
  void toggleIsActivate(Player player) {
    _playerService.updateActivate(player, !player.activate);
    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 세션 내 모든 플레이어의 경기 및 대기 통계를 초기화합니다.
  void resetPlayerStats() {
    for (Player player in _players.values) {
      _playerService.resetStats(player);
    }
    notifyListeners();
  }

  /// 대기 중인 모든 미배정 선수의 대기 횟수를 1씩 증가시킵니다.
  void incrementWaitedTimeForAllUnassignedPlayers() {
    for (var player in _unassignedPlayers) {
      _playerService.incrementWaited(player);
    }
    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 진행 코트의 개수를 [newCount]로 변경합니다.
  void updateAssignedPlayersListCount(int newCount) {
    _courtSlotService.resizeAssignedCourts(
      assignedPlayers: _assignedPlayers,
      courtStartTimes: _courtStartTimes,
      unassignedPlayers: _unassignedPlayers,
      newCount: newCount,
    );
    notifyListeners();
  }

  /// 선수를 세션 및 대기열에 등록하고 동반 그룹을 설정합니다.
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

  /// 미배정 대기열에 [player]를 추가합니다.
  void addUnassignedPlayer(Player? player) {
    if (player == null) return;
    if (_unassignedPlayers.contains(player)) return;

    _unassignedPlayers.add(player);
    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 미배정 대기열에서 [player]를 제거합니다.
  void removeUnassignedPlayer(Player player) {
    if (!_unassignedPlayers.remove(player)) return;

    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 진행 코트의 특정 슬롯에 [player]를 배치합니다.
  void addAssignedPlayer(Player? player, int courtIndex, int playerIndex) {
    if (!_courtSlotService.setPlayerAt(
      _assignedPlayers,
      courtIndex,
      playerIndex,
      player,
    )) {
      return;
    }
    _updateCourtStartTime(courtIndex);
    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 진행 코트의 특정 슬롯에서 선수를 제거하고 반환합니다.
  Player? removeAssignedPlayer(int courtIndex, int playerIndex) {
    final removed = _courtSlotService.removePlayerAt(
      _assignedPlayers,
      courtIndex,
      playerIndex,
    );
    if (removed == null) return null;

    _updateCourtStartTime(courtIndex);
    _saveLoadedPlayers();
    notifyListeners();
    return removed;
  }

  /// 대기 코트의 특정 슬롯에 [player]를 배치합니다.
  void addStandbyPlayer(Player? player, int courtIndex, int playerIndex) {
    if (!_courtSlotService.setPlayerAt(
      _standbyPlayers,
      courtIndex,
      playerIndex,
      player,
    )) {
      return;
    }
    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 대기 코트의 특정 슬롯에서 선수를 제거하고 반환합니다.
  Player? removeStandbyPlayer(int courtIndex, int playerIndex) {
    final removed = _courtSlotService.removePlayerAt(
      _standbyPlayers,
      courtIndex,
      playerIndex,
    );
    if (removed == null) return null;

    _saveLoadedPlayers();
    notifyListeners();
    return removed;
  }

  /// 드래그 앤 드롭 [data]를 바탕으로 선수를 이동 또는 맞교환(스왑)하고, 변경 사항을 1회 알림([notifyListeners])으로 일괄 반영합니다.
  void moveOrSwapPlayer({
    required PlayerDragData data,
    required String targetSectionKind,
    required int targetSectionIndex,
    required int targetSubIndex,
  }) {
    final affectedCourts = _courtSlotService.moveOrSwapPlayer(
      assignedPlayers: _assignedPlayers,
      standbyPlayers: _standbyPlayers,
      unassignedPlayers: _unassignedPlayers,
      data: data,
      targetSectionKind: targetSectionKind,
      targetSectionIndex: targetSectionIndex,
      targetSubIndex: targetSubIndex,
    );

    for (final courtIndex in affectedCourts) {
      _updateCourtStartTime(courtIndex);
    }

    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 새로운 대기 코트를 1개 추가합니다.
  void addStandByPlayers() {
    _standbyPlayers.add(List.filled(CourtConstants.capacity, null));
    _saveLoadedPlayers();
    notifyListeners();
  }

  /// [index]번째 대기 코트를 삭제하고, 포함되어 있던 선수들을 미배정 대기열로 복구합니다.
  void removeStandByPlayers(int index) {
    final removedList = _standbyPlayers.removeAt(index);
    _unassignedPlayers.addAll(removedList.whereType<Player>());

    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 첫 번째 대기 팀을 지정된 진행 코트([assignedIndex])로 승격합니다.
  bool popStandByPlayers(int assignedIndex) {
    return popStandByPlayerByIndex(assignedIndex, 0);
  }

  /// [standbyIndex]번째 대기 팀을 [assignedIndex]번째 진행 코트로 승격합니다.
  bool popStandByPlayerByIndex(int assignedIndex, int standbyIndex) {
    final success = _courtSlotService.popStandbyTeam(
      assignedPlayers: _assignedPlayers,
      standbyPlayers: _standbyPlayers,
      assignedIndex: assignedIndex,
      standbyIndex: standbyIndex,
    );
    if (!success) return false;

    _updateCourtStartTime(assignedIndex);
    _saveLoadedPlayers();
    notifyListeners();
    return true;
  }

  /// 코트의 경기를 종료하거나 비우고 선수들을 대기열로 복귀시킵니다.
  ///
  /// [played]가 1이면 경기 기록 및 플레이 시간을 누적 처리합니다.
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

    int elapsedSeconds = 0;
    if (targetCourtKind == "assigned" &&
        sectionIndex < _courtStartTimes.length) {
      final startTime = _courtStartTimes[sectionIndex];
      if (played == 1 && startTime != null) {
        elapsedSeconds = DateTime.now().difference(startTime).inSeconds;
      }
      _courtStartTimes[sectionIndex] = null;
    }

    for (int i = 0; i < playersInCourt.length; i++) {
      Player? player = playersInCourt[i];
      if (player != null) {
        if (played == 1) {
          _playerService.playedFinish(player, elapsedSeconds: elapsedSeconds);
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

  /// [sectionIndex]번째 진행 코트에 배정된 선수 목록을 반환합니다.
  List<Player> getAssignedPlayersInCourt(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) {
      return [];
    }
    return _assignedPlayers[sectionIndex]
        .where((p) => p != null)
        .cast<Player>()
        .toList();
  }

  /// [sectionIndex]번째 대기 코트에 배정된 선수 목록을 반환합니다.
  List<Player> getStandbyPlayersInCourt(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= _standbyPlayers.length) {
      return [];
    }
    return _standbyPlayers[sectionIndex]
        .where((p) => p != null)
        .cast<Player>()
        .toList();
  }

  /// 현재 코트의 선수 구성에 맞추어 추천할 대기 선수를 반환합니다.
  List<Player> getRecommendedPlayers(
    List<Player> currentPlayersOnCourt, {
    bool isClubMatch = false,
  }) {
    if (isClubMatch) {
      final Map<ObjectId, String> playerGroupLabels = {};
      for (final player in _players.values) {
        final info = getGroupInfo(player.id);
        if (info != null) {
          playerGroupLabels[player.id] = info.label;
        }
      }
      return _courtService.getRecommendedPlayersForClubMatch(
        unassignedPlayers: _unassignedPlayers,
        currentPlayersOnCourt: currentPlayersOnCourt,
        playerGroupLabels: playerGroupLabels,
      );
    }

    return _courtService.getRecommendedPlayersForCourt(
      unassignedPlayers: _unassignedPlayers,
      currentPlayersOnCourt: currentPlayersOnCourt,
    );
  }

  /// 두 진행 코트([indexA], [indexB])의 선수 배치와 시작 시각을 맞교환합니다.
  void swapAssignedCourts(int indexA, int indexB) {
    if (!_courtSlotService.swapCourts(_assignedPlayers, indexA, indexB)) return;

    DateTime? tempTime = _courtStartTimes[indexA];
    _courtStartTimes[indexA] = _courtStartTimes[indexB];
    _courtStartTimes[indexB] = tempTime;

    _saveLoadedPlayers();
    notifyListeners();
  }

  /// 두 대기 코트([indexA], [indexB])의 선수 배치를 맞교환합니다.
  void swapStandbyCourts(int indexA, int indexB) {
    if (!_courtSlotService.swapCourts(_standbyPlayers, indexA, indexB)) return;

    _saveLoadedPlayers();
    notifyListeners();
  }

  /// [sectionIndex]번째 진행 코트에 추천 선수를 자동으로 배정합니다.
  void assignNextPlayersToAssignedCourt(
    int sectionIndex, {
    bool isClubMatch = false,
  }) {
    List<Player> currentPlayers = getAssignedPlayersInCourt(sectionIndex);
    List<Player> recommendedPlayers = getRecommendedPlayers(
      currentPlayers,
      isClubMatch: isClubMatch,
    );
    addPlayersToAssignedCourt(sectionIndex, recommendedPlayers);
  }

  /// [sectionIndex]번째 대기 코트에 추천 선수를 자동으로 배정합니다.
  void assignNextPlayersToStandbyCourt(
    int sectionIndex, {
    bool isClubMatch = false,
  }) {
    List<Player> currentPlayers = getStandbyPlayersInCourt(sectionIndex);
    List<Player> recommendedPlayers = getRecommendedPlayers(
      currentPlayers,
      isClubMatch: isClubMatch,
    );
    addPlayersToStandbyCourt(sectionIndex, recommendedPlayers);
  }

  /// [sectionIndex]번째 진행 코트의 빈 슬롯에 [playersToAdd] 목록의 선수를 채웁니다.
  void addPlayersToAssignedCourt(int sectionIndex, List<Player> playersToAdd) {
    if (sectionIndex < 0 || sectionIndex >= _assignedPlayers.length) return;

    _courtSlotService.fillCourtSlots(
      court: _assignedPlayers[sectionIndex],
      unassignedPlayers: _unassignedPlayers,
      playersToAdd: playersToAdd,
    );

    _updateCourtStartTime(sectionIndex);
    _saveLoadedPlayers();
    notifyListeners();
  }

  /// [sectionIndex]번째 대기 코트의 빈 슬롯에 [playersToAdd] 목록의 선수를 채웁니다.
  void addPlayersToStandbyCourt(int sectionIndex, List<Player> playersToAdd) {
    if (sectionIndex < 0 || sectionIndex >= _standbyPlayers.length) return;

    _courtSlotService.fillCourtSlots(
      court: _standbyPlayers[sectionIndex],
      unassignedPlayers: _unassignedPlayers,
      playersToAdd: playersToAdd,
    );

    _saveLoadedPlayers();
    notifyListeners();
  }

  /// [playerId] 선수가 속한 동반 그룹의 정보([GroupInfo])를 반환합니다.
  GroupInfo? getGroupInfo(ObjectId playerId) {
    _cachedGroupInfo ??= _playerService.calculateGroupInfo(
      players: _players,
      customGroupNames: _customGroupNames,
      onObsoleteNamesFound: _saveLoadedPlayers,
    );
    return _cachedGroupInfo![playerId];
  }

  /// [memberIds] 그룹 멤버들에 대한 사용자 지정 그룹 이름을 설정합니다.
  void updateGroupName(List<ObjectId> memberIds, String newName) {
    if (memberIds.isEmpty) return;

    final String groupKey = _playerService.generateGroupKey(memberIds);

    if (newName.trim().isEmpty) {
      _customGroupNames.remove(groupKey);
    } else {
      _customGroupNames[groupKey] = newName.trim();
    }

    _saveLoadedPlayers();
    notifyListeners();
  }

  // ==========================================
  // Private Helper Methods
  // ==========================================

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

    final startTimes = await _sessionService.loadCourtStartTimes();
    _courtStartTimes.clear();
    if (startTimes.isNotEmpty) {
      _courtStartTimes.addAll(startTimes);
    } else {
      _courtStartTimes.addAll(List.filled(_assignedPlayers.length, null));
    }
  }

  Future<void> _loadInitialAssignedPlayersCount() async {
    final int initialCount = _options.numberOfSections;
    updateAssignedPlayersListCount(initialCount);
  }

  void _saveLoadedPlayers() {
    _saveDebounce?.cancel();

    final now = DateTime.now();
    // 최초 변경 발생 시점 기록 (연속 조작 중에는 최초 시점이 유지되어 최대 지연 시간 계산에 사용)
    _pendingSince ??= now;

    // 연속 조작이 계속되더라도 최대 대기 시간(1초)을 초과하면 강제 저장
    if (now.difference(_pendingSince!) >= _saveMaxWait) {
      _pendingSince = null;
      _flushSave();
      return;
    }

    // 300ms 동안 추가 조작이 없을 때 저장 수행
    _saveDebounce = Timer(_saveDebounceDuration, () {
      _pendingSince = null;
      _saveDebounce = null;
      _flushSave();
    });
  }

  Future<void> _flushSave() {
    return _sessionService.saveSession(
      players: _players,
      unassignedPlayers: _unassignedPlayers,
      assignedPlayers: _assignedPlayers,
      standbyPlayers: _standbyPlayers,
      courtStartTimes: _courtStartTimes,
      customGroupNames: _customGroupNames,
    );
  }

  Future<void> _loadCustomGroupNames() async {
    final loadedNames = await _sessionService.loadCustomGroupNames();
    _customGroupNames.clear();
    _customGroupNames.addAll(loadedNames);
  }

  void _updateCourtStartTime(int courtIndex) {
    if (courtIndex < 0 || courtIndex >= _assignedPlayers.length) return;
    _courtStartTimes[courtIndex] = _courtSlotService.calculateCourtStartTime(
      _assignedPlayers[courtIndex],
      _courtStartTimes[courtIndex],
    );
  }
}
