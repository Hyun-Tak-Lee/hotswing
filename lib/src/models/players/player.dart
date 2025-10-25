import 'package:realm/realm.dart';

part 'player.realm.dart';

@RealmModel()
class _Player {
  @PrimaryKey()
  late ObjectId id;
  late String name;
  late String role;
  late int rate;
  late String gender;
  int played = 0;
  int waited = 0;
  int lated = 0;
  bool activate = true;
  late Map<String, int> gamesPlayedWith;
  late List<ObjectId> groups;
}