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
