import 'package:flutter_test/flutter_test.dart';
import 'package:hotswing/src/common/utils/security/crypto_utils.dart';

void main() {
  group('CryptoUtils Tests', () {
    const String deviceId = 'test_device_id_123';
    const String password = 'test_password_!@#';
    const String secretKey = 'test_super_secret_key_456';

    test('encryptDeviceId generates consistent encrypted string using HMAC-SHA256', () {
      final encrypted1 = CryptoUtils.encryptDeviceId(deviceId, password, secretKey);
      final encrypted2 = CryptoUtils.encryptDeviceId(deviceId, password, secretKey);

      expect(encrypted1, startsWith('encrypted:'));
      expect(encrypted1, equals(encrypted2)); // Deterministic behavior
    });

    test('encryptDeviceId generates different outputs for different inputs', () {
      final baseEncrypted = CryptoUtils.encryptDeviceId(deviceId, password, secretKey);

      final diffDeviceEncrypted = CryptoUtils.encryptDeviceId('diff_device', password, secretKey);
      final diffPasswordEncrypted = CryptoUtils.encryptDeviceId(deviceId, 'diff_pass', secretKey);
      final diffKeyEncrypted = CryptoUtils.encryptDeviceId(deviceId, password, 'diff_key');

      expect(baseEncrypted, isNot(equals(diffDeviceEncrypted)));
      expect(baseEncrypted, isNot(equals(diffPasswordEncrypted)));
      expect(baseEncrypted, isNot(equals(diffKeyEncrypted)));
    });

    test('verifyDeviceId returns true for matching inputs', () {
      final encrypted = CryptoUtils.encryptDeviceId(deviceId, password, secretKey);

      final isValid = CryptoUtils.verifyDeviceId(deviceId, password, encrypted, secretKey);

      expect(isValid, isTrue);
    });

    test('verifyDeviceId returns false for non-matching inputs', () {
      final encrypted = CryptoUtils.encryptDeviceId(deviceId, password, secretKey);

      final isInvalidDevice = CryptoUtils.verifyDeviceId('wrong_device', password, encrypted, secretKey);
      final isInvalidPassword = CryptoUtils.verifyDeviceId(deviceId, 'wrong_pass', encrypted, secretKey);
      final isInvalidKey = CryptoUtils.verifyDeviceId(deviceId, password, encrypted, 'wrong_key');

      expect(isInvalidDevice, isFalse);
      expect(isInvalidPassword, isFalse);
      expect(isInvalidKey, isFalse);
    });
  });
}
