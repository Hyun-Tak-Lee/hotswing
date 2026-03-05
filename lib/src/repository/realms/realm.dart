import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:realm/realm.dart';

class RealmProvider {
  late Realm _realm;

  RealmProvider._() {
    final config = Configuration.local(
      [Player.schema, Options.schema],
      schemaVersion: 3,
      migrationCallback: (migration, oldSchemaVersion) {
        if (oldSchemaVersion < 1) {
          for (final obj in migration.newRealm.all<Options>()) {
            obj.reserveManager = true;
          }
        }
        if (oldSchemaVersion < 2) {
          for (final obj in migration.newRealm.all<Player>()) {
            obj.recentMatchDate = DateTime.now();
          }
        }
        if (oldSchemaVersion < 3) {
          for (final obj in migration.newRealm.all<Options>()) {
            obj.inactiveDaysThreshold = 90;
          }
        }
      },
    );
    _realm = Realm(config);
  }

  static final RealmProvider instance = RealmProvider._();

  Realm get realm => _realm;
}
