/// 배드민턴 실력 등급과 레이팅(점수) 간의 매핑 테이블.
const Map<String, int> skillLevelToRate = {
  '초심': 0,
  '초심+': 500,
  'D': 1000,
  'D+': 1500,
  'C': 2000,
  'B': 3000,
  'A': 4000,
  'S': 5000,
};

/// 점수([rate])에 해당하는 실력 등급(문자열)을 계산하여 반환합니다.
String rateToSkillLevel(int rate) {
  final entries = skillLevelToRate.entries.toList();

  for (int i = 0; i < entries.length - 1; i++) {
    int midPoint = (entries[i].value + entries[i + 1].value) ~/ 2;
    if (rate < midPoint) {
      return entries[i].key;
    }
  }

  return entries.last.key;
}
