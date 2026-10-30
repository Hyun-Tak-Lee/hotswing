import 'dart:io';
import 'dart:isolate';
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

  // .env 키
  static const String _envPasswordSalt = 'MASTER_PASSWORD_SALT';
  static const String _envPasswordHash = 'MASTER_PASSWORD_HASH';

  ActivationService._internal();

  factory ActivationService() {
    return _instance;
  }

  /// 기기 고유 ID 가져오기
  ///
  /// Android: androidId
  /// iOS: identifierForVendor
  ///
  /// 일시적으로 조회할 수 없는 경우(플랫폼 오류, 재부팅 직후 잠금 상태의 iOS 등) null을 반환합니다.
  Future<String?> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id; // Android ID
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      } else {
        // Android, iOS 이외의 플랫폼은 지원하지 않음
        return 'unsupported_platform';
      }
    } catch (e) {
      return null;
    }
  }

  /// 저장된 기기 ID 가져오기
  Future<String?> getSavedDeviceId() async {
    return await _sharedProvider.getString(_keyDeviceId);
  }

  /// 활성화 여부 확인
  Future<bool> isActivated() async {
    return await _sharedProvider.getBool(_keyIsActivated, defaultValue: false);
  }

  /// 활성화 타임스탬프 가져오기
  Future<int?> getActivationTimestamp() async {
    return await _sharedProvider.getInt(_keyActivationTimestamp);
  }

  /// 마스터 비밀번호로 활성화
  ///
  /// [password] 사용자가 입력한 비밀번호
  ///
  /// 반환: 활성화 성공 시 true, 실패 시 false
  Future<bool> activateWithPassword(String password) async {
    try {
      // 입력한 비밀번호의 해시와 .env의 마스터 비밀번호 해시 비교
      if (await verifyMasterPassword(password)) {
        final passwordHash = dotenv.env[_envPasswordHash]!.toLowerCase();

        // 현재 기기 ID 가져오기
        final deviceId = await getDeviceId();
        if (deviceId == null) {
          return false;
        }

        // 기기 ID를 마스터 비밀번호 해시로 서명하여 결합
        final encryptedDeviceId = CryptoUtils.bindDeviceId(
          deviceId: deviceId,
          passwordHash: passwordHash,
        );

        // 활성화 처리 - 암호화된 기기 ID 저장
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

  /// 입력한 [password]가 마스터 비밀번호와 일치하는지 확인
  ///
  /// `.env`의 salt로 PBKDF2 해시를 계산하여 저장된 해시와 비교합니다.
  /// 계산 비용이 커서 UI가 멈추지 않도록 별도 Isolate에서 수행합니다.
  Future<bool> verifyMasterPassword(String password) async {
    final salt = dotenv.env[_envPasswordSalt];
    final passwordHash = dotenv.env[_envPasswordHash];
    if (salt == null || salt.isEmpty) return false;
    if (passwordHash == null || passwordHash.isEmpty) return false;

    final input = password.trim();
    try {
      final inputHash = await Isolate.run(
        () => CryptoUtils.pbkdf2Sha256(password: input, saltHex: salt),
      );
      return inputHash == passwordHash.toLowerCase();
    } catch (e) {
      // salt 형식 오류 등 .env 설정 문제는 검증 실패로 처리
      return false;
    }
  }

  /// 기기 검증 (복제 방지)
  ///
  /// 저장된 결합 값과 현재 기기 ID + 마스터 비밀번호 해시가 일치하는지 확인
  ///
  /// 반환: 일치하면 true (정상), 불일치하면 false (다른 기기로 복제됨)
  ///
  /// 예시:
  /// - Android 기기 A에서 활성화 → bind(deviceId, passwordHash) 저장
  /// - 기기 A에서 실행 → verify(deviceId, passwordHash) 일치 ✓ 앱 실행
  /// - 기기 B로 SharedPreferences 복사 → verify 불일치 ✗ 재활성화 요구
  /// - 이전 방식(평문 비밀번호)으로 저장된 값 → 불일치 ✗ 1회 재활성화 요구
  Future<bool> verifyDevice() async {
    try {
      // 활성화되었는지 확인
      if (!(await isActivated())) {
        return false;
      }

      // 저장된 암호화 값 가져오기
      final encryptedDeviceId = await _sharedProvider.getString(
        _keyEncryptedDeviceId,
      );
      if (encryptedDeviceId == null) {
        // 이전 버전에서 활성화된 경우 - 재활성화 필요
        await _sharedProvider.saveBool(_keyIsActivated, false);
        return false;
      }

      // 현재 기기 ID 가져오기
      final currentDeviceId = await getDeviceId();
      if (currentDeviceId == null) {
        // 기기 ID를 일시적으로 조회할 수 없는 경우 활성화 상태는 유지
        return false;
      }

      // .env에서 마스터 비밀번호 해시 가져오기
      final passwordHash = dotenv.env[_envPasswordHash];
      if (passwordHash == null || passwordHash.isEmpty) {
        return false;
      }

      // 검증 (기기 ID + 마스터 비밀번호 해시 함께 검증)
      final isValid = CryptoUtils.verifyDeviceBinding(
        deviceId: currentDeviceId,
        passwordHash: passwordHash.toLowerCase(),
        savedBinding: encryptedDeviceId,
      );

      if (isValid) {
        return true;
      } else {
        // 불일치 시 활성화 해제
        await _sharedProvider.saveBool(_keyIsActivated, false);
        return false;
      }
    } catch (e) {
      // 일시적 오류로 활성화가 해제되지 않도록 이번 실행만 검증 실패 처리
      return false;
    }
  }

  /// 활성화 정보 조회 (디버그/관리 목적)
  Future<Map<String, dynamic>> getActivationInfo() async {
    final deviceId = await getDeviceId();
    final savedDeviceId = await getSavedDeviceId();
    final isActivated = await this.isActivated();
    final timestamp = await getActivationTimestamp();

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
