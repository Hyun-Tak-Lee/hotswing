import 'package:hotswing/src/models/options/option.dart';
import 'package:hotswing/src/repository/realms/realm.dart';
import 'package:realm/realm.dart';

class OptionsRepository {
  late Realm realm;
  late Options _options;

  OptionsRepository._() {
    realm = RealmProvider.instance.realm;
  }

  static final OptionsRepository instance = OptionsRepository._();

  Options getOptions() {
    final allOptions = realm.all<Options>();
    if (allOptions.isEmpty) {
      realm.write(() {
        _options = realm.add(
          Options(
            0,
            // id
            3,
            // numberOfSections
            1.0,
            // skillWeight
            1.0,
            // genderWeight
            1.0,
            // waitedWeight
            1.0,
            // playedWeight
            1.0, // playedWithWeight
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

  void close() {
    if (!realm.isClosed) {
      realm.close();
    }
  }
}
