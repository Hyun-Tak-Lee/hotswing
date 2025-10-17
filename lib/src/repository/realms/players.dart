import 'package:flutter/foundation.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:realm/realm.dart';

class PlayerRepository {
  late Realm _realm;

  PlayerRepository._() {
    final config = Configuration.local([Player.schema]);
    _realm = Realm(config);
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
      if(kDebugMode){
        print(e);
      }
    }
  }

  void deletePlayer(int id) {
    try {
      _realm.write(() {
        final player = _realm.find<Player>(id);
        if (player != null) {
          _realm.delete(player);
        }
      });
    } catch (e) {
      if(kDebugMode){
        print(e);
      }
    }
  }

  RealmResults<Player> getAllPlayers() {
    return _realm.all<Player>();
  }

  void close() {
    if(!_realm.isClosed){
      _realm.close();
    }
  }
}
