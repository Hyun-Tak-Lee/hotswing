import 'package:realm/realm.dart';

part 'player.realm.dart';

@RealmModel()
class _Player {
  @PrimaryKey()
  late int id;
  late String name;
  late String role;
  late int rate;
  late String gender;
  int played = 0;
  int waited = 0;
  int lated = 0;
  Map<String, int> gamesPlayedWith = const {};
  List<int> groups = const [];
}
