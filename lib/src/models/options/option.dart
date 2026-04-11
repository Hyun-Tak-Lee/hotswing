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
  late bool reserveManager;
  late int inactiveDaysThreshold; // 비활성 플레이어 자동 삭제 기간 (일)
  late int randomPoolSize; // 매칭 시 랜덤 선택 범위 (1~5)
}
