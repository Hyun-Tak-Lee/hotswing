import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 암호화 관련 유틸리티 클래스
class CryptoUtils {
  /// SHA-256 해시 생성
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 기기 ID + 비밀번호 암호화 (기기 묶임용)
  ///
  /// [deviceId] 기기 고유 ID (Android: androidInfo.id, iOS: identifierForVendor)
  /// [password] 활성화 비밀번호
  /// [secretKey] 암호화에 사용할 시크릿 키
  ///
  /// 반환: "encrypted:" 접두사가 붙은 암호화된 해시 값
  ///
  /// 예시:
  /// - Android deviceId: "abc123def456789"
  /// - password: "hotswing2026"
  /// - 반환: "encrypted:9f86d081884c7d659a2feaa0c55ad015..."
  static String encryptDeviceId(
    String deviceId,
    String password,
    String secretKey,
  ) {
    final combined = '$deviceId:$password:$secretKey';
    final hash = generateHash(combined);
    return 'encrypted:$hash';
  }

  /// 암호화된 기기 ID + 비밀번호 검증 (기기 묶임용)
  ///
  /// [deviceId] 현재 기기 ID
  /// [password] 활성화 비밀번호
  /// [encryptedDeviceId] 저장된 암호화된 값
  /// [secretKey] 복호화에 사용할 시크릿 키
  ///
  /// 반환: 현재 기기 ID + 비밀번호가 암호화된 값과 일치하면 true
  ///
  /// 예시:
  /// - 기기 A에서 활성화: encrypt("abc123", "hotswing2026") → 저장
  /// - 기기 A에서 실행: verify("abc123", "hotswing2026", encrypted) → true ✓
  /// - 기기 B에서 실행: verify("xyz789", "hotswing2026", encrypted) → false ✗
  static bool verifyDeviceId(
    String deviceId,
    String password,
    String encryptedDeviceId,
    String secretKey,
  ) {
    final expectedEncrypted = encryptDeviceId(deviceId, password, secretKey);
    return expectedEncrypted == encryptedDeviceId;
  }
}
