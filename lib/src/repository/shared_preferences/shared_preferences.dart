import 'package:shared_preferences/shared_preferences.dart';

class SharedProvider {
  late final SharedPreferences _preferences;
  static final SharedProvider _instance = SharedProvider._internal();

  SharedProvider._internal();

  factory SharedProvider(){
    return _instance;
  }

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<bool> saveStringList(String key, List<String> value) async {
    return _preferences.setStringList(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    return _preferences.getStringList(key) ?? [];
  }
}
