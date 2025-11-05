//
// 새 파일: court_sections_view.dart
//
import 'package:flutter/material.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/players/player.dart';

class CourtSectionsView extends StatelessWidget {
  final bool isMobileSize;
  final List<List<Player?>> sectionData;
  final Map<int, bool> courtGameStartedState;
  final Function(int) onRefreshCourt;
  final Function(int) onAutoMatch;
  final Function(int) onEndGame;
  final Function(BuildContext, PlayerDragData, Player?, dynamic, int, int) onPlayerDrop;
  final VoidCallback onCourtPlayerDragStarted;
  final VoidCallback onCourtPlayerDragEnded;
  final String Function(List<Player?>, int, int) getGamesPlayedWith;

  const CourtSectionsView({
    super.key,
    required this.isMobileSize,
    required this.sectionData,
    required this.courtGameStartedState,
    required this.onRefreshCourt,
    required this.onAutoMatch,
    required this.onEndGame,
    required this.onPlayerDrop,
    required this.onCourtPlayerDragStarted,
    required this.onCourtPlayerDragEnded,
    required this.getGamesPlayedWith,
  });

  @override
  Widget build(BuildContext context) {
    final Color pastelBlue = Color(0x9987CEFA);
    final Color playedWithColor = Color(0xFF89A7DA);
    final Color playedWithTextColor = Color(0xFFFFEB3B);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: sectionData.asMap().entries.map((entry) {
              int sectionIndex = entry.key;
              List<Player?> item = entry.value;
              bool isGameStarted = courtGameStartedState[sectionIndex] ?? false;
              return Container(
                margin: const EdgeInsets.all(5.0),
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(color: pastelBlue, borderRadius: BorderRadius.circular(20.0)),
                child: Column(
                  // Outer Column for title + Stack
                  children: [
                    Row(
                      // Title and buttons
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${sectionIndex + 1} 코트',
                          style: TextStyle(fontSize: isMobileSize ? 20.0 : 32.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: isMobileSize ? 16.0 : 32.0),
                        SizedBox(
                          width: isMobileSize ? 40.0 : 50.0,
                          height: isMobileSize ? 30.0 : 45.0,
                          child: FloatingActionButton(
                            elevation: 2.0,
                            onPressed: () => onRefreshCourt(sectionIndex),
                            heroTag: 'refresh_fab_$sectionIndex',
                            child: Icon(Icons.refresh, size: isMobileSize ? 18.0 : 24.0),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        if (!isGameStarted)
                          SizedBox(
                            width: isMobileSize ? 80.0 : 120.0,
                            height: isMobileSize ? 30.0 : 45.0,
                            child: FloatingActionButton(
                              elevation: 2.0,
                              onPressed: () => onAutoMatch(sectionIndex),
                              heroTag: 'start_fab_$sectionIndex',
                              child: Text('자동 매칭', style: TextStyle(fontSize: isMobileSize ? 12.0 : 20.0)),
                            ),
                          )
                        else // isGameStarted
                          SizedBox(
                            width: isMobileSize ? 90.0 : 150.0,
                            height: isMobileSize ? 30.0 : 45.0,
                            child: FloatingActionButton(
                              elevation: 2.0,
                              onPressed: () => onEndGame(sectionIndex),
                              heroTag: 'stop_fab_$sectionIndex',
                              child: Text('경기 종료', style: TextStyle(fontSize: isMobileSize ? 12.0 : 20.0)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    SizedBox(
                      height: isMobileSize ? 310.0 : 510.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: PlayerDropZone(
                                      sectionId: '${sectionIndex}_0',
                                      player: item.asMap().containsKey(0) ? item[0] : null,
                                      sectionKind: 'assigned',
                                      sectionIndex: sectionIndex,
                                      subIndex: 0,
                                      onPlayerDropped:
                                          (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                              onPlayerDrop(
                                                context,
                                                data,
                                                droppedOnPlayer,
                                                targetId,
                                                targetSectionIdx,
                                                targetSubIdx,
                                              ),
                                      onDragStartedFromZone: onCourtPlayerDragStarted,
                                      onDragEndedFromZone: onCourtPlayerDragEnded,
                                    ),
                                  ),
                                  Expanded(
                                    child: PlayerDropZone(
                                      sectionId: '${sectionIndex}_1',
                                      player: item.asMap().containsKey(1) ? item[1] : null,
                                      sectionKind: 'assigned',
                                      sectionIndex: sectionIndex,
                                      subIndex: 1,
                                      onPlayerDropped:
                                          (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                              onPlayerDrop(
                                                context,
                                                data,
                                                droppedOnPlayer,
                                                targetId,
                                                targetSectionIdx,
                                                targetSubIdx,
                                              ),
                                      onDragStartedFromZone: onCourtPlayerDragStarted,
                                      onDragEndedFromZone: onCourtPlayerDragEnded,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: isMobileSize ? 10.0 : 10.0),
                              SizedBox(height: isMobileSize ? 10.0 : 10.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: PlayerDropZone(
                                      sectionId: '${sectionIndex}_2',
                                      player: item.asMap().containsKey(2) ? item[2] : null,
                                      sectionIndex: sectionIndex,
                                      sectionKind: 'assigned',
                                      subIndex: 2,
                                      onPlayerDropped:
                                          (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                              onPlayerDrop(
                                                context,
                                                data,
                                                droppedOnPlayer,
                                                targetId,
                                                targetSectionIdx,
                                                targetSubIdx,
                                              ),
                                      onDragStartedFromZone: onCourtPlayerDragStarted,
                                      onDragEndedFromZone: onCourtPlayerDragEnded,
                                    ),
                                  ),
                                  Expanded(
                                    child: PlayerDropZone(
                                      sectionId: '${sectionIndex}_3',
                                      player: item.asMap().containsKey(3) ? item[3] : null,
                                      sectionKind: 'assigned',
                                      sectionIndex: sectionIndex,
                                      subIndex: 3,
                                      onPlayerDropped:
                                          (data, droppedOnPlayer, targetId, targetSectionIdx, targetSubIdx) =>
                                              onPlayerDrop(
                                                context,
                                                data,
                                                droppedOnPlayer,
                                                targetId,
                                                targetSectionIdx,
                                                targetSubIdx,
                                              ),

                                      onDragStartedFromZone: onCourtPlayerDragStarted,
                                      onDragEndedFromZone: onCourtPlayerDragEnded,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Indicators
                          Align(
                            alignment: FractionalOffset(0.5, 0.20),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobileSize ? 5.0 : 15.0,
                                vertical: isMobileSize ? 3.0 : 5.0,
                              ),
                              decoration: BoxDecoration(
                                color: playedWithColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                getGamesPlayedWith(item, 0, 1),
                                style: TextStyle(fontSize: isMobileSize ? 16.0 : 28.0, color: playedWithTextColor),
                              ),
                            ),
                          ),
                          Align(
                            alignment: FractionalOffset(0.5, 0.80),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobileSize ? 5.0 : 15.0,
                                vertical: isMobileSize ? 3.0 : 5.0,
                              ),
                              decoration: BoxDecoration(
                                color: playedWithColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                getGamesPlayedWith(item, 2, 3),
                                style: TextStyle(fontSize: isMobileSize ? 16.0 : 28.0, color: playedWithTextColor),
                              ),
                            ),
                          ),
                          Align(
                            alignment: FractionalOffset(0.05, 0.5),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobileSize ? 5.0 : 15.0,
                                vertical: isMobileSize ? 3.0 : 5.0,
                              ),
                              decoration: BoxDecoration(
                                color: playedWithColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                getGamesPlayedWith(item, 0, 2),
                                style: TextStyle(fontSize: isMobileSize ? 16.0 : 28.0, color: playedWithTextColor),
                              ),
                            ),
                          ),
                          Align(
                            alignment: FractionalOffset(0.95, 0.5),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobileSize ? 5.0 : 15.0,
                                vertical: isMobileSize ? 3.0 : 5.0,
                              ),
                              decoration: BoxDecoration(
                                color: playedWithColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                getGamesPlayedWith(item, 1, 3),
                                style: TextStyle(fontSize: isMobileSize ? 16.0 : 28.0, color: playedWithTextColor),
                              ),
                            ),
                          ),
                          Align(
                            alignment: FractionalOffset(isMobileSize ? 0.25 : 0.35, 0.5),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobileSize ? 5.0 : 15.0,
                                    vertical: isMobileSize ? 3.0 : 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: playedWithColor,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Text(
                                    '1⇄4 ' + getGamesPlayedWith(item, 0, 3),
                                    style: TextStyle(fontSize: isMobileSize ? 16.0 : 28.0, color: playedWithTextColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: FractionalOffset(isMobileSize ? 0.75 : 0.65, 0.5),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobileSize ? 5.0 : 15.0,
                                    vertical: isMobileSize ? 3.0 : 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: playedWithColor,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Text(
                                    '2⇄3 ' + getGamesPlayedWith(item, 1, 2),
                                    style: TextStyle(fontSize: isMobileSize ? 16.0 : 28.0, color: playedWithTextColor),
                                  ),
                                ),
                              ],
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
    );
  }
}
