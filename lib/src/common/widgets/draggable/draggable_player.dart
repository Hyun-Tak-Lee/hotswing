import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/widgets/dialogs/game_played_dialog.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

// 개별 플레이어를 나타내는 드래그 가능한 위젯
class DraggablePlayerItem extends StatelessWidget {
  final Player player;
  final dynamic sourceSectionId;
  final String sectionKind;
  final int sectionIndex;
  final int subIndex;
  final bool isDragEnabled;
  final bool showRemoveButton;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;
  final VoidCallback? onPlayerRemoved;

  const DraggablePlayerItem({
    super.key,
    required this.player,
    required this.sourceSectionId,
    required this.sectionKind,
    required this.sectionIndex,
    required this.subIndex,
    this.isDragEnabled = true,
    this.showRemoveButton = false,
    this.onDragStarted,
    this.onDragEnded,
    this.onPlayerRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final groupInfo = playersProvider.getGroupInfo(player.id);
    final isTablet = ResponsiveUtils.isTablet(context);
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final courtColors = context.courtColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // infinite/0 이하 높이와 너비에 대한 안전 장치
        final double availHeight = (height.isInfinite || height <= 0)
            ? (isTablet ? 160.0 : 140.0)
            : height;
        final double availWidth = (width.isInfinite || width <= 0)
            ? (isTablet ? 200.0 : 150.0)
            : width;

        // 사이즈 비례 폰트 계산
        // 세로 높이 기준 비율 설정
        double nameFontSize = availHeight * 0.15;
        double skillFontSize = availHeight * 0.12;
        double detailFontSize = availHeight * 0.11;

        // 가로 너비 기준 상한선 적용 (너무 크면 가로가 넘치므로)
        final double maxNameByWidth = availWidth * 0.13;
        if (nameFontSize > maxNameByWidth) {
          nameFontSize = maxNameByWidth;
          skillFontSize = nameFontSize * 0.8;
          detailFontSize = nameFontSize * 0.75;
        }

        // clamp 적용하여 모바일/태블릿 적정 범위 보장
        nameFontSize = nameFontSize.clamp(12.0, isTablet ? 25.0 : 20.0);
        skillFontSize = skillFontSize.clamp(10.0, isTablet ? 18.0 : 16.0);
        detailFontSize = detailFontSize.clamp(9.0, 16.0);

        final double removeBtnSize = (nameFontSize * 1.3).clamp(
          16.0,
          isTablet ? 28.0 : 24.0,
        );
        final double removeIconSize = (removeBtnSize * 0.7).clamp(
          11.0,
          isTablet ? 18.0 : 16.0,
        );

        final String skillLevelDisplay = player.grade;
        final textColor = courtColors.playerItemTextPrimary;
        final detailTextColor = courtColors.playerItemTextSecondary;

        // 시간 표시 포맷팅 (MM:SS)
        final String minutesStr = (player.playTime ~/ 60).toString().padLeft(
          2,
          '0',
        );
        final String secondsStr = (player.playTime % 60).toString().padLeft(
          2,
          '0',
        );
        final String timeDisplay = '$minutesStr:$secondsStr';

        // 가로 너비 제약으로 인해 글자 크기(nameFontSize)가 줄어들 경우를 고려하여,
        // 간격과 여백을 최종 글자 크기에 비례하도록 동기화합니다.
        final double spacing = (nameFontSize * 0.35).clamp(1.5, 12.0);
        final double verticalPadding = (nameFontSize * 0.25).clamp(0.0, 8.0);

        // 순수 UI 표현을 위한 위젯
        Widget playerItemDisplay = Stack(
          children: [
            Container(
              height: availHeight, // 부모 드롭존의 높이를 가득 채우도록 함
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding,
                horizontal: 2.0,
              ),
              margin: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 0.0,
              ),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment:
                    MainAxisAlignment.center, // 세로 공간이 넉넉할 때 가운데를 기점으로 정렬
                mainAxisSize: MainAxisSize.max, // 높이를 가득 채우므로 max로 변경
                children: [
                  if (groupInfo != null)
                    Container(
                      margin: EdgeInsets.only(
                        bottom: spacing,
                        left: 2.0,
                        right: 2.0,
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: (nameFontSize * 0.15).clamp(1.0, 4.0),
                      ),
                      decoration: BoxDecoration(
                        color: groupInfo.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: groupInfo.color.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (showRemoveButton)
                            SizedBox(width: removeBtnSize), // 좌우 균형을 위한 빈 공간

                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  groupInfo.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: (nameFontSize - 6.0).clamp(
                                      10.0,
                                      16.0,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: groupInfo.color,
                                    height: 1.1,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          if (showRemoveButton)
                            GestureDetector(
                              onTap: () {
                                if (onPlayerRemoved != null) {
                                  onPlayerRemoved!();
                                }
                              },
                              child: Container(
                                width: removeBtnSize,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.close,
                                  size: removeIconSize,
                                  color: groupInfo.color.withValues(alpha: 0.8),
                                ),
                              ),
                            )
                          else
                            const SizedBox(),
                        ],
                      ),
                    ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: availHeight < 120.0 ? 0.0 : 2.0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (player.role == "manager") ...[
                              Icon(
                                Icons.star_rounded,
                                size: (nameFontSize * 1.2).clamp(
                                  14.0,
                                  isTablet ? 28.0 : 20.0,
                                ),
                                color: playerColors.roleManager,
                              ),
                              const SizedBox(width: 4.0),
                            ],
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  player.name,
                                  style: TextStyle(
                                    fontSize: nameFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  player.gender,
                                  style: TextStyle(
                                    fontSize: (nameFontSize - 2.0).clamp(
                                      10.0,
                                      23.0,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    color: courtColors.playerItemGenderText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              skillLevelDisplay,
                              style: TextStyle(
                                fontSize: skillFontSize + 4,
                                color: courtColors.playerItemGenderText,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Container(
                              height: 12,
                              width: 1.5,
                              color: courtColors.playerItemDivider,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            Text(
                              'Rate ',
                              style: TextStyle(
                                fontSize: (detailFontSize - 2).clamp(8.0, 14.0),
                                color: courtColors.playerItemRateLabel,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${player.rate}',
                              style: TextStyle(
                                fontSize: detailFontSize,
                                color: detailTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_outline_rounded,
                              size: (detailFontSize - 2.0).clamp(8.0, 14.0),
                              color: detailTextColor,
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              '${player.played}${player.lated != 0 ? ' (+${player.lated})' : ''}',
                              style: TextStyle(
                                fontSize: (detailFontSize - 1.0).clamp(
                                  8.0,
                                  15.0,
                                ),
                                color: detailTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              height: 10.0,
                              width: 1.2,
                              color: courtColors.playerItemDivider,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                            ),
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: (detailFontSize - 2.0).clamp(8.0, 14.0),
                              color: detailTextColor,
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              '${player.waited}',
                              style: TextStyle(
                                fontSize: (detailFontSize - 1.0).clamp(
                                  8.0,
                                  15.0,
                                ),
                                color: detailTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              height: 10.0,
                              width: 1.2,
                              color: Colors.grey.shade300,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                            ),
                            Icon(
                              Icons.timer_outlined,
                              size: (detailFontSize - 2.0).clamp(8.0, 14.0),
                              color: detailTextColor,
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              timeDisplay,
                              style: TextStyle(
                                fontSize: (detailFontSize - 1.0).clamp(
                                  8.0,
                                  15.0,
                                ),
                                color: detailTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (groupInfo == null && showRemoveButton)
              Positioned(
                top: verticalPadding,
                right: 2.0,
                child: GestureDetector(
                  onTap: () {
                    if (onPlayerRemoved != null) {
                      onPlayerRemoved!();
                    }
                  },
                  child: Container(
                    width: removeBtnSize,
                    height: removeBtnSize,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close,
                      size: removeIconSize,
                      color: courtColors.dropZoneCloseIcon,
                    ),
                  ),
                ),
              ),
          ],
        );

        // 탭 기능을 추가하기 위해 GestureDetector로 감싼 위젯
        Widget interactivePlayerContent = GestureDetector(
          onTap: () {
            final Map<String, int> newGamesPlayedWithMap = player
                .gamesPlayedWith
                .map((key, value) {
                  final newKey =
                      playersProvider
                          .getPlayerById(ObjectId.fromHexString(key))
                          ?.name ??
                      "";
                  return MapEntry(newKey, value);
                });

            final List<String> allPlayerNames = playersProvider.players.values
                .map((p) => p.name)
                .toList();
            final Set<String> playedWithPlayerNames = newGamesPlayedWithMap.keys
                .toSet();
            final List<String> notPlayedWithNames = allPlayerNames
                .where(
                  (name) =>
                      !playedWithPlayerNames.contains(name) &&
                      name != player.name,
                )
                .toList();

            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return GamePlayedDialog(
                  gamesPlayedWithMap: newGamesPlayedWithMap,
                  player: player,
                  notPlayedWithNames: notPlayedWithNames,
                );
              },
            );
          },
          child: playerItemDisplay,
        );

        if (!isDragEnabled) {
          return interactivePlayerContent;
        }

        return LongPressDraggable<PlayerDragData>(
          data: PlayerDragData(
            player: player,
            sourceSectionId: sourceSectionId,
            sectionKind: sectionKind,
            sectionIndex: sectionIndex,
            subIndex: subIndex,
          ),
          feedback: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: baseColors.cardBg,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: baseColors.cardShadow,
                      blurRadius: 15.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (groupInfo != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 6.0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 2.0,
                          horizontal: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: groupInfo.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: groupInfo.color.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            groupInfo.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (nameFontSize - 7.0).clamp(8.0, 18.0),
                              fontWeight: FontWeight.bold,
                              color: groupInfo.color,
                              height: 1.0,
                              decoration: TextDecoration.none,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (player.role == "manager") ...[
                            Icon(
                              Icons.star_rounded,
                              size: isTablet ? 18.0 : 14.0,
                              color: playerColors.roleManager,
                            ),
                            const SizedBox(width: 4.0),
                          ],
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                player.name,
                                style: TextStyle(
                                  fontSize: nameFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: courtColors.playerItemTextPrimary,
                                  decoration: TextDecoration.none,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 6.0),
                              Text(
                                player.gender,
                                style: TextStyle(
                                  fontSize: (nameFontSize - 2.0).clamp(
                                    10.0,
                                    23.0,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  color: courtColors.playerItemGenderText,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 드래그 중에는 순수 UI만 표시 (탭 기능 없음)
          childWhenDragging: Opacity(opacity: 0.5, child: playerItemDisplay),
          onDragStarted: () {
            if (sectionIndex != -1 && onDragStarted != null) {
              onDragStarted!();
            }
          },
          onDraggableCanceled: (velocity, offset) {
            if (sectionIndex != -1 && onDragEnded != null) {
              onDragEnded!();
            }
          },
          onDragCompleted: () {
            if (sectionIndex != -1 && onDragEnded != null) {
              onDragEnded!();
            }
          },
          // 실제 드래그 대상이 되는 자식 위젯 (탭 기능 포함)
          child: interactivePlayerContent,
        );
      },
    );
  }
}

// 플레이어를 담고, 다른 플레이어를 드롭할 수 있는 영역 위젯
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isTablet = ResponsiveUtils.isTablet(context);
    // 태블릿 화면에서 코트를 더 많이 볼 수 있도록 세로 길이 축소 (기존 240 -> 160)
    final double? currentHeight = isLandscape
        ? null
        : (isTablet ? 160.0 : 140.0);

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

        Color determinedDefaultBgColor = player == null
            ? courtColors.dropZoneEmptyBg
            : !player!.activate
            ? courtColors.dropZoneInactiveBg
            : courtColors.dropZoneActiveBg;
        Color hoveringBgColor = player == null
            ? courtColors.dropZoneHoverBg
            : courtColors.dropZoneActiveBg;
        Color borderColor = player == null
            ? courtColors.dropZoneBorder
            : Colors.transparent;

        return Container(
          height: currentHeight,
          margin: EdgeInsets.all(isTablet ? 2.0 : 4.0),
          decoration: BoxDecoration(
            color: isHovering ? hoveringBgColor : determinedDefaultBgColor,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: player != null && player!.activate
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 12.0,
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
                          sectionKind == 'assigned' || sectionKind == 'standby',
                      onPlayerRemoved: onPlayerRemoved,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _MiniGroupBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const _MiniGroupBadge({
    required this.label,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
          height: 1.0,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}
