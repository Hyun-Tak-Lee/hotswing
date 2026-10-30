import 'package:hotswing/src/common/constants/option_constants.dart';
import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/repository/realms/realm.dart';
import 'package:realm/realm.dart';

/// 앱 운영 옵션([Options])의 Realm 데이터베이스 영속화를 관리하는 레포지토리.
class OptionsRepository {
  /// [OptionsRepository]의 싱글톤 인스턴스.
  static final OptionsRepository instance = OptionsRepository._();

  late final Realm realm;
  late Options _options;

  OptionsRepository._() {
    realm = RealmProvider.instance.realm;
  }

  /// 데이터베이스에서 옵션 객체를 조회하며, 없을 경우 기본값으로 생성하여 반환합니다.
  Options getOptions() {
    final allOptions = realm.all<Options>();
    if (allOptions.isEmpty) {
      realm.write(() {
        _options = realm.add(
          Options(
            0, // id
            OptionConstants.defaultNumberOfSections,
            OptionConstants.defaultWeight, // skillWeight
            OptionConstants.defaultWeight, // genderWeight
            OptionConstants.defaultWeight, // waitedWeight
            OptionConstants.defaultWeight, // playedWeight
            OptionConstants.defaultWeight, // playedWithWeight
            OptionConstants.defaultReserveManager,
            OptionConstants.defaultInactiveDays,
            OptionConstants.defaultRandomPoolSize,
            OptionConstants.defaultKeepScreenOn,
          ),
        );
      });
    } else {
      _options = allOptions.first;
      if (allOptions.length > 1) {
        realm.write(() {
          realm.deleteMany(allOptions.skip(1));
        });
      }
    }
    return _options;
  }

  /// Realm 데이터베이스 연결을 종료합니다.
  void close() {
    if (!realm.isClosed) {
      realm.close();
    }
  }
}
