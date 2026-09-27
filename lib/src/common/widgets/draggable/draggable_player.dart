import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/models/ui/group_info.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/widgets/dialogs/game_played_dialog.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

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
                    ? _SimplifiedPlayerContent(
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
                    : _DetailedPlayerContent(
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

/// 코트 패널 내에서 선수 정보를 간소화(이름, 그룹, 급수, 성별)하여 표시하는 위젯.
class _SimplifiedPlayerContent extends StatelessWidget {
  final Player player;
  final GroupInfo? groupInfo;
  final double nameFontSize;
  final double skillFontSize;
  final double spacing;
  final double availHeight;
  final bool hasRemoveButton;
  final double removeBtnSize;
  final bool isTablet;

  const _SimplifiedPlayerContent({
    required this.player,
    required this.groupInfo,
    required this.nameFontSize,
    required this.skillFontSize,
    required this.spacing,
    required this.availHeight,
    required this.hasRemoveButton,
    required this.removeBtnSize,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;

    // 우측 삭제(X) 버튼 침범을 방지하면서도 텍스트 크기와 정중앙 정렬을 보호하기 위해 여백 제한
    final double horizontalPadding = hasRemoveButton
        ? (isTablet ? 14.0 : 10.0)
        : (isTablet ? 8.0 : 6.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        // 1행: 이름
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: availHeight < 100.0 ? 0.0 : 1.0,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                player.name,
                style: TextStyle(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.bold,
                  color: courtColors.playerItemTextPrimary,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        SizedBox(height: (spacing * 0.6).clamp(3.0, 8.0)),
        // 2행: 성별 급수 + 그룹 (급수 뒤에 그룹 배치)
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: skillFontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(
                      text: '${player.gender}  ${player.grade}',
                      style: TextStyle(color: courtColors.playerItemGenderText),
                    ),
                    if (groupInfo != null) ...[
                      const TextSpan(text: '   '),
                      TextSpan(
                        text: groupInfo!.label,
                        style: TextStyle(color: groupInfo!.color),
                      ),
                    ],
                  ],
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 대기 패널 내에서 선수 정보를 표시하는 위젯 (그룹 -> 이름 -> 성별 급수 -> 플레이 정보).
class _DetailedPlayerContent extends StatelessWidget {
  final Player player;
  final GroupInfo? groupInfo;
  final double nameFontSize;
  final double skillFontSize;
  final double detailFontSize;
  final double spacing;
  final double availHeight;
  final String timeDisplay;
  final bool hasRemoveButton;
  final double removeBtnSize;
  final bool isTablet;

  const _DetailedPlayerContent({
    required this.player,
    required this.groupInfo,
    required this.nameFontSize,
    required this.skillFontSize,
    required this.detailFontSize,
    required this.spacing,
    required this.availHeight,
    required this.timeDisplay,
    required this.hasRemoveButton,
    required this.removeBtnSize,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final textColor = courtColors.playerItemTextPrimary;
    final detailTextColor = courtColors.playerItemTextSecondary;
    final skillLevelDisplay = player.grade;

    // 우측 삭제(X) 버튼 침범을 방지하면서도 텍스트 크기와 정중앙 정렬을 보호하기 위해 여백 제한
    final double horizontalPadding = hasRemoveButton
        ? (isTablet ? 14.0 : 10.0)
        : (isTablet ? 8.0 : 6.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 상단/중앙 메인 정보: 이름 1행 + 성별급수/그룹 2행 (유연한 텍스트 크기)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1행: 이름 (단독, 최대 크기 지정)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: availHeight < 120.0 ? 0.0 : 1.0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: (spacing * 0.5).clamp(3.0, 7.0)),
              // 2행: 성별 급수 + 그룹 (급수 뒤에 그룹 배치)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: skillFontSize,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                        children: [
                          TextSpan(
                            text: '${player.gender}  $skillLevelDisplay',
                            style: TextStyle(
                              color: courtColors.playerItemGenderText,
                            ),
                          ),
                          if (groupInfo != null) ...[
                            const TextSpan(text: '   '),
                            TextSpan(
                              text: groupInfo!.label,
                              style: TextStyle(color: groupInfo!.color),
                            ),
                          ],
                        ],
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 4. 최하단 부가 정보: 플레이 정보 (공간 부족 시 2줄로 자동 변환)
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0, left: 4.0, right: 4.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double iconSize = (detailFontSize - 1.0).clamp(
                8.0,
                isTablet ? 19.0 : 13.0,
              );
              final double itemGap = isTablet ? 12.0 : 8.0;
              final double iconTextGap = isTablet ? 3.5 : 2.5;
              final TextStyle textStyle = TextStyle(
                fontSize: detailFontSize,
                color: detailTextColor,
                fontWeight: FontWeight.w600,
              );

              final String playedText =
                  '${player.played}${player.lated != 0 ? ' (+${player.lated})' : ''}';
              final String waitedText = '${player.waited}';

              // 1줄 배치 시 필요한 대략적인 최소 가로 너비 추정
              final int totalChars =
                  playedText.length + waitedText.length + timeDisplay.length;
              final double estimatedCharWidth = detailFontSize * 0.62;
              final double neededWidth =
                  (iconSize * 3) +
                  (iconTextGap * 3) +
                  (itemGap * 2) +
                  (totalChars * estimatedCharWidth);

              final bool shouldUseTwoRows =
                  constraints.maxWidth.isFinite &&
                  constraints.maxWidth < neededWidth;

              final Widget gameItem = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline_rounded,
                    size: iconSize,
                    color: detailTextColor,
                  ),
                  SizedBox(width: iconTextGap),
                  Text(playedText, style: textStyle),
                ],
              );

              final Widget waitItem = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hourglass_empty_rounded,
                    size: iconSize,
                    color: detailTextColor,
                  ),
                  SizedBox(width: iconTextGap),
                  Text(waitedText, style: textStyle),
                ],
              );

              final Widget timeItem = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: iconSize,
                    color: detailTextColor,
                  ),
                  SizedBox(width: iconTextGap),
                  Text(timeDisplay, style: textStyle),
                ],
              );

              if (shouldUseTwoRows) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          gameItem,
                          SizedBox(width: itemGap),
                          waitItem,
                        ],
                      ),
                      const SizedBox(height: 1.5),
                      timeItem,
                    ],
                  ),
                );
              }

              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    gameItem,
                    SizedBox(width: itemGap),
                    waitItem,
                    SizedBox(width: itemGap),
                    timeItem,
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
