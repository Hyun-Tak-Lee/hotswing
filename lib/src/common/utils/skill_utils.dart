const Map<String, int> skillLevelToRate = {
  '초심': 500,
  'D': 1000,
  'D+': 1500,
  'C': 2000,
  'B': 3000,
  'A': 5000,
  'S': 10000,
};

// 역 매핑을 위한 getter 또는 함수 (필요한 경우)
Map<int, String> get rateToSkillLevel {
  return skillLevelToRate.map((key, value) => MapEntry(value, key));
}
