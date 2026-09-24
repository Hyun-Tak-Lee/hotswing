import 'package:hotswing/src/models/players/player.dart';

/// 코트 또는 대기열 간 드래그 앤 드롭 시 선수 객체와 원본 위치 정보를 전달하는 데이터 모델.
class PlayerDragData {
  /// 드래그 대상 선수 객체.
  final Player player;

  /// 드래그가 시작된 섹션의 고유 식별자 또는 인덱스.
  final dynamic sourceSectionId;

  /// 드래그가 시작된 영역의 종류 (unassigned, assigned, standby 등).
  final String sectionKind;

  /// 드래그가 시작된 코트(또는 섹션) 인덱스.
  final int sectionIndex;

  /// 코트 내의 슬롯 위치 인덱스.
  final int subIndex;

  /// [PlayerDragData] 인스턴스를 생성합니다.
  PlayerDragData({
    required this.player,
    required this.sourceSectionId,
    required this.sectionKind,
    required this.sectionIndex,
    required this.subIndex,
  });
}
