import 'package:flutter_test/flutter_test.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';

void main() {
  group('SkillUtils.rateToSkillLevel', () {
    test('등급 기준 레이팅은 해당 등급으로 변환된다', () {
      expect(SkillUtils.rateToSkillLevel(0), '초심');
      expect(SkillUtils.rateToSkillLevel(2000), 'C');
      expect(SkillUtils.rateToSkillLevel(5000), 'S');
    });

    test('인접 등급 중간값부터 상위 등급으로 변환된다', () {
      // D(1000)와 D+(1500)의 중간값은 1250
      expect(SkillUtils.rateToSkillLevel(1249), 'D');
      expect(SkillUtils.rateToSkillLevel(1250), 'D+');
    });

    test('최고 등급 기준을 넘으면 최고 등급이다', () {
      expect(SkillUtils.rateToSkillLevel(7500), 'S');
    });
  });
}
