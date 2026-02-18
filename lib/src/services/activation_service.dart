import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:hotswing/src/common/utils/security/crypto_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 라이센스 인증 서비스
///
/// 마스터 비밀번호를 통한 앱 활성화 관리
class ActivationService {
  static final ActivationService _instance = ActivationService._internal();
  final SharedProvider _sharedProvider = SharedProvider();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // SharedPreferences 키
  static const String _keyDeviceId = 'device_id';
  static const String _keyEncryptedDeviceId = 'encrypted_device_id';
  static const String _keyIsActivated = 'is_activated';
  static const String _keyActivationTimestamp = 'activation_timestamp';

  ActivationService._internal();

  factory ActivationService() {
    return _instance;
  }

  /// 기기 고유 ID 가져오기
  ///
  /// Android: androidId
  /// iOS: identifierForVendor
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_device';
      } else {
        // Android, iOS 이외의 플랫폼은 지원하지 않음
        return 'unsupported_platform';
      }
    } catch (e) {
      return 'error_getting_device_id';
    }
  }

  /// 저장된 기기 ID 가져오기
  String? getSavedDeviceId() {
    return _sharedProvider.getString(_keyDeviceId);
  }

  /// 활성화 여부 확인
  bool isActivated() {
    return _sharedProvider.getBool(_keyIsActivated, defaultValue: false);
  }

  /// 활성화 타임스탬프 가져오기
  int? getActivationTimestamp() {
    return _sharedProvider.getInt(_keyActivationTimestamp);
  }

  /// 마스터 비밀번호로 활성화
  ///
  /// [password] 사용자가 입력한 비밀번호
  ///
  /// 반환: 활성화 성공 시 true, 실패 시 false
  Future<bool> activateWithPassword(String password) async {
    try {
      // .env에서 마스터 비밀번호와 시크릿 키 가져오기
      final masterPassword = dotenv.env['MASTER_PASSWORD'];
      final secretKey = dotenv.env['SECRET_KEY'];

      if (masterPassword == null) {
        return false;
      }

      if (secretKey == null) {
        return false;
      }

      // 입력한 비밀번호와 마스터 비밀번호 비교
      if (password.trim() == masterPassword) {
        // 1. 현재 기기 ID 가져오기
        final deviceId = await getDeviceId();

        // 2. 기기 ID + 비밀번호 함께 암호화
        final encryptedDeviceId = CryptoUtils.encryptDeviceId(
          deviceId,
          masterPassword, // 비밀번호 포함 ⭐
          secretKey,
        );

        // 3. 활성화 처리 - 암호화된 기기 ID 저장
        await _sharedProvider.saveString(_keyDeviceId, deviceId);
        await _sharedProvider.saveString(
          _keyEncryptedDeviceId,
          encryptedDeviceId,
        );
        await _sharedProvider.saveBool(_keyIsActivated, true);
        await _sharedProvider.saveInt(
          _keyActivationTimestamp,
          DateTime.now().millisecondsSinceEpoch,
        );

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// 기기 검증 (복제 방지)
  ///
  /// 저장된 암호화된 값과 현재 기기 ID + 비밀번호가 일치하는지 확인
  ///
  /// 반환: 일치하면 true (정상), 불일치하면 false (다른 기기로 복제됨)
  ///
  /// 예시:
  /// - Android 기기 A에서 활성화 → encrypt(deviceId, password) 저장
  /// - 기기 A에서 실행 → verify(deviceId, password) 일치 ✓ 앱 실행
  /// - 기기 B로 SharedPreferences 복사 → verify 불일치 ✗ 재활성화 요구
  Future<bool> verifyDevice() async {
    try {
      // 1. 활성화되었는지 확인
      if (!isActivated()) {
        return false;
      }

      // 2. 저장된 암호화 값 가져오기
      final encryptedDeviceId = _sharedProvider.getString(
        _keyEncryptedDeviceId,
      );
      if (encryptedDeviceId == null) {
        // 이전 버전에서 활성화된 경우 - 재활성화 필요
        await _sharedProvider.saveBool(_keyIsActivated, false);
        return false;
      }

      // 3. 현재 기기 ID 가져오기
      final currentDeviceId = await getDeviceId();

      // 4. .env에서 마스터 비밀번호와 시크릿 키 가져오기
      final masterPassword = dotenv.env['MASTER_PASSWORD'];
      final secretKey = dotenv.env['SECRET_KEY'];

      if (masterPassword == null || secretKey == null) {
        return false;
      }

      // 5. 검증 (기기 ID + 비밀번호 함께 검증) ⭐
      final isValid = CryptoUtils.verifyDeviceId(
        currentDeviceId,
        masterPassword, // 비밀번호 포함 ⭐
        encryptedDeviceId,
        secretKey,
      );

      if (isValid) {
        return true;
      } else {
        // 불일치 시 활성화 해제
        await _sharedProvider.saveBool(_keyIsActivated, false);
        return false;
      }
    } catch (e) {
      // 에러 시 안전을 위해 재활성화 요구
      await _sharedProvider.saveBool(_keyIsActivated, false);
      return false;
    }
  }

  /// 활성화 정보 조회 (디버그/관리 목적)
  Future<Map<String, dynamic>> getActivationInfo() async {
    final deviceId = await getDeviceId();
    final savedDeviceId = getSavedDeviceId();
    final isActivated = this.isActivated();
    final timestamp = getActivationTimestamp();

    return {
      'current_device_id': deviceId,
      'saved_device_id': savedDeviceId,
      'is_activated': isActivated,
      'activation_timestamp': timestamp,
      'activation_date': timestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(timestamp).toString()
          : null,
    };
  }

  /// 활성화 초기화 (테스트/디버그 목적)
  ///
  /// 주의: 프로덕션에서는 사용하지 말 것
  Future<void> resetActivation() async {
    await _sharedProvider.saveBool(_keyIsActivated, false);
  }
}
