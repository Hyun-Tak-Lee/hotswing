import 'package:flutter/foundation.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/realm.dart';
import 'package:realm/realm.dart';

class PlayerRepository {
  late Realm _realm;

  PlayerRepository._() {
    _realm = RealmProvider.instance.realm;
  }

  static final PlayerRepository instance = PlayerRepository._();

  RealmResults<Player> findPlayersByPrefix(String name) {
    final results = _realm.query<Player>("name BEGINWITH \$0", [name]);
    return results;
  }

  void addPlayer(Player player) {
    try {
      _realm.write(() {
        _realm.add(player);
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void updatePlayer({
    required Player player,
    String? name,
    String? role,
    int? rate,
    String? gender,
    int? played,
    int? waited,
    int? lated,
    bool? activate,
    RealmMap<int>? gamesPlayedWith,
    RealmList<ObjectId>? groups,
  }) {
    try {
      _realm.write(() {
        if (name != null) {
          player.name = name;
        }
        if (role != null) {
          player.role = role;
        }
        if (rate != null) {
          player.rate = rate;
        }
        if (gender != null) {
          player.gender = gender;
        }
        if (played != null) {
          player.played = played;
        }
        if (waited != null) {
          player.waited = waited;
        }
        if (lated != null) {
          player.lated = lated;
        }
        if (activate != null) {
          player.activate = activate;
        }
        if (gamesPlayedWith != null) {
          player.gamesPlayedWith.clear();
          player.gamesPlayedWith.addAll(gamesPlayedWith);
        }
        if (groups != null) {
          player.groups.clear();
          player.groups.addAll(groups);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void updateGamesPlayedWith({
    required Player currentPlayer,
    required List<Player?> playersInCourt,
    required int games,
  }) {
    try {
      _realm.write(() {
        for (Player? otherPlayerInCourt in playersInCourt) {
          if (otherPlayerInCourt != null &&
              otherPlayerInCourt.id != currentPlayer.id) {
            final otherPlayerId = otherPlayerInCourt.id.toString();
            final currentGames =
                currentPlayer.gamesPlayedWith[otherPlayerId] ?? 0;
            currentPlayer.gamesPlayedWith[otherPlayerId] = currentGames + games;
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void deletePlayer(ObjectId id) {
    try {
      _realm.write(() {
        final player = _realm.find<Player>(id);
        if (player != null) {
          _realm.delete(player);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void clearPlayerGroup(Player player) {
    try {
      _realm.write(() {
        player.groups.clear();
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  RealmResults<Player> getAllPlayers() {
    return _realm.all<Player>();
  }
}
