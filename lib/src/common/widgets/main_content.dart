import 'package:flutter/material.dart';
import 'package:hotswing/src/common/widgets/courts/assigned_court.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';

class MainContent extends StatefulWidget {
  const MainContent({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  late PlayersProvider _playersProvider;
  bool _showCourtHighlight = false;
  Map<int, bool> _courtGameStartedState = {};

  SortCriterion _sortCriterion = SortCriterion.played;
  bool _sortAscending = true;

  CourtViewSection selectedView = CourtViewSection.assignedView;

  @override
  void initState() {
    super.initState();
    _playersProvider = Provider.of<PlayersProvider>(context, listen: false);
    _playersProvider.addListener(_syncCourtStates);

    // 첫 빌드 완료 후 초기 상태 동기화 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCourtStates();
    });
  }

  @override
  void dispose() {
    _playersProvider.removeListener(_syncCourtStates);
    super.dispose();
  }

  String _getSortCriterionText(SortCriterion criterion) {
    switch (criterion) {
      case SortCriterion.played:
        return '경기';
      case SortCriterion.name:
        return '이름';
    }
  }

  void _syncCourtStates() {
    if (!mounted) return;

    final assignedPlayers = _playersProvider.assignedPlayers;
    bool needsUpdate = false;
    Map<int, bool> newStates = Map.from(_courtGameStartedState);

    for (int i = 0; i < assignedPlayers.length; i++) {
      final courtPlayers = assignedPlayers[i];
      final playerCount = courtPlayers.where((p) => p != null).length;
      final bool isFull = (playerCount == 4);
      final bool currentState = _courtGameStartedState[i] ?? false;

      if (isFull != currentState) {
        newStates[i] = isFull;
        needsUpdate = true;
      }
    }

    // 변경 사항이 있을 때만 setState 호출
    if (needsUpdate) {
      setState(() {
        _courtGameStartedState = newStates;
      });
    }
  }

