import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:hotswing/src/common/utils/security/crypto_utils.dart';
import 'package:hotswing/src/services/system/activation_service.dart';

/// 관리자 인증 서비스
///
/// 선수 관리 등 민감한 페이지에 접근하기 위한 두 번째 비밀번호 관리
class ManagerAuthService {
  static final ManagerAuthService _instance = ManagerAuthService._internal();
  final SharedProvider _sharedProvider = SharedProvider();

  static const String _keyManagerPasswordHash = 'manager_password_hash';
  static const String _keyManagerPasswordSalt = 'manager_password_salt';

  ManagerAuthService._internal();

  factory ManagerAuthService() {
    return _instance;
  }

  /// 관리자 비밀번호가 설정되어 있는지 확인
  Future<bool> hasManagerPassword() async {
    final hash = await _sharedProvider.getString(_keyManagerPasswordHash);
    return hash != null && hash.isNotEmpty;
  }

  /// 관리자 비밀번호 검증
  Future<bool> verifyManagerPassword(String password) async {
    final savedHash = await _sharedProvider.getString(_keyManagerPasswordHash);
    if (savedHash == null || savedHash.isEmpty) {
      return false;
    }

    final salt = await _sharedProvider.getString(_keyManagerPasswordSalt);
    if (salt == null || salt.isEmpty) {
      // salt 도입 이전에 저장된 해시: 일치하면 salt 적용 해시로 재저장
      if (savedHash != CryptoUtils.generateHash(password)) return false;
      await setManagerPassword(password);
      return true;
    }

    return savedHash == CryptoUtils.generateSaltedHash(password, salt);
  }

  /// 활성화(마스터) 비밀번호와 일치하는지 확인 (초기화, 재설정 용도)
  Future<bool> verifyActivationPassword(String password) {
    return ActivationService().verifyMasterPassword(password);
  }

  /// 관리자 비밀번호 설정
  ///
  /// 설정할 때마다 새 salt를 생성하여 해시와 함께 저장합니다.
  Future<void> setManagerPassword(String newPassword) async {
    final salt = CryptoUtils.generateSalt();
    final hash = CryptoUtils.generateSaltedHash(newPassword, salt);
    await _sharedProvider.saveString(_keyManagerPasswordSalt, salt);
    await _sharedProvider.saveString(_keyManagerPasswordHash, hash);
  }
}
