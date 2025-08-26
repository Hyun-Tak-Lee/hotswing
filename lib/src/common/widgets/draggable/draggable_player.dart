import 'package:flutter/material.dart';
import 'package:hotswing/src/providers/players_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    Widget playerContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        player.name,
        style: TextStyle(
          fontSize: 24.0,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (!isDragEnabled) {
      return playerContent;
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
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 12.0,
            ),
            decoration: BoxDecoration(
              color: const Color(0xAA007FFF),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: 24.0,
                color: Theme.of(context).colorScheme.onPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: playerContent),
      onDragStarted: () {
        // section_index가 -1이 아닌 경우 (즉, 코트 구역의 플레이어인 경우) 콜백 호출
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
      child: playerContent,
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
        Color defaultBgColor = backgroundColor ?? const Color(0x20F0FFFF);
        Color hoveringBgColor = const Color(0x20F0FFFF);

        return Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isHovering ? hoveringBgColor : defaultBgColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isHovering
                  ? const Color(0xFFFFD1DC)
                  : Theme.of(context).colorScheme.outline.withAlpha(64),
              width: isHovering ? 2.0 : 1.0,
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
