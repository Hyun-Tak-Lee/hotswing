import 'package:realm/realm.dart';

// Realm 에 저장될 데이터 모델
part 'option.realm.dart';

@RealmModel()
class _Options {
  @PrimaryKey()
  late int id; // Realm 객체를 식별하기 위한 기본 키

  late int numberOfSections;
  late double skillWeight;
  late double genderWeight;
  late double waitedWeight;
  late double playedWeight;
  late double playedWithWeight;
}
