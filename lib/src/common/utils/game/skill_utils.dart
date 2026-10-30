import 'package:hotswing/src/common/constants/skill_constants.dart';

/// 실력 등급과 레이팅 간 변환 유틸리티.
abstract final class SkillUtils {
  /// 점수([rate])에 해당하는 실력 등급(문자열)을 계산하여 반환합니다.
  ///
  /// 인접한 두 등급 기준 레이팅의 중간값을 경계로 삼습니다.
  static String rateToSkillLevel(int rate) {
    final entries = SkillConstants.levelToRate.entries.toList();

    for (int i = 0; i < entries.length - 1; i++) {
      int midPoint = (entries[i].value + entries[i + 1].value) ~/ 2;
      if (rate < midPoint) {
        return entries[i].key;
      }
    }

    return entries.last.key;
  }
}
