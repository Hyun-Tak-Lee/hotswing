import 'package:flutter/foundation.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/realm.dart';
import 'package:realm/realm.dart';

/// Realm 데이터베이스의 [Player] 엔티티에 대한 CRUD 및 쿼리 연산을 전담하는 레포지토리.
class PlayerRepository {
  /// [PlayerRepository]의 싱글톤 인스턴스.
  static final PlayerRepository instance = PlayerRepository._();

  late final Realm _realm;

  PlayerRepository._() {
    _realm = RealmProvider.instance.realm;
  }

  /// 데이터베이스의 모든 선수 목록을 조회합니다.
  RealmResults<Player> getAllPlayers() {
    return _realm.all<Player>();
  }

  /// 이름 접두어([name])로 시작하는 선수 목록을 검색합니다.
  RealmResults<Player> findPlayersByPrefix(String name) {
    final results = _realm.query<Player>("name BEGINSWITH \$0", [name]);
    return results;
  }

  /// 식별자 목록([ids])에 포함된 선수들을 조회합니다.
  RealmResults<Player> findPlayersByIds(List<ObjectId?> ids) {
    final results = _realm.query<Player>("id IN \$0", [ids]);
    return results;
  }

  /// 조건식([query]), 인자([args]) 및 정렬 옵션을 적용하여 선수 목록을 필터링 조회합니다.
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

  /// 신규 [player]를 데이터베이스에 추가합니다.
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

  /// [player]의 속성들을 선택적으로 갱신합니다.
  void updatePlayer({
    required Player player,
    String? name,
    String? role,
    int? rate,
    String? grade,
    String? gender,
    int? played,
    int? waited,
    int? lated,
    int? playTime,
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
        if (grade != null) {
          player.grade = grade;
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
        if (playTime != null) {
          player.playTime = playTime;
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

  /// 여러 플레이어의 groups를 단일 트랜잭션으로 갱신합니다.
  void updatePlayersGroups(Map<Player, List<ObjectId>> playerGroups) {
    if (playerGroups.isEmpty) return;
    try {
      _realm.write(() {
        for (final entry in playerGroups.entries) {
          entry.key.groups.clear();
          entry.key.groups.addAll(entry.value);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  /// [currentPlayer]와 코트에 함께 배정된 선수들 간의 경기 횟수를 누적 갱신합니다.
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

  /// [player]의 동반 그룹 목록을 비웁니다.
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

  /// 주어진 식별자([id])의 선수를 데이터베이스에서 삭제합니다.
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

  /// 식별자 목록([ids])에 해당하는 선수들을 일괄 삭제합니다.
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

  /// 모든 선수 데이터를 데이터베이스에서 일괄 삭제합니다.
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

  /// 지정 기간([daysThreshold]) 동안 참여 기록이 없으며 현재 활성 목록에 포함되지 않은 선수를 정리합니다.
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

  /// 현재 활성 세션에 포함되지 않은 게스트(role == 'guest') 선수를 삭제합니다.
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
