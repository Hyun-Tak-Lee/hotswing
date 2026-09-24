import 'package:hotswing/src/common/constants/player_constants.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/group_info.dart';
import 'package:hotswing/src/repository/realms/players.dart';
import 'package:realm/realm.dart';

/// 선수 데이터 조작 및 비즈니스 로직(그룹 관계 분석, 정렬 등)을 전담하는 도메인 서비스.
class PlayerService {
  final PlayerRepository _playerRepository = PlayerRepository.instance;

  /// [playerId]를 포함한 [groups] 목록의 플레이어들에게 상호 그룹 참조 관계를 갱신합니다.
  void updateGroupPlayers(
    Map<ObjectId, Player> player,
    List<ObjectId> groups,
    ObjectId playerId,
  ) {
    final List<ObjectId> updateGroups = [playerId, ...groups];
    final Map<Player, List<ObjectId>> playerGroups = {};

    for (int i = 1; i < updateGroups.length; i++) {
      ObjectId currentPlayerId = updateGroups[i];
      final Player? currentPlayer = player[currentPlayerId];
      if (currentPlayer != null) {
        playerGroups[currentPlayer] = updateGroups
            .where((j) => j != currentPlayerId)
            .toList();
      }
    }

    _playerRepository.updatePlayersGroups(playerGroups);
  }

  /// [playerId]를 기존 그룹 관계에서 제거하고, 나머지 그룹원들의 그룹 목록에서도 [playerId]를 제외합니다.
  void removeGroupPlayers(
    Map<ObjectId, Player> player,
    List<ObjectId> groups,
    ObjectId playerId,
  ) {
    final List<ObjectId> updateGroups = [playerId, ...groups];
    final Map<Player, List<ObjectId>> playerGroups = {};

    // 삭제 대상 당사자 본인(playerId)의 그룹 정보를 비웁니다.
    final Player? targetPlayer = player[playerId];
    if (targetPlayer != null) {
      playerGroups[targetPlayer] = [];
    }

    // 나머지 그룹원들의 그룹 목록에서 삭제된 플레이어(playerId)를 제외합니다.
    for (int i = 1; i < updateGroups.length; i++) {
      ObjectId currentPlayerId = updateGroups[i];
      final Player? currentPlayer = player[currentPlayerId];
      if (currentPlayer != null) {
        playerGroups[currentPlayer] = currentPlayer.groups
            .where((id) => id != playerId)
            .toList();
      }
    }

    _playerRepository.updatePlayersGroups(playerGroups);
  }

  /// 단일 [player]의 동반 그룹 목록을 초기화합니다.
  void clearPlayerGroup(Player player) {
    _playerRepository.clearPlayerGroup(player);
  }

  /// 데이터베이스에 저장된 모든 선수 목록을 조회합니다.
  List<Player> findAllPlayers() {
    return _playerRepository.getAllPlayers().toList();
  }

  /// 이름 접두어([name])로 시작하는 선수 목록을 검색합니다.
  RealmResults<Player> findPlayersByPrefix(String name) {
    return _playerRepository.findPlayersByPrefix(name);
  }

  /// 식별자 목록([ids])에 해당하는 선수 목록을 조회합니다.
  List<Player?> findPlayersByIds(List<ObjectId?> ids) {
    final List<Player> findPlayers = _playerRepository
        .findPlayersByIds(ids)
        .toList();
    final Map<ObjectId, Player> playerMap = {
      for (var player in findPlayers) player.id: player,
    };
    return ids.map((id) {
      if (id == null) {
        return null;
      }
      return playerMap[id];
    }).toList();
  }

  /// 신규 [player]를 데이터베이스에 추가합니다.
  void addPlayer(Player player) {
    _playerRepository.addPlayer(player);
  }

  /// 주어진 식별자([id])의 선수를 데이터베이스에서 삭제합니다.
  void deletePlayer(ObjectId id) {
    _playerRepository.deletePlayer(id);
  }

  /// [player]의 상세 정보를 갱신합니다.
  void updatePlayer(
    Player player,
    String name,
    String role,
    int rate,
    String grade,
    String gender,
    int played,
    int waited,
    int lated,
    int playTime,
    List<ObjectId> groups,
    DateTime? recentMatchDate,
  ) {
    _playerRepository.updatePlayer(
      player: player,
      name: name,
      role: role,
      rate: rate,
      grade: grade,
      gender: gender,
      played: played,
      waited: waited,
      lated: lated,
      playTime: playTime,
      groups: RealmList(groups),
      recentMatchDate: recentMatchDate,
    );
  }

