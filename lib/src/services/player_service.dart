import 'package:hotswing/src/models/players/player.dart';

import 'package:hotswing/src/repository/realms/players.dart';
import 'package:realm/realm.dart';

class PlayerService {
  PlayerRepository _playerRepository = PlayerRepository.instance;

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

    for (int i = 1; i < updateGroups.length; i++) {
      ObjectId currentPlayerId = updateGroups[i];
      final Player? currentPlayer = player[currentPlayerId];
      if (currentPlayer != null) {
        _playerRepository.clearPlayerGroup(currentPlayer);
      }
    }
  }

  RealmResults<Player> findPlayersByPrefix(String name) {
    return _playerRepository.findPlayersByPrefix(name);
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
    String gender,
    int played,
    int waited,
    int lated,
    List<ObjectId> groups,
  ) {
    _playerRepository.updatePlayer(
      player: player,
      name: name,
      role: role,
      rate: rate,
      gender: gender,
      played: played,
      waited: waited,
      lated: lated,
      groups: RealmList(groups),
    );
  }

  void resetStats(Player player) {
    _playerRepository.updatePlayer(
      player: player,
      played: 0,
      waited: 0,
      lated: 0,
      gamesPlayedWith: RealmMap<int>({}),
    );
  }

  void incrementWaited(Player player) {
    _playerRepository.updatePlayer(player: player, waited: player.waited + 1);
  }

  void playedFinish(Player player) {
    _playerRepository.updatePlayer(
      player: player,
      played: player.played + 1,
      waited: 0,
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
}
