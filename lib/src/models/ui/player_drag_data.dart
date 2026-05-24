import 'package:hotswing/src/models/players/player.dart';

// 드래그되는 플레이어의 데이터와 원래 소속 섹션 정보를 전달하기 위한 클래스
class PlayerDragData {
  final Player player;
  final dynamic sourceSectionId;
  final String sectionKind;
  final int sectionIndex;
  final int subIndex;

  PlayerDragData({
    required this.player,
    required this.sourceSectionId,
    required this.sectionKind,
    required this.sectionIndex,
    required this.subIndex,
  });
}
