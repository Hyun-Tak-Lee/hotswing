import 'package:flutter_test/flutter_test.dart';
import 'package:hotswing/src/common/utils/security/crypto_utils.dart';

void main() {
  group('CryptoUtils.pbkdf2Sha256', () {
    // PBKDF2-HMAC-SHA256 표준 테스트 벡터 (P="password", S="salt")
    const saltHex = '73616c74';

    test('iterations 1', () {
      expect(
        CryptoUtils.pbkdf2Sha256(
          password: 'password',
          saltHex: saltHex,
          iterations: 1,
        ),
        '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
      );
    });

    test('iterations 2', () {
      expect(
        CryptoUtils.pbkdf2Sha256(
          password: 'password',
          saltHex: saltHex,
          iterations: 2,
        ),
        'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43',
      );
    });

    test('iterations 4096', () {
      expect(
        CryptoUtils.pbkdf2Sha256(
          password: 'password',
          saltHex: saltHex,
          iterations: 4096,
        ),
        'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a',
      );
    });
  });

  group('CryptoUtils.bindDeviceId', () {
    test('같은 기기 ID와 해시면 검증에 성공한다', () {
      final binding = CryptoUtils.bindDeviceId(
        deviceId: 'device-a',
        passwordHash: 'hash',
      );
      expect(
        CryptoUtils.verifyDeviceBinding(
          deviceId: 'device-a',
          passwordHash: 'hash',
          savedBinding: binding,
        ),
        isTrue,
      );
    });

    test('다른 기기 ID면 검증에 실패한다', () {
      final binding = CryptoUtils.bindDeviceId(
        deviceId: 'device-a',
        passwordHash: 'hash',
      );
      expect(
        CryptoUtils.verifyDeviceBinding(
          deviceId: 'device-b',
          passwordHash: 'hash',
          savedBinding: binding,
        ),
        isFalse,
      );
    });
  });
}
