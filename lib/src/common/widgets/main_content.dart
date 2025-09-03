import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';

// 왼쪽 상단 -> 오른쪽 하단 대각선
class DiagonalPainterLeft extends CustomPainter {
  final double strokeWidth;

  DiagonalPainterLeft({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xAA007FFF) // 선 색상
      ..strokeWidth = strokeWidth; // 선 두께
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 오른쪽 상단 -> 왼쪽 하단 대각선
class DiagonalPainterRight extends CustomPainter {
  final double strokeWidth;

  DiagonalPainterRight({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xAA007FFF) // 선 색상
      ..strokeWidth = strokeWidth; // 선 두께
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MainContent extends StatefulWidget {
  const MainContent({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  bool _showCourtHighlight = false;
  Map<int, bool> _courtGameStartedState = {};

  void _handlePlayerDrop(
    BuildContext context,
    PlayerDragData data,
    Player? targetPlayer,
    dynamic targetSectionId,
    int targetSectionIndex,
    int targetSubIndex,
  ) {
    final playersProvider = Provider.of<PlayersProvider>(
      context,
      listen: false,
    );
    final Player draggedPlayer = data.player;
    final int sourceSectionIndex = data.section_index;
    final int sourceSubIndex = data.sub_index;

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
        if (sourceSectionIndex == targetSectionIndex &&
            sourceSubIndex == targetSubIndex) {
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
    setState(() {
      _showCourtHighlight = true;
    });
  }

  void _onCourtPlayerDragEnded() {
    setState(() {
      _showCourtHighlight = false;
    });
  }

  String getGamesPlayedWith(List<Player?> list, int index1, int index2) {
    final maxIndex = index1 > index2 ? index1 : index2;
    if (list.length <= maxIndex) return '0';

    final player1 = list[index1];
    final player2 = list[index2];
    if (player1 == null || player2 == null) return '0';

    final gamesCount = player1.gamesPlayedWith[player2.id];
    return gamesCount?.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;

    final Color pastelBlue = Color(0x9987CEFA);
    final Color pastelPink = Color(0xFFFFD1DC); // 파스텔 핑크색 정의

    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    // playersProvider.unassignedPlayers로부터 리스트를 가져와서 수정 가능한 복사본을 만듭니다.
    final playerList = List<Player>.from(playersProvider.unassignedPlayers);
    playerList.sort((a, b) {
      int playedCompare = (a.played + a.lated).compareTo(b.played + b.lated);
      if (playedCompare != 0) {
        return playedCompare;
      }
      return b.waited.compareTo(a.waited);
    });

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
                      bool isGameStarted =
                          _courtGameStartedState[sectionIndex] ?? false;
                      return Container(
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          color: pastelBlue,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
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
                                  style: TextStyle(
                                    fontSize: widget.isMobileSize ? 20.0 : 32.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: widget.isMobileSize ? 16.0 : 32.0,
                                ),
                                SizedBox(
                                  width: widget.isMobileSize ? 40.0 : 50.0,
                                  height: widget.isMobileSize ? 30.0 : 45.0,
                                  child: FloatingActionButton(
                                    elevation: 2.0,
                                    onPressed: () {
                                      playersProvider
                                          .movePlayersFromCourtToUnassigned(
                                            sectionIndex,
                                            0,
                                          );
                                      setState(() {
                                        _courtGameStartedState[sectionIndex] =
                                            false;
                                      });
                                    },
                                    heroTag: 'refresh_fab_$sectionIndex',
                                    child: Icon(
                                      Icons.refresh,
                                      size: widget.isMobileSize ? 18.0 : 24.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                if (!isGameStarted)
                                  SizedBox(
                                    width: widget.isMobileSize ? 80.0 : 120.0,
                                    height: widget.isMobileSize ? 30.0 : 45.0,
                                    child: FloatingActionButton(
                                      elevation: 2.0,
                                      onPressed: () {
                                        playersProvider.assignPlayersToCourt(
                                          sectionIndex,
                                          skillWeight:
                                              optionsProvider.skillWeight,
                                          genderWeight:
                                              optionsProvider.genderWeight,
                                          waitedWeight:
                                              optionsProvider.waitedWeight,
                                          playedWeight:
                                              optionsProvider.playedWeight,
                                        );
                                        setState(() {
                                          _courtGameStartedState[sectionIndex] =
                                              true;
                                        });
                                      },
                                      heroTag: 'start_fab_$sectionIndex',
                                      child: Text(
                                        '자동 매칭',
                                        style: TextStyle(
                                          fontSize: widget.isMobileSize
                                              ? 12.0
                                              : 20.0,
                                        ),
                                      ),
                                    ),
                                  )
                                else // isGameStarted
                                  SizedBox(
                                    width: widget.isMobileSize ? 90.0 : 150.0,
                                    height: widget.isMobileSize ? 30.0 : 45.0,
                                    child: FloatingActionButton(
                                      elevation: 2.0,
                                      onPressed: () {
                                        playersProvider
                                            .incrementWaitedTimeForAllUnassignedPlayers();
                                        playersProvider
                                            .movePlayersFromCourtToUnassigned(
                                              sectionIndex,
                                            );
                                        setState(() {
                                          _courtGameStartedState[sectionIndex] =
                                              false;
                                        });
                                      },
                                      heroTag: 'stop_fab_$sectionIndex',
                                      child: Text(
                                        '경기 종료',
                                        style: TextStyle(
                                          fontSize: widget.isMobileSize
                                              ? 12.0
                                              : 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4.0),
                            SizedBox(
                              height: widget.isMobileSize ? 310.0 : 530.0,
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
                                              player:
                                                  item.asMap().containsKey(0)
                                                  ? item[0]
                                                  : null,
                                              section_index: sectionIndex,
                                              sub_index: 0,
                                              onPlayerDropped:
                                                  (
                                                    data,
                                                    droppedOnPlayer,
                                                    targetId,
                                                    targetSectionIdx,
                                                    targetSubIdx,
                                                  ) => _handlePlayerDrop(
                                                    context,
                                                    data,
                                                    droppedOnPlayer,
                                                    targetId,
                                                    targetSectionIdx,
                                                    targetSubIdx,
                                                  ),
                                              onDragStartedFromZone:
                                                  _onCourtPlayerDragStarted,
                                              onDragEndedFromZone:
                                                  _onCourtPlayerDragEnded,
                                            ),
                                          ),
                                          Expanded(
                                            child: PlayerDropZone(
                                              sectionId: '${sectionIndex}_1',
                                              player:
                                                  item.asMap().containsKey(1)
                                                  ? item[1]
                                                  : null,
                                              section_index: sectionIndex,
                                              sub_index: 1,
                                              onPlayerDropped:
                                                  (
                                                    data,
                                                    droppedOnPlayer,
                                                    targetId,
                                                    targetSectionIdx,
                                                    targetSubIdx,
                                                  ) => _handlePlayerDrop(
                                                    context,
                                                    data,
                                                    droppedOnPlayer,
                                                    targetId,
                                                    targetSectionIdx,
                                                    targetSubIdx,
                                                  ),
                                              onDragStartedFromZone:
                                                  _onCourtPlayerDragStarted,
                                              onDragEndedFromZone:
                                                  _onCourtPlayerDragEnded,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: widget.isMobileSize
                                            ? 10.0
                                            : 20.0,
                                      ),
                                      Visibility(
                                        visible: shouldShowDivider,
                                        child: Divider(
                                          color: Colors.grey,
                                          thickness: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        height: widget.isMobileSize
                                            ? 10.0
                                            : 20.0,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: PlayerDropZone(
                                              sectionId: '${sectionIndex}_2',
                                              player:
                                                  item.asMap().containsKey(2)
                                                  ? item[2]
                                                  : null,
                                              section_index: sectionIndex,
                                              sub_index: 2,
                                              onPlayerDropped:
                                                  (
                                                    data,
                                                    droppedOnPlayer,
                                                    targetId,
                                                    targetSectionIdx,
                                                    targetSubIdx,
                                                  ) => _handlePlayerDrop(
                                                    context,
                                                    data,
                                                    droppedOnPlayer,
                                                    targetId,
                                                    targetSectionIdx,
                                                    targetSubIdx,
                                                  ),
                                              onDragStartedFromZone:
                                                  _onCourtPlayerDragStarted,
                                              onDragEndedFromZone:
                                                  _onCourtPlayerDragEnded,
                                            ),
                                          ),
                                          Expanded(
                                            child: PlayerDropZone(
                                              sectionId: '${sectionIndex}_3',
                                              player:
                                                  item.asMap().containsKey(3)
                                                  ? item[3]
                                                  : null,
                                              section_index: sectionIndex,
                                              sub_index: 3,
                                              onPlayerDropped:
                                                  (
                                                    data,
                                                    droppedOnPlayer,
                                                    targetId,
                                                    targetSectionIdx,
                                                    targetSubIdx,
                                                  ) => _handlePlayerDrop(
                                                    context,
                                                    data,
                                                    droppedOnPlayer,
                                                    targetId,
                                                    targetSectionIdx,
                                                    targetSubIdx,
                                                  ),
                                              onDragStartedFromZone:
                                                  _onCourtPlayerDragStarted,
                                              onDragEndedFromZone:
                                                  _onCourtPlayerDragEnded,
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
                                        color: pastelPink, // 변경된 부분
                                        borderRadius: BorderRadius.circular(
                                          16.0,
                                        ),
                                      ),
                                      child: Text(
                                        getGamesPlayedWith(item, 0, 1),
                                        style: TextStyle(
                                          fontSize: isMobileSize ? 16.0 : 28.0,
                                          color: Colors.white,
                                        ),
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
                                        color: pastelPink, // 변경된 부분
                                        borderRadius: BorderRadius.circular(
                                          16.0,
                                        ),
                                      ),
                                      child: Text(
                                        getGamesPlayedWith(item, 2, 3),
                                        style: TextStyle(
                                          fontSize: isMobileSize ? 16.0 : 28.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: FractionalOffset(0.10, 0.5),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobileSize ? 5.0 : 15.0,
                                        vertical: isMobileSize ? 3.0 : 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pastelPink, // 변경된 부분
                                        borderRadius: BorderRadius.circular(
                                          16.0,
                                        ),
                                      ),
                                      child: Text(
                                        getGamesPlayedWith(item, 0, 2),
                                        style: TextStyle(
                                          fontSize: isMobileSize ? 16.0 : 28.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: FractionalOffset(0.90, 0.5),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isMobileSize ? 5.0 : 15.0,
                                        vertical: isMobileSize ? 3.0 : 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pastelPink, // 변경된 부분
                                        borderRadius: BorderRadius.circular(
                                          16.0,
                                        ),
                                      ),
                                      child: Text(
                                        getGamesPlayedWith(item, 1, 3),
                                        style: TextStyle(
                                          fontSize: isMobileSize ? 16.0 : 28.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: FractionalOffset(
                                      isMobileSize ? 0.40 : 0.43,
                                      0.5,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: isMobileSize ? 70.0 : 140.0,
                                          height: isMobileSize ? 30.0 : 50.0,
                                          child: CustomPaint(
                                            painter: DiagonalPainterLeft(
                                              strokeWidth: isMobileSize
                                                  ? 2.0
                                                  : 4.0,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isMobileSize
                                                ? 5.0
                                                : 15.0,
                                            vertical: isMobileSize ? 3.0 : 5.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: pastelPink,
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                          ),
                                          child: Text(
                                            getGamesPlayedWith(item, 0, 3),
                                            style: TextStyle(
                                              fontSize: isMobileSize
                                                  ? 16.0
                                                  : 28.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Align(
                                    alignment: FractionalOffset(
                                      isMobileSize ? 0.60 : 0.57,
                                      0.5,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: isMobileSize ? 70.0 : 140.0,
                                          height: isMobileSize ? 30.0 : 50.0,
                                          child: CustomPaint(
                                            painter: DiagonalPainterRight(
                                              strokeWidth: isMobileSize
                                                  ? 2.0
                                                  : 4.0,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isMobileSize
                                                ? 5.0
                                                : 15.0,
                                            vertical: isMobileSize ? 3.0 : 5.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: pastelPink,
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                          ),
                                          child: Text(
                                            getGamesPlayedWith(item, 1, 2),
                                            style: TextStyle(
                                              fontSize: isMobileSize
                                                  ? 16.0
                                                  : 28.0,
                                              color: Colors.white,
                                            ),
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
            ),
          ),
          const VerticalDivider(width: 1.0, color: Colors.grey),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Center(
                    child: FractionallySizedBox(
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
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: PlayerDropZone(
                                sectionId: playerSectionId,
                                player: player,
                                section_index: -1,
                                sub_index: playerIndex,
                                onPlayerDropped:
                                    (
                                      data,
                                      droppedOnPlayer,
                                      targetId,
                                      targetSectionIdx,
                                      targetSubIdx,
                                    ) => _handlePlayerDrop(
                                      context,
                                      data,
                                      droppedOnPlayer,
                                      targetId,
                                      targetSectionIdx,
                                      targetSubIdx,
                                    ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_showCourtHighlight)
                  Positioned.fill(
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
                          'unassigned_area_delete_overlay',
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
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
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
                                size: widget.isMobileSize ? 30.0 : 50.0,
                              ),
                            );
                          },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
