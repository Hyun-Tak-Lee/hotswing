import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/game_played_dialog.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

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

// 개별 플레이어를 나타내는 드래그 가능한 위젯
class DraggablePlayerItem extends StatelessWidget {
  final Player player;
  final dynamic sourceSectionId;
  final String sectionKind;
  final int sectionIndex;
  final int subIndex;
  final bool isDragEnabled;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  const DraggablePlayerItem({
    super.key,
    required this.player,
    required this.sourceSectionId,
    required this.sectionKind,
    required this.sectionIndex,
    required this.subIndex,
    this.isDragEnabled = true,
    this.onDragStarted,
    this.onDragEnded,
  });

  String _getSkillLevelString(int rate) {
    return rateToSkillLevel(rate);
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    // 태블릿(높이 160.0)에 다 들어가도록 글자 크기 조정
    final double nameFontSize = isTablet ? 25.0 : 20.0;
    final double skillFontSize = isTablet ? 18.0 : 16.0;
    final double detailFontSize = 16.0;

    String skillLevelDisplay = _getSkillLevelString(player.rate);
    final textColor = const Color(0xFF1E293B); // Slate 800 (세련된 진회색)
    final detailTextColor = const Color(0xFF64748B); // Slate 500

    // 순수 UI 표현을 위한 위젯
    Widget playerItemDisplay = Container(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 2.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (player.role == "manager") ...[
                    Icon(
                      Icons.star_rounded,
                      size: isTablet ? 28.0 : 20.0,
                      color: const Color(0xFFFFB74D), // 별색상: 주황/금색
                    ),
                    const SizedBox(width: 4.0),
                  ],
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
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
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          player.gender,
                          style: TextStyle(
                            fontSize: nameFontSize - 2.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 2.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    skillLevelDisplay,
                    style: TextStyle(
                      fontSize: skillFontSize + 4,
                      color: Colors.blueAccent.shade700,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    height: 12,
                    width: 1.5,
                    color: Colors.grey.shade400,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Text(
                    'Rate ',
                    style: TextStyle(
                      fontSize: detailFontSize - 2,
                      color: Colors.black54,
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
              SizedBox(height: isTablet ? 2.0 : 4.0),
              Text(
                '플레이: ${player.played}${player.lated != 0 ? ' (+${player.lated})' : ''}  |  대기: ${player.waited}',
                style: TextStyle(
                  fontSize: detailFontSize,
                  color: detailTextColor,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );

    // 탭 기능을 추가하기 위해 GestureDetector로 감싼 위젯
    Widget interactivePlayerContent = GestureDetector(
      onTap: () {
        final Map<String, int> newGamesPlayedWithMap = player.gamesPlayedWith
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
                  !playedWithPlayerNames.contains(name) && name != player.name,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 15.0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (player.role == "manager") ...[
                      Icon(
                        Icons.star_rounded,
                        size: isTablet ? 18.0 : 14.0,
                        color: const Color(0xFFFFB74D),
                      ),
                      const SizedBox(width: 4.0),
                    ],
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                fontSize: nameFontSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                                decoration: TextDecoration.none,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            player.gender,
                            style: TextStyle(
                              fontSize: nameFontSize - 2.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent.shade700,
                              decoration: TextDecoration.none,
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
    final isTablet = ResponsiveUtils.isTablet(context);
    // 태블릿 화면에서 코트를 더 많이 볼 수 있도록 세로 길이 축소 (기존 240 -> 160)
    final double currentHeight = isTablet ? 160.0 : 140.0;

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
            ? const Color(0xFFF8FAFC) // 빈 영역은 부드러운 연회색
            : !player!.activate
            ? const Color(0xFFCBD5E1).withAlpha(120) // 비활성은 눈에 띄게 더 투명하고 흐리게
            : const Color(0xFFFFFFFF); // 활성 플레이어는 깔끔한 흰색
        Color hoveringBgColor = player == null
            ? const Color(0xFFE2E8F0)
            : const Color(0xFFF8FAFC);
        Color borderColor = player == null
            ? const Color(0xFFE2E8F0)
            : Colors.transparent;

        Widget content = Container(
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
                : [], // 빈 영역이나 비활성은 그림자 없음
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
                    opacity: player!.activate
                        ? 1.0
                        : 0.4, // 비활성 시 내용물도 투명하게 흐리게 처리
                    child: DraggablePlayerItem(
                      player: player!,
                      sourceSectionId: sectionId,
                      sectionKind: sectionKind,
                      sectionIndex: sectionIndex,
                      subIndex: subIndex,
                      onDragStarted: onDragStartedFromZone,
                      onDragEnded: onDragEndedFromZone,
                    ),
                  ),
          ),
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            content,
            if (player != null &&
                (sectionKind == 'assigned' || sectionKind == 'standby'))
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    if (onPlayerRemoved != null) {
                      onPlayerRemoved!();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 6.0 : 4.0),
                    margin: EdgeInsets.all(isTablet ? 6.0 : 4.0),
                    child: Icon(
                      Icons.close,
                      size: isTablet ? 18.0 : 14.0,
                      color: const Color(
                        0xFF94A3B8,
                      ), // Slate 400 (좀 더 연하고 깔끔하게 묻히는 색상)
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