  /// [player]의 출석 활성화 상태([activate])를 갱신합니다.
  void updateActivate(Player player, bool activate) {
    _playerRepository.updatePlayer(player: player, activate: activate);
  }

  /// [player]의 동반 그룹 목록([groups])을 갱신합니다.
  void updateGroups(Player player, List<ObjectId> groups) {
    _playerRepository.updatePlayer(player: player, groups: RealmList(groups));
  }

  /// [player]의 경기 및 대기 통계를 초기화합니다.
  void resetStats(Player player, {int lated = 0}) {
    _playerRepository.updatePlayer(
      player: player,
      played: 0,
      waited: 0,
      lated: lated,
      playTime: 0,
      gamesPlayedWith: RealmMap<int>({}),
    );
  }

  /// 데이터베이스의 모든 선수 데이터를 일괄 삭제합니다.
  void deleteAllPlayers() {
    _playerRepository.deleteAllPlayers();
  }

  /// [player]의 대기 횟수를 1 증가시킵니다.
  void incrementWaited(Player player) {
    _playerRepository.updatePlayer(player: player, waited: player.waited + 1);
  }

  /// [player]의 경기 완료 처리를 수행합니다. (플레이 수 증가, 대기 수 초기화, 플레이 시간 누적)
  void playedFinish(Player player, {int elapsedSeconds = 0}) {
    _playerRepository.updatePlayer(
      player: player,
      played: player.played + 1,
      waited: 0,
      playTime: player.playTime + elapsedSeconds,
    );
  }

  /// [currentPlayer]가 코트에 함께 있었던 상대 선수들과의 경기 횟수를 누적 기록합니다.
  void addGamesPlayedWith(
    Player currentPlayer,
    List<Player?> playersInCourt,
    int games,
  ) {
    _playerRepository.updateGamesPlayedWith(
      currentPlayer: currentPlayer,
      playersInCourt: playersInCourt,
      games: games,
    );
  }

  /// [player]의 최근 경기 일시를 현재 시각으로 갱신합니다.
  void updateRecentMatchDate(Player player) {
    _playerRepository.updatePlayer(
      player: player,
      recentMatchDate: DateTime.now(),
    );
  }

  /// 지정된 일수([daysThreshold]) 이상 경기에 참여하지 않은 미참석 선수를 정리합니다.
  void cleanupInactivePlayers(
    int daysThreshold,
    List<ObjectId> activePlayerIds,
  ) {
    _playerRepository.cleanupInactivePlayers(daysThreshold, activePlayerIds);
  }

  /// 세션에 참여하지 않은 게스트(guest) 선수를 데이터베이스에서 정리합니다.
  void cleanupGuestPlayers(List<ObjectId> activePlayerIds) {
    _playerRepository.cleanupGuestPlayers(activePlayerIds);
  }

  /// [memberIds] 목록을 오름차순 정렬하여 고유한 그룹 식별 키 문자열을 생성합니다.
  String generateGroupKey(List<ObjectId> memberIds) {
    final List<ObjectId> sortedIds = List.from(memberIds)
      ..sort((a, b) => a.toString().compareTo(b.toString()));
    return sortedIds.map((id) => id.toString()).join(',');
  }

