import 'package:realm/realm.dart';

part 'player.realm.dart';

/// Realm 데이터베이스에 저장되는 선수 엔티티 모델 스키마.
@RealmModel()
class _Player {
  @PrimaryKey()
  late ObjectId id;
  @Indexed()
  late String name;
  late String role;
  late int rate;
  late String grade;
  late String gender;
  int played = 0;
  int waited = 0;
  int lated = 0;
  int playTime = 0;
  bool activate = true;
  late Map<String, int> gamesPlayedWith;
  late List<ObjectId> groups;
  @Indexed()
  DateTime? recentMatchDate;
}
