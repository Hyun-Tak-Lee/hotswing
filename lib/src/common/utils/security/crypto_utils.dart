import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// 암호화 관련 유틸리티 클래스
class CryptoUtils {
  /// SHA-256 해시 생성
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// 암호학적으로 안전한 난수 기반 salt 생성 (16바이트, 16진수 문자열)
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// salt를 결합한 SHA-256 해시 생성
  static String generateSaltedHash(String input, String salt) {
    return generateHash('$salt:$input');
  }

  /// 마스터 비밀번호 해시에 사용하는 PBKDF2 반복 횟수
  static const int pbkdf2Iterations = 300000;

  /// PBKDF2-HMAC-SHA256 키 유도 (32바이트, 16진수 문자열)
  ///
  /// [saltHex] 16진수 문자열 salt (바이트로 디코딩하여 사용)
  ///
  /// Python `hashlib.pbkdf2_hmac('sha256', password, bytes.fromhex(saltHex), iterations)`와 동일한 결과를 반환합니다.
  static String pbkdf2Sha256({
    required String password,
    required String saltHex,
    int iterations = pbkdf2Iterations,
  }) {
    final hmac = Hmac(sha256, utf8.encode(password));
    // 출력 길이(32바이트)가 SHA-256 블록 하나이므로 블록 인덱스는 1 고정
    var block = hmac.convert([..._hexToBytes(saltHex), 0, 0, 0, 1]).bytes;
    final result = List<int>.of(block);
    for (int i = 1; i < iterations; i++) {
      block = hmac.convert(block).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }
    return result.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// 기기 ID를 마스터 비밀번호 해시로 서명한 결합 값 생성 (기기 묶임용)
  ///
  /// [deviceId] 기기 고유 ID (Android: androidInfo.id, iOS: identifierForVendor)
  /// [passwordHash] `.env`의 마스터 비밀번호 해시
  ///
  /// 반환: "v2:" 접두사가 붙은 HMAC-SHA256 값
  static String bindDeviceId({
    required String deviceId,
    required String passwordHash,
  }) {
    final hmac = Hmac(sha256, utf8.encode(passwordHash));
    return 'v2:${hmac.convert(utf8.encode(deviceId))}';
  }

  /// 저장된 결합 값이 현재 기기 ID와 일치하는지 검증 (기기 묶임용)
  static bool verifyDeviceBinding({
    required String deviceId,
    required String passwordHash,
    required String savedBinding,
  }) {
    final expected = bindDeviceId(
      deviceId: deviceId,
      passwordHash: passwordHash,
    );
    return expected == savedBinding;
  }

  static List<int> _hexToBytes(String hex) {
    return List<int>.generate(
      hex.length ~/ 2,
      (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
    );
  }
}
