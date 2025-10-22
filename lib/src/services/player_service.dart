import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/players.dart';

class PlayerService {
  PlayerRepository _playerRepository = PlayerRepository.instance;

  void updateGroupPlayers(
    Map<int, Player> player,
    List<int> groups,
    int playerId,
  ) {
    final List<int> updateGroups = [playerId, ...groups];

    for (int i = 1; i < updateGroups.length; i++) {
      int currentPlayerId = updateGroups[i];
      final Player? currentPlayer = player[currentPlayerId];
      if (currentPlayer != null) {
        final List<int> otherPlayerIds = updateGroups
            .where((j) => j != currentPlayerId)
            .toList();

        currentPlayer.groups.clear();
        currentPlayer.groups.addAll(otherPlayerIds);
      }
    }
  }

  void removeGroupPlayers(
    Map<int, Player> player,
    List<int> groups,
    int playerId,
  ){
    final List<int> updateGroups = [playerId, ...groups];

    for (int i = 1; i < updateGroups.length; i++) {
      int currentPlayerId = updateGroups[i];
      final Player? currentPlayer = player[currentPlayerId];
      if (currentPlayer != null) {
        currentPlayer.groups.clear();
      }
    }
  }
}
