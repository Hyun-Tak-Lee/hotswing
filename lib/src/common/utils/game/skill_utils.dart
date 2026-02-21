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

// 점수(rate)에 따른 스킬 등급(문자열)을 반환하는 함수
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
