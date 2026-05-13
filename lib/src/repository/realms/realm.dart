import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:realm/realm.dart';

class RealmProvider {
  late Realm _realm;

  RealmProvider._() {
    final config = Configuration.local(
      [Player.schema, Options.schema],
      schemaVersion: 6,
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
        if (oldSchemaVersion < 4) {
          for (final obj in migration.newRealm.all<Player>()) {
            obj.grade = rateToSkillLevel(obj.rate);
          }
        }
        if (oldSchemaVersion < 5) {
          for (final obj in migration.newRealm.all<Options>()) {
            obj.randomPoolSize = 1;
          }
        }
        if (oldSchemaVersion < 6) {
          for (final obj in migration.newRealm.all<Player>()) {
            obj.playTime = 0;
          }
        }
      },
    );
    _realm = Realm(config);
  }

  static final RealmProvider instance = RealmProvider._();

  Realm get realm => _realm;
}
