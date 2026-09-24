import 'package:realm/realm.dart';

part 'option.realm.dart';

/// Realm 데이터베이스에 저장되는 앱 운영 옵션 엔티티 모델 스키마.
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
