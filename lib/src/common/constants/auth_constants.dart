/// 앱 활성화 및 관리자 인증 관련 도메인 상수
abstract final class AuthConstants {
  /// 마스터 비밀번호 해시에 사용하는 PBKDF2 반복 횟수
  ///
  /// 변경 시 `tool/hash_password.dart`로 `.env` 해시를 다시 생성해야 합니다.
  static const int pbkdf2Iterations = 300000;

  /// 관리자 비밀번호 최소 글자 수
  static const int minManagerPasswordLength = 4;

  /// `.env` 마스터 비밀번호 salt 키
  static const String envPasswordSalt = 'MASTER_PASSWORD_SALT';

  /// `.env` 마스터 비밀번호 해시 키
  static const String envPasswordHash = 'MASTER_PASSWORD_HASH';

  /// 활성화한 기기 ID SharedPreferences 저장 키
  static const String deviceIdKey = 'device_id';

  /// 기기 ID 결합 값 SharedPreferences 저장 키
  static const String encryptedDeviceIdKey = 'encrypted_device_id';

  /// 활성화 여부 SharedPreferences 저장 키
  static const String isActivatedKey = 'is_activated';

  /// 활성화 시각 SharedPreferences 저장 키
  static const String activationTimestampKey = 'activation_timestamp';

  /// 관리자 비밀번호 해시 SharedPreferences 저장 키
  static const String managerPasswordHashKey = 'manager_password_hash';

  /// 관리자 비밀번호 salt SharedPreferences 저장 키
  static const String managerPasswordSaltKey = 'manager_password_salt';
}
