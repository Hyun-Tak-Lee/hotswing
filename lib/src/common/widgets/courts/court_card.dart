import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 단일 코트를 렌더링하는 공통 위젯.
/// [CourtSectionsView]와 [StandbyCourtSectionsView]에서 공유합니다.
class CourtCard extends StatelessWidget {
  /// 코트 섹션 인덱스.
  final int sectionIndex;

  /// 코트에 배정된 플레이어 목록 (최대 4명, 빈 자리는 null).
  final List<Player?> players;

  /// 섹션 종류 (예: 경기 코트, 대기 코트).
  final String sectionKind;

  /// 코트 헤더에 배치할 액션 위젯 목록.
  final List<Widget> headerActions;

  /// 플레이어 드롭 시 호출되는 콜백.
  final Function(
    BuildContext,
    PlayerDragData,
    Player?,
    dynamic,
    String,
    int,
    int,
  )
  onPlayerDrop;

  /// 코트 내 플레이어 드래그 시작 시 호출되는 콜백.
  final VoidCallback onCourtPlayerDragStarted;

  /// 코트 내 플레이어 드래그 종료 시 호출되는 콜백.
  final VoidCallback onCourtPlayerDragEnded;

  /// 코트 내 플레이어 삭제/제거 시 호출되는 콜백 (선택).
  final Function(int sectionIndex, int subIndex)? onPlayerRemoved;

  /// [CourtCard] 생성자.
  const CourtCard({
    super.key,
    required this.sectionIndex,
    required this.players,
    required this.sectionKind,
    required this.headerActions,
    required this.onPlayerDrop,
    required this.onCourtPlayerDragStarted,
    required this.onCourtPlayerDragEnded,
    this.onPlayerRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);

    final playerGrid = Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _CourtDropZone(card: this, subIndex: 0)),
              Expanded(child: _CourtDropZone(card: this, subIndex: 1)),
            ],
          ),
        ),
        SizedBox(height: isTablet ? 4.0 : 4.0),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _CourtDropZone(card: this, subIndex: 2)),
              Expanded(child: _CourtDropZone(card: this, subIndex: 3)),
            ],
          ),
        ),
      ],
    );

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isTablet ? 3.0 : 5.0,
        horizontal: 5.0,
      ),
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 3.0 : 5.0,
        horizontal: 5.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [courtColors.courtCardBgStart, courtColors.courtCardBgEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // 헤더: 코트 이름 + 액션 버튼들
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${sectionIndex + 1} 코트',
                    style: TextStyle(
                      fontSize: isTablet ? 32.0 : 20.0,
                      fontWeight: FontWeight.bold,
                      color: courtColors.courtCardText,
                    ),
                  ),
                  SizedBox(width: isTablet ? 8.0 : 4.0),
                  for (int i = 0; i < headerActions.length; i++) ...[
                    headerActions[i],
                    if (i < headerActions.length - 1)
                      SizedBox(width: isTablet ? 8.0 : 4.0),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          // 코트 내부: 4개의 PlayerDropZone
          Expanded(child: playerGrid),
        ],
      ),
    );
  }

}

class _CourtDropZone extends StatelessWidget {
  const _CourtDropZone({required this.card, required this.subIndex});

  final CourtCard card;
  final int subIndex;

  @override
  Widget build(BuildContext context) {
    return PlayerDropZone(
      sectionId: '${card.sectionIndex}_$subIndex',
      player: card.players.asMap().containsKey(subIndex)
          ? card.players[subIndex]
          : null,
      sectionKind: card.sectionKind,
      sectionIndex: card.sectionIndex,
      subIndex: subIndex,
      onPlayerDropped:
          (
            data,
            droppedOnPlayer,
            targetId,
            targetSectionKind,
            targetSectionIdx,
            targetSubIdx,
          ) => card.onPlayerDrop(
            context,
            data,
            droppedOnPlayer,
            targetId,
            targetSectionKind,
            targetSectionIdx,
            targetSubIdx,
          ),
      onDragStartedFromZone: card.onCourtPlayerDragStarted,
      onDragEndedFromZone: card.onCourtPlayerDragEnded,
      onPlayerRemoved: card.onPlayerRemoved != null
          ? () => card.onPlayerRemoved!(card.sectionIndex, subIndex)
          : null,
    );
  }
}
