import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';

enum SortCriterion { played, name }

class WaitingPlayersPanel extends StatefulWidget {
  final bool showDeleteOverlay;
  final Function(
    BuildContext context,
    PlayerDragData data,
    Player? targetPlayer,
    dynamic targetSectionId,
    String targetSectionKind,
    int targetSectionIndex,
    int targetSubIndex,
  )
  onPlayerDrop;

  const WaitingPlayersPanel({
    super.key,
    required this.showDeleteOverlay,
    required this.onPlayerDrop,
  });

  @override
  State<WaitingPlayersPanel> createState() => _WaitingPlayersPanelState();
}

class _WaitingPlayersPanelState extends State<WaitingPlayersPanel> {
  SortCriterion _sortCriterion = SortCriterion.played;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    final playerList = List<Player>.from(playersProvider.unassignedPlayers);

    // 정렬 로직 적용
    playerList.sort((a, b) {
      int compareResult;
      switch (_sortCriterion) {
        case SortCriterion.played:
          int activateCompare = (b.activate ? 1 : 0).compareTo(
            a.activate ? 1 : 0,
          );
          if (activateCompare != 0) {
            return activateCompare;
          }
          int playedCompare = (a.played + a.lated).compareTo(
            b.played + b.lated,
          );
          if (playedCompare != 0) {
            compareResult = playedCompare;
          }
          compareResult = b.waited.compareTo(a.waited);
          break;
        case SortCriterion.name:
          compareResult = a.name.compareTo(b.name);
          break;
      }

      return _sortAscending ? compareResult : -compareResult;
    });

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Center(
            child: FractionallySizedBox(
              child: Column(
                children: [
                  _buildHeader(context, isTablet, playerList.length),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: playerList.asMap().entries.map<Widget>((
                          entry,
                        ) {
                          int playerIndex = entry.key;
                          Player player = entry.value;
                          final String playerSectionId =
                              'unassigned_$playerIndex';
                          return PlayerDropZone(
                            player: player,
                            sectionId: playerSectionId,
                            sectionKind: PlayerSectionKind.unassigned.value,
                            sectionIndex: -1,
                            subIndex: playerIndex,
                            onPlayerDropped:
                                (
                                  data,
                                  droppedOnPlayer,
                                  targetId,
                                  sectionKind,
                                  targetSectionIdx,
                                  targetSubIdx,
                                ) => widget.onPlayerDrop(
                                  context,
                                  data,
                                  droppedOnPlayer,
                                  targetId,
                                  sectionKind,
                                  targetSectionIdx,
                                  targetSubIdx,
                                ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.showDeleteOverlay)
          Positioned.fill(
            child: DragTarget<PlayerDragData>(
              onWillAcceptWithDetails: (details) {
                final data = details.data;
                return data.sectionIndex != -1;
              },
              onAcceptWithDetails: (details) {
                final data = details.data;
                widget.onPlayerDrop(
                  context,
                  data,
                  null,
                  'unassigned_area_delete_overlay',
                  'drop',
                  -1,
                  -1,
                );
              },
              builder:
                  (
                    BuildContext context,
                    List<PlayerDragData?> candidateData,
                    List<dynamic> rejectedData,
                  ) {
                    final bool isHovering = candidateData.isNotEmpty;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: isHovering
                            ? Colors.black.withAlpha(50)
                            : Colors.black.withAlpha(25),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: isTablet ? 50.0 : 30.0,
                      ),
                    );
                  },
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (isTablet) ...[
                  TextSpan(
                    text: "대기",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const TextSpan(text: " "),
                ],
                TextSpan(
                  text: '$count',
                  style: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<SortCriterion>(
            initialValue: _sortCriterion,
            color: const Color(0xFFFAFAFA), // 눈 안 부신 부드러운 흰색
            onSelected: (SortCriterion newValue) {
              setState(() {
                _sortCriterion = newValue;
                _sortAscending = true;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<SortCriterion>(
                  value: SortCriterion.played,
                  child: Text('경기 적은 순'),
                ),
                const PopupMenuItem<SortCriterion>(
                  value: SortCriterion.name,
                  child: Text('이름 가나다 순'),
                ),
              ];
            },
            child: isTablet
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), // 연한 파스텔 블루 배경
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBBDEFB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _sortCriterion == SortCriterion.played
                              ? '경기 적은 순'
                              : '이름 가나다 순',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.0,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.sort, size: 24.0, color: Colors.black54),
                  ),
          ),
        ],
      ),
    );
  }
}
