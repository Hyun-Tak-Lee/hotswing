import 'package:hotswing/src/models/options/option.dart';
import 'package:realm/realm.dart';

class OptionsRepository {
  late Realm _realm;
  late Options _options;

  Options getOptions() {
    final config = Configuration.local([Options.schema]);
    _realm = Realm(config);

    final allOptions = _realm.all<Options>();
    if (allOptions.isEmpty) {
      _realm.write(() {
        _options = _realm.add(Options(
          0, // id
          3, // numberOfSections
          1.0, // skillWeight
          1.0, // genderWeight
          1.0, // waitedWeight
          1.0, // playedWeight
          1.0, // playedWithWeight
        ));
      });
    } else {
      _options = allOptions.first;
      if (allOptions.length > 1) {
        _realm.write(() {
          _realm.deleteMany(allOptions.skip(1));
        });
      }
    }
    return _options;

  }
}