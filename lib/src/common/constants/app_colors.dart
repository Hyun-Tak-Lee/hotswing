import 'package:flutter/material.dart';

class AppColors {
  // 자동 매칭 (그린 계열)
  static const List<Color> autoMatch = [
    Color(0xFF86EFAC),
    Color(0xFF4ADE80),
  ];

  // 새로고침 / 플레이어 제거 (레드 계열)
  static const List<Color> remove = [
    Color(0xFFEF9A9A),
    Color(0xFFE57373),
  ];

  // 경기 종료 (오렌지/레드 계열)
  static const List<Color> finish = [
    Color(0xFFFFB74D),
    Color(0xFFE57373),
  ];

  // 코트 이동 / 교환 (블루 계열)
  static const List<Color> swap = [
    Color(0xFF64B5F6),
    Color(0xFF2196F3),
  ];

  // 코트 삭제 (오렌지 계열)
  static const List<Color> removeCourt = [
    Color(0xFFFDBA74),
    Color(0xFFFB923C),
  ];

  // 대기존 배경 (옐로우/앰버 계열)
  static const List<Color> standbyZone = [
    Color(0xFFFEF3C7),
    Color(0xFFFDE68A),
  ];

  // 텍스트/아이콘 색상 (강조용 대여)
  static const Color standbyZoneIcon = Color(0xFFD97706);
}
