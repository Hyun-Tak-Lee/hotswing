import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hotswing/src/common/utils/security/crypto_utils.dart';
import 'package:hotswing/src/services/system/activation_service.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();

  const salt = '42f5c082571c32c2b9ff19b7edaf89c8';
  final hash = CryptoUtils.pbkdf2Sha256(
    password: 'test-password-123',
    saltHex: salt,
  );

  group('ActivationService.verifyMasterPassword', () {
    test('올바른 비밀번호는 성공한다 (앞뒤 공백 무시)', () async {
      dotenv.loadFromString(
        envString: 'MASTER_PASSWORD_SALT=$salt\nMASTER_PASSWORD_HASH=$hash',
      );
      expect(
        await ActivationService().verifyMasterPassword(' test-password-123 '),
        isTrue,
      );
    });

    test('대문자 해시도 동일하게 검증된다', () async {
      dotenv.loadFromString(
        envString:
            'MASTER_PASSWORD_SALT=$salt\n'
            'MASTER_PASSWORD_HASH=${hash.toUpperCase()}',
      );
      expect(
        await ActivationService().verifyMasterPassword('test-password-123'),
        isTrue,
      );
    });

    test('틀린 비밀번호는 실패한다', () async {
      dotenv.loadFromString(
        envString: 'MASTER_PASSWORD_SALT=$salt\nMASTER_PASSWORD_HASH=$hash',
      );
      expect(await ActivationService().verifyMasterPassword('wrong'), isFalse);
    });

    test('salt 형식이 잘못되면 예외 없이 실패한다', () async {
      dotenv.loadFromString(
        envString: 'MASTER_PASSWORD_SALT=zz\nMASTER_PASSWORD_HASH=$hash',
      );
      expect(
        await ActivationService().verifyMasterPassword('test-password-123'),
        isFalse,
      );
    });
  });
}
