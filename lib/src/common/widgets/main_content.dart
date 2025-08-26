import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';

class MainContent extends StatefulWidget {
  const MainContent({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  bool _showCourtHighlight = false;

  void _handlePlayerDrop(
    BuildContext context,
    PlayerDragData data,
    Player? targetPlayer,
    dynamic targetSectionId,
    int targetSectionIndex,
    int targetSubIndex,
  ) {
    final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
    final Player draggedPlayer = data.player;
    final int sourceSectionIndex = data.section_index;
    final int sourceSubIndex = data.sub_index;

    print("${data.player.name}, ${data.sourceSectionId}, [${data.section_index}, ${data.sub_index}] | ${targetPlayer?.name ?? 'none'}, $targetSectionId, [$targetSectionIndex, $targetSubIndex] (Action not yet implemented)");

    // 사례 1: 할당되지 않은 목록에서 드래그한 경우
    if (sourceSectionIndex == -1) {
      if (targetSectionIndex != -1) {
        playersProvider.exchangeUnassignedPlayerWithCourtPlayer(
          unassignedPlayerToAssign: draggedPlayer,
          targetCourtSectionIndex: targetSectionIndex,
          targetCourtPlayerIndex: targetSubIndex,
        );
      }
    }
    // 사례 2: 코트 슬롯에서 드래그한 경우
    else {
      // 사례 2a: 다른 코트 슬롯에 놓은 경우
      if (targetSectionIndex != -1) {
        if (sourceSectionIndex == targetSectionIndex && sourceSubIndex == targetSubIndex) {
          return;
        }
        playersProvider.exchangePlayersInCourts(
          sectionIndex1: sourceSectionIndex,
          playerIndexInSection1: sourceSubIndex,
          sectionIndex2: targetSectionIndex,
          playerIndexInSection2: targetSubIndex,
        );
      }
      // 사례 2b: 할당되지 않은 목록에 놓은 경우
      else {
        playersProvider.removePlayerFromCourt(
          sectionIndex: sourceSectionIndex,
          playerIndexInSection: sourceSubIndex,
        );
      }
    }
  }

  void _onCourtPlayerDragStarted() {
    print('drag_start');
    setState(() {
      _showCourtHighlight = true;
    });
  }

  void _onCourtPlayerDragEnded() {
    print('drag_end');
    setState(() {
      _showCourtHighlight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;

    final Color pastelBlue = Colors.lightBlue.shade50;
    final Color pastelLightBlue = Color(0xFFFAFFFF);

    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    final playerList = playersProvider.unassignedPlayers;
    final List<List<Player?>> sectionData = playersProvider.assignedPlayers;
    final bool shouldShowDivider = optionsProvider.divideTeam;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: sectionData.asMap().entries.map((entry) {
                          int sectionIndex = entry.key;
                          List<Player?> item = entry.value;

                          return Container(
                            margin: const EdgeInsets.all(5.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: pastelBlue,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            height: widget.isMobileSize
                                ? screenHeight * 0.25
                                : screenHeight * 0.2,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: PlayerDropZone(
                                          sectionId: '${sectionIndex}_0',
                                          player: item.asMap().containsKey(0)
                                              ? item[0]
                                              : null,
                                          section_index: sectionIndex,
                                          sub_index: 0,
                                          onPlayerDropped: (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                              _handlePlayerDrop(
                                                context,
                                                data,
                                                droppedOnPlayer,
                                                targetId,
                                                targetSectionIdx,
                                                targetSubIdx,
                                              ),
                                          backgroundColor: pastelLightBlue,
                                          onDragStartedFromZone: _onCourtPlayerDragStarted,
                                          onDragEndedFromZone: _onCourtPlayerDragEnded,
                                        ),
                                      ),
                                      Expanded(
                                        child: PlayerDropZone(
                                          sectionId: '${sectionIndex}_1',
                                          player: item.asMap().containsKey(1)
                                              ? item[1]
                                              : null,
                                          section_index: sectionIndex,
                                          sub_index: 1,
                                          onPlayerDropped: (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                              _handlePlayerDrop(
                                                context,
                                                data,
                                                droppedOnPlayer,
                                                targetId,
                                                targetSectionIdx,
                                                targetSubIdx,
                                              ),
                                          backgroundColor: pastelLightBlue,
                                          onDragStartedFromZone: _onCourtPlayerDragStarted,
                                          onDragEndedFromZone: _onCourtPlayerDragEnded,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: shouldShowDivider,
                                  child: Divider(color: Colors.grey, thickness: 1),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: PlayerDropZone(
                                          sectionId: '${sectionIndex}_2',
                                          player: item.asMap().containsKey(2)
                                              ? item[2]
                                              : null,
                                          section_index: sectionIndex,
                                          sub_index: 2,
                                          onPlayerDropped: (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                              _handlePlayerDrop(
                                                context,
                                                data,
                                                droppedOnPlayer,
                                                targetId,
                                                targetSectionIdx,
                                                targetSubIdx,
                                              ),
                                          backgroundColor: pastelLightBlue,
                                          onDragStartedFromZone: _onCourtPlayerDragStarted,
                                          onDragEndedFromZone: _onCourtPlayerDragEnded,
                                        ),
                                      ),
                                      Expanded(
                                        child: PlayerDropZone(
                                          sectionId: '${sectionIndex}_3',
                                          player: item.asMap().containsKey(3)
                                              ? item[3]
                                              : null,
                                          section_index: sectionIndex,
                                          sub_index: 3,
                                          onPlayerDropped: (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                              _handlePlayerDrop(
                                                context,
                                                data,
                                                droppedOnPlayer,
                                                targetId,
                                                targetSectionIdx,
                                                targetSubIdx,
                                              ),
                                          backgroundColor: pastelLightBlue,
                                          onDragStartedFromZone: _onCourtPlayerDragStarted,
                                          onDragEndedFromZone: _onCourtPlayerDragEnded,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                if (_showCourtHighlight)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.3),
                      alignment: Alignment.center,
                      child: Text(
                        '코트 구역 고정',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1.0, color: Colors.grey),
          Expanded(
            flex: 1,
            child: DragTarget<PlayerDragData>(
              onWillAcceptWithDetails: (details) {
                final data = details.data;
                return data.section_index != -1;
              },
              onAcceptWithDetails: (details) {
                final data = details.data;
                _handlePlayerDrop(
                  context,
                  data,
                  null,
                  'unassigned_area_target',
                  -1,
                  -1,
                );
              },
              builder: (BuildContext context, List<PlayerDragData?> candidateData, List<dynamic> rejectedData) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                   decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: FractionallySizedBox(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: playerList.asMap().entries.map<Widget>((entry) {
                            int playerIndex = entry.key;
                            Player player = entry.value;
                            final String playerSectionId = 'unassigned_$playerIndex';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: PlayerDropZone(
                                sectionId: playerSectionId,
                                player: player,
                                section_index: -1,
                                sub_index: playerIndex,
                                onPlayerDropped: (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                    _handlePlayerDrop(context, data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx),
                                backgroundColor: Colors.grey[200],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
