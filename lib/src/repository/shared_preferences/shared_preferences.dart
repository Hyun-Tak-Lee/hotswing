import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferencesAsync를 래핑하여 로컬 키-값 저장소 비동기 접근을 제공하는 싱글톤 클래스.
class SharedProvider {
  static final SharedProvider _instance = SharedProvider._internal();

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  SharedProvider._internal();

  /// [SharedProvider] 싱글톤 인스턴스를 반환하는 팩토리 생성자.
  factory SharedProvider() {
    return _instance;
  }

  /// 문자열 리스트를 로컬 저장소에 저장합니다.
  Future<void> saveStringList(String key, List<String> value) async {
    await _preferences.setStringList(key, value);
  }

  /// 로컬 저장소에서 문자열 리스트를 조회합니다. 없을 경우 빈 리스트를 반환합니다.
  Future<List<String>> getStringList(String key) async {
    return await _preferences.getStringList(key) ?? [];
  }

  /// 문자열을 로컬 저장소에 저장합니다.
  Future<void> saveString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  /// 로컬 저장소에서 문자열을 조회합니다.
  Future<String?> getString(String key) async {
    return await _preferences.getString(key);
  }

  /// 불리언 값을 로컬 저장소에 저장합니다.
  Future<void> saveBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  /// 로컬 저장소에서 불리언 값을 조회합니다. 없을 경우 [defaultValue]를 반환합니다.
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return await _preferences.getBool(key) ?? defaultValue;
  }

  /// 정수 값을 로컬 저장소에 저장합니다.
  Future<void> saveInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  /// 로컬 저장소에서 정수 값을 조회합니다.
  Future<int?> getInt(String key) async {
    return await _preferences.getInt(key);
  }
}
