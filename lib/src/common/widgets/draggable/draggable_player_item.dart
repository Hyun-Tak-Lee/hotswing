import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/game_played_dialog.dart';
import 'package:hotswing/src/common/widgets/draggable/detailed_player_content.dart';
import 'package:hotswing/src/common/widgets/draggable/simplified_player_content.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/group_info.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

/// 개별 플레이어의 상세 정보(이름, 등급, 통계, 그룹)를 표시하며 드래그 조작을 지원하는 위젯.
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
    // 해당 플레이어의 그룹 정보가 변경될 때만 리빌드되도록 선별 구독
    final groupInfo = context.select<PlayersProvider, GroupInfo?>(
      (p) => p.getGroupInfo(player.id),
    );
    final isTablet = ResponsiveUtils.isTablet(context);
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final courtColors = context.courtColors;

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final bool isCourtPanel =
              sectionKind == 'assigned' || sectionKind == 'standby';

          // infinite/0 이하 높이와 너비에 대한 안전 장치
          final double availHeight = (height.isInfinite || height <= 0)
              ? (isTablet ? 160.0 : 140.0)
              : height;
          final double availWidth = (width.isInfinite || width <= 0)
              ? (isTablet ? 200.0 : 150.0)
              : width;

          // 사이즈 비례 폰트 계산
          double nameFontSize;
          double skillFontSize;
          double detailFontSize = 0.0;

          if (isCourtPanel) {
            nameFontSize = isTablet ? availHeight * 0.26 : availHeight * 0.22;
            skillFontSize = isTablet ? availHeight * 0.19 : availHeight * 0.17;

            final double maxNameByWidth = isTablet
                ? availWidth * 0.22
                : availWidth * 0.16;
            if (nameFontSize > maxNameByWidth) {
              nameFontSize = maxNameByWidth;
              skillFontSize = nameFontSize * 0.85;
            }

            nameFontSize = nameFontSize.clamp(13.0, isTablet ? 32.0 : 19.0);
            skillFontSize = skillFontSize.clamp(11.0, isTablet ? 22.0 : 15.0);
          } else {
            nameFontSize = isTablet
                ? (availHeight * 0.20).clamp(13.0, 27.0)
                : (availHeight * 0.19).clamp(14.0, 21.0);
            skillFontSize = isTablet
                ? (nameFontSize * 0.85).clamp(11.0, 22.0)
                : (nameFontSize * 0.85).clamp(12.0, 16.5);
            detailFontSize = isTablet
                ? (availHeight * 0.135).clamp(11.0, 19.0)
                : (availHeight * 0.115).clamp(10.5, 13.5);

            final double maxNameByWidth = isTablet
                ? availWidth * 0.20
                : availWidth * 0.17;
            if (nameFontSize > maxNameByWidth) {
              nameFontSize = maxNameByWidth.clamp(12.0, isTablet ? 27.0 : 21.0);
              skillFontSize = isTablet
                  ? (nameFontSize * 0.85).clamp(10.0, 22.0)
                  : (nameFontSize * 0.85).clamp(11.0, 16.5);
              detailFontSize = isTablet
                  ? (nameFontSize * 0.70).clamp(10.0, 19.0)
                  : (nameFontSize * 0.65).clamp(9.5, 13.5);
            }
          }

          // X 삭제 버튼 터치 타겟(36~42px) 및 시각적 아이콘 크기(16.5~20px) 넉넉하게 확보
          final double removeBtnTouchSize = isTablet ? 42.0 : 36.0;
          final double removeIconSize = isTablet ? 20.0 : 16.5;

          // 시간 표시 포맷팅 (60분 이상: Xh Ym, 60분 미만: MM:SS)
          final int totalSeconds = player.playTime;
          final String timeDisplay;
          if (totalSeconds >= 3600) {
            final int hours = totalSeconds ~/ 3600;
            final int minutes = (totalSeconds % 3600) ~/ 60;
            timeDisplay = '${hours}h ${minutes}m';
          } else {
            final String minutesStr = (totalSeconds ~/ 60).toString().padLeft(
              2,
              '0',
            );
            final String secondsStr = (totalSeconds % 60).toString().padLeft(
              2,
              '0',
            );
            timeDisplay = '$minutesStr:$secondsStr';
          }

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
                child: isCourtPanel
                    ? SimplifiedPlayerContent(
                        player: player,
                        groupInfo: groupInfo,
                        nameFontSize: nameFontSize,
                        skillFontSize: skillFontSize,
                        spacing: spacing,
                        availHeight: availHeight,
                        hasRemoveButton: showRemoveButton,
                        removeBtnSize: removeBtnTouchSize,
                        isTablet: isTablet,
                      )
                    : DetailedPlayerContent(
                        player: player,
                        groupInfo: groupInfo,
                        nameFontSize: nameFontSize,
                        skillFontSize: skillFontSize,
                        detailFontSize: detailFontSize,
                        spacing: spacing,
                        availHeight: availHeight,
                        timeDisplay: timeDisplay,
                        hasRemoveButton: showRemoveButton,
                        removeBtnSize: removeBtnTouchSize,
                        isTablet: isTablet,
                      ),
              ),
              if (showRemoveButton)
                Positioned(
                  top: 0.0,
                  right: 0.0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (onPlayerRemoved != null) {
                        onPlayerRemoved!();
                      }
                    },
                    child: Container(
                      width: removeBtnTouchSize,
                      height: removeBtnTouchSize,
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
              final playersProvider = context.read<PlayersProvider>();
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
              final Set<String> playedWithPlayerNames = newGamesPlayedWithMap
                  .keys
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
            feedback: RepaintBoundary(
              child: Material(
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
                      border: player.role == "manager"
                          ? Border.all(
                              color: playerColors.roleManager.withValues(
                                alpha: 0.75,
                              ),
                              width: 1.6,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: player.role == "manager"
                              ? playerColors.roleManager.withValues(alpha: 0.12)
                              : baseColors.cardShadow,
                          blurRadius: 15.0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
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
                        ),
                      ],
                    ),
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
      ),
    );
  }
}
