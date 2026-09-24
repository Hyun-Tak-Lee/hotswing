import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:realm/realm.dart';

/// Realm 데이터베이스 인스턴스를 초기화하고 스키마 마이그레이션을 관리하는 싱글톤 제공자.
class RealmProvider {
  /// [RealmProvider]의 싱글톤 인스턴스.
  static final RealmProvider instance = RealmProvider._();

  late final Realm _realm;

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

  /// 활성화된 Realm 데이터베이스 인스턴스를 반환합니다.
  Realm get realm => _realm;
}
