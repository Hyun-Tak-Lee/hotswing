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
    final results = _realm.query<Player>("name BEGINSWITH \$0", [name]);
    return results;
  }

  RealmResults<Player> findPlayersByIds(List<ObjectId?> ids) {
    final results = _realm.query<Player>("id IN \$0", [ids]);
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
    DateTime? recentMatchDate,
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
        if (recentMatchDate != null) {
          player.recentMatchDate = recentMatchDate;
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
            final otherPlayerId = otherPlayerInCourt.id.hexString;
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

  void deleteAllPlayers() {
    try {
      _realm.write(() {
        _realm.deleteAll<Player>();
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  RealmResults<Player> getPlayers({
    required String query,
    required List<Object> args,
    String? sortField,
    bool sortAscending = true,
  }) {
    String finalQuery = query.isEmpty ? 'TRUEPREDICATE' : query;

    if (sortField != null && sortField.isNotEmpty) {
      finalQuery += ' SORT($sortField ${sortAscending ? 'ASC' : 'DESC'})';
    }

    return _realm.query<Player>(finalQuery, args);
  }

  void deletePlayers(List<ObjectId> ids) {
    try {
      _realm.write(() {
        final playersToDelete = _realm.query<Player>("id IN \$0", [ids]);
        _realm.deleteMany(playersToDelete);
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

  void cleanupInactivePlayers(
    int daysThreshold,
    List<ObjectId> activePlayerIds,
  ) {
    try {
      final thresholdDate = DateTime.now().subtract(
        Duration(days: daysThreshold),
      );
      final inactivePlayers = _realm.query<Player>(
        "(recentMatchDate == nil || recentMatchDate < \$0) AND NOT (id IN \$1)",
        [thresholdDate, activePlayerIds],
      );

      if (inactivePlayers.isNotEmpty) {
        _realm.write(() {
          _realm.deleteMany(inactivePlayers);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Cleanup error: \$e");
      }
    }
  }

  void cleanupGuestPlayers(List<ObjectId> activePlayerIds) {
    try {
      final guestPlayers = _realm.query<Player>(
        "role == 'guest' AND NOT (id IN \$0)",
        [activePlayerIds],
      );

      if (guestPlayers.isNotEmpty) {
        _realm.write(() {
          _realm.deleteMany(guestPlayers);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Cleanup guest error: \$e");
      }
    }
  }
}
