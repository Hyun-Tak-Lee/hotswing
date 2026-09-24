import 'package:flutter/material.dart';

/// 동반 그룹의 라벨과 배지 색상 정보를 나타내는 UI 모델.
class GroupInfo {
  /// 그룹 표시 문자열 (예: "A", "B", "그룹명").
  final String label;

  /// 그룹 식별용 배경 색상.
  final Color color;

  /// [GroupInfo] 인스턴스를 생성합니다.
  GroupInfo({required this.label, required this.color});
}
