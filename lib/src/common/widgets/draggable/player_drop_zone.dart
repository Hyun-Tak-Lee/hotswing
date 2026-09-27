import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player_item.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';

/// 플레이어를 배치할 수 있는 슬롯 영역을 제공하고, 드롭 타겟 역할을 수행하는 위젯.
class PlayerDropZone extends StatelessWidget {
  final dynamic sectionId;
  final Player? player;
  final String sectionKind;
  final int sectionIndex;
  final int subIndex;
  final Function(
    PlayerDragData data,
    Player? targetPlayer,
    dynamic targetSectionId,
    String sectionKind,
    int sectionIndex,
    int subIndex,
  )
  onPlayerDropped;
  final bool isDropEnabled;
  final Color? backgroundColor;
  final VoidCallback? onDragStartedFromZone;
  final VoidCallback? onDragEndedFromZone;
  final VoidCallback? onPlayerRemoved;

  const PlayerDropZone({
    super.key,
    required this.sectionId,
    this.player,
    required this.sectionKind,
    required this.sectionIndex,
    required this.subIndex,
    required this.onPlayerDropped,
    this.isDropEnabled = true,
    this.backgroundColor,
    this.onDragStartedFromZone,
    this.onDragEndedFromZone,
    this.onPlayerRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final playerColors = context.playerColors;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = ResponsiveUtils.isTablet(context);
    // 태블릿 화면에서 코트를 더 많이 볼 수 있도록 세로 길이 축소
    // 가로 모드일 때는 비율에 맞춰 크기가 계산되도록 높이를 null로 설정
    // 배정/대기 코트 카드 내부인 경우(assigned, standby)는 세로모드에서도 비례 크기를 갖도록 null로 설정
    final bool isWithinCourtCard =
        sectionKind == 'assigned' || sectionKind == 'standby';
    final double? currentHeight = isWithinCourtCard
        ? null
        : (isLandscape ? null : (isTablet ? 160.0 : 140.0));

    return DragTarget<PlayerDragData>(
      onWillAcceptWithDetails: (details) {
        return isDropEnabled;
      },
      onAcceptWithDetails: (details) {
        if (isDropEnabled) {
          onPlayerDropped(
            details.data,
            player,
            sectionId,
            sectionKind,
            sectionIndex,
            subIndex,
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty && isDropEnabled;
        final bool isManager = player != null && player!.role == "manager";

        Color determinedDefaultBgColor = player == null
            ? courtColors.dropZoneEmptyBg
            : !player!.activate
            ? courtColors.dropZoneInactiveBg
            : courtColors.dropZoneActiveBg;
        Color hoveringBgColor = player == null
            ? courtColors.dropZoneHoverBg
            : courtColors.dropZoneActiveBg;

        // 다른 요소를 가리지 않는 은은하고 세련된 매니저 옐로우/골드 테두리
        Color borderColor = player == null
            ? courtColors.dropZoneBorder
            : (isManager
                  ? playerColors.roleManager.withValues(alpha: 0.75)
                  : Colors.transparent);
        double borderWidth = isManager ? 1.6 : 1.5;

        return LayoutBuilder(
          builder: (context, zoneConstraints) {
            return Container(
              height: currentHeight,
              margin: EdgeInsets.all(isTablet ? 2.0 : 4.0),
              decoration: BoxDecoration(
                color: isHovering ? hoveringBgColor : determinedDefaultBgColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: player != null && player!.activate
                    ? [
                        BoxShadow(
                          color: isManager
                              ? playerColors.roleManager.withValues(alpha: 0.12)
                              : Colors.black.withAlpha(12),
                          blurRadius: isManager ? 14.0 : 12.0,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: player == null
                    ? Text(
                        isDropEnabled ? '' : 'X',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withAlpha(100),
                        ),
                      )
                    : Opacity(
                        opacity: player!.activate ? 1.0 : 0.4,
                        child: DraggablePlayerItem(
                          player: player!,
                          sourceSectionId: sectionId,
                          sectionKind: sectionKind,
                          sectionIndex: sectionIndex,
                          subIndex: subIndex,
                          onDragStarted: onDragStartedFromZone,
                          onDragEnded: onDragEndedFromZone,
                          showRemoveButton:
                              sectionKind == 'assigned' ||
                              sectionKind == 'standby',
                          onPlayerRemoved: onPlayerRemoved,
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