  /// [players]의 동반 그룹 관계를 BFS(너비 우선 탐색)로 분석하여 각 선수의 [GroupInfo] 맵을 계산합니다.
  ///
  /// [customGroupNames]에 등록된 사용자 지정 이름이 있으면 우선 적용하고, 없으면 알파벳("A", "B"...) 라벨을 순차 부여합니다.
  /// 더 이상 존재하지 않는 유령 그룹명이 감지되면 [onObsoleteNamesFound] 콜백을 실행하여 세션을 정리합니다.
  Map<ObjectId, GroupInfo> calculateGroupInfo({
    required Map<ObjectId, Player> players,
    required Map<String, String> customGroupNames,
    void Function()? onObsoleteNamesFound,
  }) {
    final Map<ObjectId, GroupInfo> cachedGroupInfo = {};
    final visited = <ObjectId>{};
    final List<Set<ObjectId>> groupsList = [];

    for (final player in players.values) {
      if (visited.contains(player.id)) continue;
      if (player.groups.isEmpty) continue;

      final currentGroup = <ObjectId>{};
      final queue = <ObjectId>[player.id];
      while (queue.isNotEmpty) {
        final currentId = queue.removeLast();
        if (currentGroup.contains(currentId)) continue;
        currentGroup.add(currentId);
        visited.add(currentId);

        final p = players[currentId];
        if (p != null) {
          for (final neighborId in p.groups) {
            if (!currentGroup.contains(neighborId)) {
              queue.add(neighborId);
            }
          }
        }
      }

      if (currentGroup.length > 1) {
        groupsList.add(currentGroup);
      }
    }

    // Sort groups list deterministically by the name of the first player alphabetically
    groupsList.sort((a, b) {
      final nameA =
          a
              .map((id) => players[id]?.name ?? '')
              .where((name) => name.isNotEmpty)
              .toList()
            ..sort();
      final nameB =
          b
              .map((id) => players[id]?.name ?? '')
              .where((name) => name.isNotEmpty)
              .toList()
            ..sort();
      if (nameA.isEmpty && nameB.isEmpty) return 0;
      if (nameA.isEmpty) return 1;
      if (nameB.isEmpty) return -1;
      return nameA.first.compareTo(nameB.first);
    });

    for (int i = 0; i < groupsList.length; i++) {
      final groupMembers = groupsList[i];
      final String groupKey = generateGroupKey(groupMembers.toList());

      final String label =
          customGroupNames[groupKey] ??
          (String.fromCharCode(65 + (i % 26)) +
              (i >= 26 ? '${(i ~/ 26) + 1}' : ''));
      final color =
          PlayerConstants.groupPalette[i % PlayerConstants.groupPalette.length];
      for (final id in groupMembers) {
        cachedGroupInfo[id] = GroupInfo(label: label, color: color);
      }
    }

    final Set<String> activeGroupKeys = {};
    for (final group in groupsList) {
      activeGroupKeys.add(generateGroupKey(group.toList()));
    }

    bool hasChanges = false;
    customGroupNames.removeWhere((key, value) {
      final isObsolete = !activeGroupKeys.contains(key);
      if (isObsolete) hasChanges = true;
      return isObsolete;
    });

    if (hasChanges && onObsoleteNamesFound != null) {
      onObsoleteNamesFound();
    }

    return cachedGroupInfo;
  }

  /// [players] 목록을 [criterion] 기준 및 [ascending] 방향으로 정렬한 새로운 리스트를 반환합니다.
  ///
  /// 활성화된 선수를 항상 우선 배치하며, [SortCriterion.played] 정렬 시 플레이 수 및 대기 수가 동일하면
  /// 이름 가나다순으로 결정론적 정렬을 수행하여 순서 뒤섞임을 방지합니다.
  List<Player> sortWaitingPlayers({
    required Iterable<Player> players,
    required SortCriterion criterion,
    required bool ascending,
  }) {
    final sortedList = List<Player>.from(players);
    sortedList.sort((a, b) {
      switch (criterion) {
        case SortCriterion.played:
          // 1. 활성화 여부 (활성화 우선)
          final activateCompare = (b.activate ? 1 : 0).compareTo(
            a.activate ? 1 : 0,
          );
          if (activateCompare != 0) return activateCompare;

          // 2. 플레이 수
          final playedCompare = (a.played + a.lated).compareTo(
            b.played + b.lated,
          );
          if (playedCompare != 0) {
            return ascending ? playedCompare : -playedCompare;
          }

          // 3. 대기 수
          final waitedCompare = b.waited.compareTo(a.waited);
          if (waitedCompare != 0) {
            return ascending ? waitedCompare : -waitedCompare;
          }

          // 4. Tie-breaker: 동점자 순서 보장을 위해 이름 가나다순으로 고정
          return a.name.compareTo(b.name);

        case SortCriterion.name:
          final nameCompare = a.name.compareTo(b.name);
          return ascending ? nameCompare : -nameCompare;
      }
    });
    return sortedList;
  }
}
