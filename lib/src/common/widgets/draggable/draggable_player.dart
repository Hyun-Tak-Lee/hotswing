import 'package:flutter/material.dart';
import 'package:hotswing/src/providers/players_provider.dart'; // Player 모델 임포트

// 드래그되는 플레이어의 데이터와 원래 소속 섹션 정보를 전달하기 위한 클래스
class PlayerDragData {
  final Player player;
  final dynamic sourceSectionId; // 플레이어가 어느 섹션에서 왔는지 식별
  final int section_index;
  final int sub_index;

  PlayerDragData({required this.player, required this.sourceSectionId, required this.section_index, required this.sub_index});
}

// 개별 플레이어를 나타내는 드래그 가능한 위젯
class DraggablePlayerItem extends StatelessWidget {
  final Player player;
  final dynamic sourceSectionId; // 이 플레이어가 현재 속한 섹션의 ID
  final int section_index;
  final int sub_index;
  final bool isDragEnabled; // 특정 플레이어의 드래그를 비활성화할 때 사용

  const DraggablePlayerItem({
    Key? key,
    required this.player,
    required this.sourceSectionId,
    required this.section_index,
    required this.sub_index,
    this.isDragEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 플레이어 아이템의 기본 UI
    Widget playerContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(153),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
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

    return Draggable<PlayerDragData>(
      data: PlayerDragData(player: player, sourceSectionId: sourceSectionId, section_index: section_index, sub_index: sub_index),
      // 드래그 중 손가락을 따라다니는 위젯
      feedback: Material(
        elevation: 4.0,
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
              color: Theme.of(context).colorScheme.primary.withAlpha(204),
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
      // 드래그가 시작된 후 원래 위치에 표시될 위젯
      childWhenDragging: Opacity(opacity: 0.5, child: playerContent),
      // 드래그되지 않을 때 기본적으로 표시될 위젯
      child: playerContent,
    );
  }
}

// 플레이어를 담고, 다른 플레이어를 드롭할 수 있는 영역 위젯
class PlayerDropZone extends StatelessWidget {
  final dynamic sectionId; // 이 드롭 존의 고유 ID
  final Player? player; // 이 존에 표시될 플레이어 (단일 플레이어)
  final int section_index;
  final int sub_index;
  final Function(PlayerDragData data, dynamic targetSectionId, int section_index, int sub_index) onPlayerDropped;
  final bool isDropEnabled; // 이 존에 드롭을 허용할지 여부
  final Color? backgroundColor; // 존 배경색 (호버링 시 변경 위함)

  const PlayerDropZone({
    Key? key,
    required this.sectionId,
    this.player,
    required this.section_index,
    required this.sub_index,
    required this.onPlayerDropped,
    this.isDropEnabled = true,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<PlayerDragData>(
      onWillAcceptWithDetails: (details) {
        return isDropEnabled;
      },
      onAcceptWithDetails: (details) {
        if (isDropEnabled) {
          onPlayerDropped(details.data, sectionId, section_index, sub_index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        // 플레이어 존재 여부와 관계없이 드롭 가능하면 호버링 효과 표시
        bool isHovering = candidateData.isNotEmpty && isDropEnabled;
        Color defaultBgColor =
            backgroundColor ??
            Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(77);
        Color hoveringBgColor = Theme.of(
          context,
        ).colorScheme.primaryContainer.withAlpha(128);

        return Container(
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: isHovering ? hoveringBgColor : defaultBgColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: isHovering
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withAlpha(128),
              width: isHovering ? 2.0 : 1.0,
            ),
          ),
          child: Center(
            child: player == null
                ? Text(
                    isDropEnabled ? '비어있음' : 'X',
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
                  ),
          ),
        );
      },
    );
  }
}
