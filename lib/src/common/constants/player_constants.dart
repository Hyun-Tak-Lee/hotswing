import 'package:flutter/material.dart';

/// 선수 및 대기열 관련 도메인 상수
abstract final class PlayerConstants {
  /// 대기열 정렬 기준 SharedPreferences 저장 키
  static const String waitingSortCriterionKey = 'standby_sort';

  /// 동반 그룹 식별용 색상 팔레트
  static const List<Color> groupPalette = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFF59E0B), // Orange
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF43F5E), // Rose
    Color(0xFF14B8A6), // Teal
    Color(0xFF6366F1), // Indigo
  ];
}
