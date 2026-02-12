import 'package:shared_preferences/shared_preferences.dart';

class SharedProvider {
  late final SharedPreferences _preferences;
  static final SharedProvider _instance = SharedProvider._internal();

  SharedProvider._internal();

  factory SharedProvider() {
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

  Future<bool> saveString(String key, String value) async {
    return _preferences.setString(key, value);
  }

  String? getString(String key) {
    return _preferences.getString(key);
  }

  Future<bool> saveBool(String key, bool value) async {
    return _preferences.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences.getBool(key) ?? defaultValue;
  }

  Future<bool> saveInt(String key, int value) async {
    return _preferences.setInt(key, value);
  }

  int? getInt(String key) {
    return _preferences.getInt(key);
  }
}
