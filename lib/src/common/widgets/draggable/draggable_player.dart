import 'package:flutter/material.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/game_played_dialog.dart';
import 'package:provider/provider.dart';

// 드래그되는 플레이어의 데이터와 원래 소속 섹션 정보를 전달하기 위한 클래스
class PlayerDragData {
  final Player player;
  final dynamic sourceSectionId;
  final int section_index;
  final int sub_index;

  PlayerDragData({
    required this.player,
    required this.sourceSectionId,
    required this.section_index,
    required this.sub_index,
  });
}

// 개별 플레이어를 나타내는 드래그 가능한 위젯
class DraggablePlayerItem extends StatelessWidget {
  final Player player;
  final dynamic sourceSectionId;
  final int section_index;
  final int sub_index;
  final bool isDragEnabled;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  const DraggablePlayerItem({
    Key? key,
    required this.player,
    required this.sourceSectionId,
    required this.section_index,
    required this.sub_index,
    this.isDragEnabled = true,
    this.onDragStarted,
    this.onDragEnded,
  }) : super(key: key);

  String _getSkillLevelString(int rate) {
    return rateToSkillLevel[rate] ?? rate.toString();
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileSize = screenWidth < 600;

    final double nameFontSize = isMobileSize ? 20.0 : 32.0;
    final double skillFontSize = isMobileSize ? 16.0 : 28.0;
    final double detailFontSize = isMobileSize ? 16.0 : 28.0;

    String skillLevelDisplay = _getSkillLevelString(player.rate);
    final onPrimaryContainer = Theme.of(context).colorScheme.onPrimaryContainer;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

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
          Text(
            '${player.name} (${player.gender})',
            style: TextStyle(
              fontSize: nameFontSize,
              fontWeight: FontWeight.bold,
              color: onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '급수: $skillLevelDisplay',
                style: TextStyle(
                  fontSize: skillFontSize,
                  color: onPrimaryContainer.withAlpha(230),
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.0),
              Text(
                '플레이: ${player.played}',
                style: TextStyle(
                  fontSize: detailFontSize,
                  color: onPrimaryContainer.withAlpha(204),
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.0),
              Text(
                '대기: ${player.waited}',
                style: TextStyle(
                  fontSize: detailFontSize,
                  color: onPrimaryContainer.withAlpha(204),
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
        final newGamesPlayedWithMap = player.gamesPlayedWith.map((key, value) {
          final newKey = playersProvider.getPlayerById(key)?.name ?? "";
          return MapEntry(newKey, value);
        });

        final allPlayerNames = playersProvider.players.values.map((p) => p.name).toList();
        final playedWithPlayerNames = newGamesPlayedWithMap.keys.toSet();
        final notPlayedWithNames = allPlayerNames.where((name) => !playedWithPlayerNames.contains(name) && name != player.name).toList();

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
        section_index: section_index,
        sub_index: sub_index,
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
              color: const Color(0xAA007FFF),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${player.name} (${player.gender})',
                  style: TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.bold,
                    color: onPrimary,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
      // 드래그 중에는 순수 UI만 표시 (탭 기능 없음)
      childWhenDragging: Opacity(opacity: 0.5, child: playerItemDisplay),
      onDragStarted: () {
        if (section_index != -1 && onDragStarted != null) {
          onDragStarted!();
        }
      },
      onDraggableCanceled: (velocity, offset) {
        if (section_index != -1 && onDragEnded != null) {
          onDragEnded!();
        }
      },
      onDragCompleted: () {
        if (section_index != -1 && onDragEnded != null) {
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
  final int section_index;
  final int sub_index;
  final Function(
    PlayerDragData data,
    Player? targetPlayer,
    dynamic targetSectionId,
    int section_index,
    int sub_index,
  )
  onPlayerDropped;
  final bool isDropEnabled;
  final Color? backgroundColor;
  final VoidCallback? onDragStartedFromZone;
  final VoidCallback? onDragEndedFromZone;

  const PlayerDropZone({
    Key? key,
    required this.sectionId,
    this.player,
    required this.section_index,
    required this.sub_index,
    required this.onPlayerDropped,
    this.isDropEnabled = true,
    this.backgroundColor,
    this.onDragStartedFromZone,
    this.onDragEndedFromZone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileSize = screenWidth < 600;
    final double currentHeight = isMobileSize ? 140.0 : 240.0;

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
            section_index,
            sub_index,
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty && isDropEnabled;

        Color determinedDefaultBgColor = player != null && player!.manager
            ? const Color(0x77FFF700)
            : const Color(0x66FFFFFF);
        Color hoveringBgColor = const Color(0x88F0FFFF);

        return Container(
          height: currentHeight,
          padding: const EdgeInsets.all(0.0),
          margin: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
            color: isHovering ? hoveringBgColor : determinedDefaultBgColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withAlpha(64),
              width: 1.0,
            ),
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
                      ).colorScheme.onSurfaceVariant.withAlpha(179),
                    ),
                  )
                : DraggablePlayerItem(
                    player: player!,
                    sourceSectionId: sectionId,
                    section_index: section_index,
                    sub_index: sub_index,
                    onDragStarted: onDragStartedFromZone,
                    onDragEnded: onDragEndedFromZone,
                  ),
          ),
        );
      },
    );
  }
}
