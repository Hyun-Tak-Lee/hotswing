import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key, required this.isMobileSize});

  final bool isMobileSize;

  void _handlePlayerDrop(
    BuildContext context,
    PlayerDragData data,
    dynamic targetSectionId,
    int targetSectionIndex,
    int targetSubIndex,
  ) {
    print(
      "Player ${data.player.name} (from ${data.sourceSectionId} [${data.section_index}, ${data.sub_index}]) dropped on $targetSectionId [$targetSectionIndex, $targetSubIndex]. (Action not yet implemented)",
    );
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
            child: Center(
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
                        height: isMobileSize
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
                                      onPlayerDropped: (data, targetId, targetSectionIdx, targetSubIdx) =>
                                          _handlePlayerDrop(
                                            context,
                                            data,
                                            targetId,
                                            targetSectionIdx,
                                            targetSubIdx,
                                          ),
                                      backgroundColor: pastelLightBlue,
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
                                      onPlayerDropped: (data, targetId, targetSectionIdx, targetSubIdx) =>
                                          _handlePlayerDrop(
                                            context,
                                            data,
                                            targetId,
                                            targetSectionIdx,
                                            targetSubIdx,
                                          ),
                                      backgroundColor: pastelLightBlue,
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
                                      onPlayerDropped: (data, targetId, targetSectionIdx, targetSubIdx) =>
                                          _handlePlayerDrop(
                                            context,
                                            data,
                                            targetId,
                                            targetSectionIdx,
                                            targetSubIdx,
                                          ),
                                      backgroundColor: pastelLightBlue,
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
                                      onPlayerDropped: (data, targetId, targetSectionIdx, targetSubIdx) =>
                                          _handlePlayerDrop(
                                            context,
                                            data,
                                            targetId,
                                            targetSectionIdx,
                                            targetSubIdx,
                                          ),
                                      backgroundColor: pastelLightBlue,
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
          ),
          const VerticalDivider(width: 1.0, color: Colors.grey),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Center(
                // Center 위젯으로 감싸 중앙 정렬 유지
                child: FractionallySizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: playerList.asMap().entries.map<Widget>((entry) {
                        int playerIndex = entry.key; // 플레이어 리스트에서의 인덱스
                        Player player = entry.value; // 플레이어 객체
                        final String playerSectionId =
                            'unassigned_$playerIndex';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: PlayerDropZone(
                            sectionId: playerSectionId,
                            player: player,
                            section_index: -1, // Unassigned section
                            sub_index: playerIndex,
                            // PlayerDropZone이 이 플레이어를 DraggablePlayerItem으로 표시할 것으로 예상
                            onPlayerDropped: (data, targetId, targetSectionIdx, targetSubIdx) =>
                                _handlePlayerDrop(context, data, targetId, targetSectionIdx, targetSubIdx),
                            backgroundColor: Colors.grey[200], // 각 드롭존 배경색
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
