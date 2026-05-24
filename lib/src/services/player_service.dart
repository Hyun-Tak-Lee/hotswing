import 'package:hotswing/src/models/players/player.dart';

import 'package:hotswing/src/repository/realms/players.dart';
import 'package:realm/realm.dart';

class PlayerService {
  final PlayerRepository _playerRepository = PlayerRepository.instance;

  void updateGroupPlayers(
    Map<ObjectId, Player> player,
    List<ObjectId> groups,
    ObjectId playerId,
  ) {
    final List<ObjectId> updateGroups = [playerId, ...groups];

    for (int i = 1; i < updateGroups.length; i++) {
      ObjectId currentPlayerId = updateGroups[i];
      final Player? currentPlayer = player[currentPlayerId];
      if (currentPlayer != null) {
        final List<ObjectId> otherPlayerIds = updateGroups
            .where((j) => j != currentPlayerId)
            .toList();

        _playerRepository.updatePlayer(
          player: currentPlayer,
          groups: RealmList(otherPlayerIds),
        );
      }
    }
  }

  void removeGroupPlayers(
    Map<ObjectId, Player> player,
    List<ObjectId> groups,
    ObjectId playerId,
  ) {
    final List<ObjectId> updateGroups = [playerId, ...groups];

    // 삭제 대상 당사자 본인(playerId)의 그룹 정보를 데이터베이스에서 비워줍니다.
    final Player? targetPlayer = player[playerId];
    if (targetPlayer != null) {
      _playerRepository.updatePlayer(
        player: targetPlayer,
        groups: RealmList<ObjectId>([]),
      );
    }

    // 나머지 그룹원들의 그룹 목록에서 삭제된 플레이어(playerId)를 제외합니다.
    for (int i = 1; i < updateGroups.length; i++) {
      ObjectId currentPlayerId = updateGroups[i];
      final Player? currentPlayer = player[currentPlayerId];
      if (currentPlayer != null) {
        final List<ObjectId> updatedPlayerGroups = currentPlayer.groups
            .where((id) => id != playerId)
            .toList();

        _playerRepository.updatePlayer(
          player: currentPlayer,
          groups: RealmList(updatedPlayerGroups),
        );
      }
    }
  }

  void clearPlayerGroup(Player player) {
    _playerRepository.clearPlayerGroup(player);
  }

  List<Player> findAllPlayers() {
    return _playerRepository.getAllPlayers().toList();
  }

  RealmResults<Player> findPlayersByPrefix(String name) {
    return _playerRepository.findPlayersByPrefix(name);
  }

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

  void addPlayer(Player player) {
    _playerRepository.addPlayer(player);
  }

  void deletePlayer(ObjectId id) {
    _playerRepository.deletePlayer(id);
  }

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

  void updateActivate(Player player, bool activate) {
    _playerRepository.updatePlayer(player: player, activate: activate);
  }

  void updateGroups(Player player, List<ObjectId> groups) {
    _playerRepository.updatePlayer(player: player, groups: RealmList(groups));
  }

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

  void deleteAllPlayers() {
    _playerRepository.deleteAllPlayers();
  }

  void incrementWaited(Player player) {
    _playerRepository.updatePlayer(player: player, waited: player.waited + 1);
  }

  void playedFinish(Player player, {int elapsedSeconds = 0}) {
    _playerRepository.updatePlayer(
      player: player,
      played: player.played + 1,
      waited: 0,
      playTime: player.playTime + elapsedSeconds,
    );
  }

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

  void updateRecentMatchDate(Player player) {
    _playerRepository.updatePlayer(
      player: player,
      recentMatchDate: DateTime.now(),
    );
  }

  void cleanupInactivePlayers(
    int daysThreshold,
    List<ObjectId> activePlayerIds,
  ) {
    _playerRepository.cleanupInactivePlayers(daysThreshold, activePlayerIds);
  }

  void cleanupGuestPlayers(List<ObjectId> activePlayerIds) {
    _playerRepository.cleanupGuestPlayers(activePlayerIds);
  }
}