  void _handlePlayerDrop(
    BuildContext context,
    PlayerDragData data,
    Player? targetPlayer,
    dynamic targetSectionId,
    String targetSectionKind,
    int targetSectionIndex,
    int targetSubIndex,
  ) {
    final playersProvider = Provider.of<PlayersProvider>(context, listen: false);
    final Player draggedPlayer = data.player;
    final String sourceSectionKind = data.sectionKind;
    final int sourceSectionIndex = data.sectionIndex;
    final int sourceSubIndex = data.subIndex;

    // 사례 1: 할당되지 않은 목록에서 드래그한 경우
    if (sourceSectionKind == PlayerSectionKind.unassigned.value) {
      if (targetSectionIndex != -1) {
        playersProvider.exchangeUnassignedPlayerWithCourtPlayer(
          unassignedPlayerToAssign: draggedPlayer,
          targetCourtSectionIndex: targetSectionIndex,
          targetCourtPlayerIndex: targetSubIndex,
          targetCourtKind: targetSectionKind,
        );
      }
    }
    // 사례 2: 코트 슬롯에서 드래그한 경우
    else {
      // 사례 2a: 다른 assigned 코트 슬롯에 놓은 경우
      if ([PlayerSectionKind.unassigned.value,PlayerSectionKind.drop].contains(targetSectionKind) ) {
        if (sourceSectionIndex == targetSectionIndex && sourceSubIndex == targetSubIndex) {
          return;
        }
        playersProvider.exchangePlayersInCourts(
          sectionIndex1: sourceSectionIndex,
          playerIndexInSection1: sourceSubIndex,
          sectionIndex2: targetSectionIndex,
          playerIndexInSection2: targetSubIndex,
          targetCourtKind: sourceSectionKind,
        );
      }
      // 사례 2b: 할당되지 않은 목록에 놓은 경우
      else {
        playersProvider.removePlayerFromCourt(
          sectionIndex: sourceSectionIndex,
          playerIndexInSection: sourceSubIndex,
          targetCourtKind: sourceSectionKind,
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

  Widget _buildViewButton(String label, CourtViewSection value) {
    final bool isSelected = (selectedView == value);

    final buttonTextStyle = TextStyle(fontSize: widget.isMobileSize ? 14.0 : 16.0);

    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0)),
      textStyle: WidgetStateProperty.all(buttonTextStyle),
      visualDensity: VisualDensity.compact,
    );

    return isSelected
        ? ElevatedButton(style: buttonStyle, onPressed: null, child: Text(label))
        : OutlinedButton(
            style: buttonStyle,
            onPressed: () {
              setState(() {
                selectedView = value;
              });
            },
            child: Text(label),
          );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;

    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    final playerList = List<Player>.from(playersProvider.unassignedPlayers);
    playerList.sort((a, b) {
      int playedCompare = (a.played + a.lated).compareTo(b.played + b.lated);
      if (playedCompare != 0) {
        return playedCompare;
      }
      return b.waited.compareTo(a.waited);
    });

    playerList.sort((a, b) {
      int compareResult;
      switch (_sortCriterion) {
        case SortCriterion.played:
          int playedCompare = (a.played + a.lated).compareTo(b.played + b.lated);
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

    final List<List<Player?>> sectionData = playersProvider.assignedPlayers;
    final List<List<Player?>> standbyCourts = playersProvider.standbyPlayers;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildViewButton('경기 코트', CourtViewSection.assignedView)),
                      const SizedBox(width: 8.0),
                      Expanded(child: _buildViewButton('대기 코트', CourtViewSection.standbyView)),
                    ],
                  ),
                ),

                Expanded(
                  child: switch (selectedView) {
                    CourtViewSection.assignedView => CourtSectionsView(
                      // '경기 코트' 뷰
                      isMobileSize: widget.isMobileSize,
                      sectionData: sectionData,
                      courtGameStartedState: _courtGameStartedState,
                      getGamesPlayedWith: getGamesPlayedWith,
                      onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
                      onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
                      onPlayerDrop: _handlePlayerDrop,
                      onRefreshCourt: (sectionIndex) {
                        playersProvider.movePlayersFromCourtToUnassigned(
                          sectionIndex: sectionIndex,
                          targetCourtKind: PlayerSectionKind.assigned.value,
                          played: 0,
                        );
                        setState(() {
                          _courtGameStartedState[sectionIndex] = false;
                        });
                      },
                      onAutoMatch: (sectionIndex) {
                        playersProvider.assignPlayersToCourt(
                          sectionIndex,
                          skillWeight: optionsProvider.skillWeight,
                          genderWeight: optionsProvider.genderWeight,
                          waitedWeight: optionsProvider.waitedWeight,
                          playedWeight: optionsProvider.playedWeight,
                          playedWithWeight: optionsProvider.playedWithWeight,
                          targetCourtKind: PlayerSectionKind.assigned.value,
                        );
                        setState(() {
                          _courtGameStartedState[sectionIndex] = true;
                        });
                      },
                      onEndGame: (sectionIndex) {
                        playersProvider.incrementWaitedTimeForAllUnassignedPlayers();
                        playersProvider.movePlayersFromCourtToUnassigned(
                          sectionIndex: sectionIndex,
                          targetCourtKind: PlayerSectionKind.assigned.value,
                        );
                        setState(() {
                          _courtGameStartedState[sectionIndex] = false;
                        });
                      },
                    ),

                    CourtViewSection.standbyView => CourtSectionsView(
                      // '대기 코트' 뷰
                      isMobileSize: widget.isMobileSize,
                      sectionData: standbyCourts,
                      courtGameStartedState: _courtGameStartedState,
                      getGamesPlayedWith: getGamesPlayedWith,
                      onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
                      onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
                      onPlayerDrop: _handlePlayerDrop,
                      onRefreshCourt: (sectionIndex) {
                        playersProvider.movePlayersFromCourtToUnassigned(
                          sectionIndex: sectionIndex,
                          targetCourtKind: PlayerSectionKind.standby.value,
                          played: 0,
                        );
                        setState(() {
                          _courtGameStartedState[sectionIndex] = false;
                        });
                      },
                      onAutoMatch: (sectionIndex) {
                        playersProvider.assignPlayersToCourt(
                          sectionIndex,
                          skillWeight: optionsProvider.skillWeight,
                          genderWeight: optionsProvider.genderWeight,
                          waitedWeight: optionsProvider.waitedWeight,
                          playedWeight: optionsProvider.playedWeight,
                          playedWithWeight: optionsProvider.playedWithWeight,
                          targetCourtKind: PlayerSectionKind.standby.value,
                        );
                        setState(() {
                          _courtGameStartedState[sectionIndex] = true;
                        });
                      },
                      onEndGame: (sectionIndex) {
                        playersProvider.incrementWaitedTimeForAllUnassignedPlayers();
                        playersProvider.movePlayersFromCourtToUnassigned(
                          sectionIndex: sectionIndex,
                          targetCourtKind: PlayerSectionKind.standby.value,
                        );
                        setState(() {
                          _courtGameStartedState[sectionIndex] = false;
                        });
                      },
                    ),
                  },
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1.0, color: Colors.grey),
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  child: Center(
                    child: FractionallySizedBox(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor,
                              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "대기 선수",
                                  style: TextStyle(
                                    fontSize: widget.isMobileSize ? 16.0 : 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    DropdownButton<SortCriterion>(
                                      value: _sortCriterion,
                                      items: SortCriterion.values.map((criterion) {
                                        return DropdownMenuItem<SortCriterion>(
                                          value: criterion,
                                          child: Text(_getSortCriterionText(criterion)),
                                        );
                                      }).toList(),
                                      onChanged: (SortCriterion? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _sortCriterion = newValue;
                                          });
                                        }
                                      },
                                      underline: Container(),
                                      style: TextStyle(
                                        fontSize: widget.isMobileSize ? 14.0 : 16.0,
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                      ),
                                      icon: Icon(Icons.arrow_drop_down, size: widget.isMobileSize ? 20.0 : 22.0),
                                    ),
                                    SizedBox(width: 4.0),
                                    IconButton(
                                      icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
                                      iconSize: widget.isMobileSize ? 20.0 : 22.0,
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      onPressed: () {
                                        setState(() {
                                          _sortAscending = !_sortAscending;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Column(
                                children: playerList.asMap().entries.map<Widget>((entry) {
                                  int playerIndex = entry.key;
                                  Player player = entry.value;
                                  final String playerSectionId = 'unassigned_$playerIndex';
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
                                        ) => _handlePlayerDrop(
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
                if (_showCourtHighlight)
                  Positioned.fill(
                    child: DragTarget<PlayerDragData>(
                      onWillAcceptWithDetails: (details) {
                        final data = details.data;
                        return data.sectionIndex != -1;
                      },
                      onAcceptWithDetails: (details) {
                        final data = details.data;
                        _handlePlayerDrop(context, data, null, 'unassigned_area_delete_overlay', 'drop', -1, -1);
                      },
                      builder: (BuildContext context, List<PlayerDragData?> candidateData, List<dynamic> rejectedData) {
                        final bool isHovering = candidateData.isNotEmpty;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                            color: isHovering ? Colors.black.withAlpha(50) : Colors.black.withAlpha(25),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.delete, color: Colors.white, size: widget.isMobileSize ? 30.0 : 50.0),
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
