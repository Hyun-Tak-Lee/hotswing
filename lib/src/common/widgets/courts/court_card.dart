import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 단일 코트를 렌더링하는 공통 위젯.
/// [CourtSectionsView]와 [StandbyCourtSectionsView]에서 공유합니다.
class CourtCard extends StatelessWidget {
  final int sectionIndex;
  final List<Player?> players;
  final String sectionKind;
  final List<Widget> headerActions;
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
  final VoidCallback onCourtPlayerDragStarted;
  final VoidCallback onCourtPlayerDragEnded;
  final Function(int sectionIndex, int subIndex)? onPlayerRemoved;

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
          colors: [
            courtColors.courtCardBgStart,
            courtColors.courtCardBgEnd,
          ],
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
        children: [
          // 헤더: 코트 이름 + 액션 버튼들
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: isTablet ? 8.0 : 4.0,
            runSpacing: 4.0,
            children: [
              Text(
                '${sectionIndex + 1} 코트',
                style: TextStyle(
                  fontSize: isTablet ? 32.0 : 20.0,
                  fontWeight: FontWeight.bold,
                  color: courtColors.courtCardText,
                ),
              ),
              ...headerActions,
            ],
          ),
          const SizedBox(height: 4.0),
          // 코트 내부: 4개의 PlayerDropZone
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildDropZone(context, 0)),
                  Expanded(child: _buildDropZone(context, 1)),
                ],
              ),
              SizedBox(height: isTablet ? 4.0 : 4.0),
              Row(
                children: [
                  Expanded(child: _buildDropZone(context, 2)),
                  Expanded(child: _buildDropZone(context, 3)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context, int subIndex) {
    return PlayerDropZone(
      sectionId: '${sectionIndex}_$subIndex',
      player: players.asMap().containsKey(subIndex) ? players[subIndex] : null,
      sectionKind: sectionKind,
      sectionIndex: sectionIndex,
      subIndex: subIndex,
      onPlayerDropped:
          (
            data,
            droppedOnPlayer,
            targetId,
            targetSectionKind,
            targetSectionIdx,
            targetSubIdx,
          ) => onPlayerDrop(
            context,
            data,
            droppedOnPlayer,
            targetId,
            targetSectionKind,
            targetSectionIdx,
            targetSubIdx,
          ),
      onDragStartedFromZone: onCourtPlayerDragStarted,
      onDragEndedFromZone: onCourtPlayerDragEnded,
      onPlayerRemoved: onPlayerRemoved != null
          ? () => onPlayerRemoved!(sectionIndex, subIndex)
          : null,
    );
  }
}
