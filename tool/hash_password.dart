import 'dart:io';

import 'package:hotswing/src/common/utils/security/crypto_utils.dart';

/// 마스터 비밀번호로 `.env`에 넣을 salt와 해시를 생성합니다.
///
/// 사용법: dart run tool/hash_password.dart <비밀번호>
void main(List<String> args) {
  if (args.length != 1 || args.first.trim().isEmpty) {
    stderr.writeln('사용법: dart run tool/hash_password.dart <비밀번호>');
    exit(64);
  }

  final salt = CryptoUtils.generateSalt();
  final hash = CryptoUtils.pbkdf2Sha256(
    password: args.first.trim(),
    saltHex: salt,
  );

  stdout.writeln('MASTER_PASSWORD_SALT=$salt');
  stdout.writeln('MASTER_PASSWORD_HASH=$hash');
}
