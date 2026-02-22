import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:hotswing/src/common/utils/security/crypto_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 관리자 인증 서비스
///
/// 선수 관리 등 민감한 페이지에 접근하기 위한 두 번째 비밀번호 관리
class ManagerAuthService {
  static final ManagerAuthService _instance = ManagerAuthService._internal();
  final SharedProvider _sharedProvider = SharedProvider();

  static const String _keyManagerPasswordHash = 'manager_password_hash';

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
    final inputHash = CryptoUtils.generateHash(password);
    return savedHash == inputHash;
  }

  /// 활성화(마스터) 비밀번호와 일치하는지 확인 (초기화, 재설정 용도)
  bool verifyActivationPassword(String password) {
    final masterPassword = dotenv.env['MASTER_PASSWORD'];
    if (masterPassword == null) return false;
    return password.trim() == masterPassword;
  }

  /// 관리자 비밀번호 설정
  Future<void> setManagerPassword(String newPassword) async {
    final hash = CryptoUtils.generateHash(newPassword);
    await _sharedProvider.saveString(_keyManagerPasswordHash, hash);
  }
}
