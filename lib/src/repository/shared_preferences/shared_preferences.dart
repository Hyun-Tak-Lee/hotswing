import 'package:shared_preferences/shared_preferences.dart';

class SharedProvider {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static final SharedProvider _instance = SharedProvider._internal();

  SharedProvider._internal();

  factory SharedProvider() {
    return _instance;
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await _preferences.setStringList(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    return await _preferences.getStringList(key) ?? [];
  }

  Future<void> saveString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return await _preferences.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return await _preferences.getBool(key) ?? defaultValue;
  }

  Future<void> saveInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return await _preferences.getInt(key);
  }
}
