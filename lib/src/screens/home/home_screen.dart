import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/assigned_court.dart';
import 'package:hotswing/src/common/widgets/courts/standby_court.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/screens/home/widgets/court_view_selector.dart';
import 'package:hotswing/src/screens/home/widgets/waiting_players_panel.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PlayersProvider _playersProvider;
  bool _showCourtHighlight = false;
  Map<int, bool> _courtGameStartedState = {};

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
    final playersProvider = Provider.of<PlayersProvider>(
      context,
      listen: false,
    );
    final String sourceSectionKind = data.sectionKind;
    final int sourceSectionIndex = data.sectionIndex;
    final int sourceSubIndex = data.subIndex;

    // 1. Source에서 제거 (Drag된 Player)
    Player? draggedPlayer;
    if (sourceSectionKind == PlayerSectionKind.unassigned.value) {
      draggedPlayer = data.player;
      playersProvider.removeUnassignedPlayer(draggedPlayer);
    } else if (sourceSectionKind == PlayerSectionKind.assigned.value) {
      draggedPlayer = playersProvider.removeAssignedPlayer(
        sourceSectionIndex,
        sourceSubIndex,
      );
    } else if (sourceSectionKind == PlayerSectionKind.standby.value) {
      draggedPlayer = playersProvider.removeStandbyPlayer(
        sourceSectionIndex,
        sourceSubIndex,
      );
    }

    if (draggedPlayer == null) return;

    // 2. Target 상호작용 준비
    // Target이 대기 목록(unassigned)이거나 삭제 영역(drop)이면, 단순히 대기 목록에 추가하고 종료.
    if (targetSectionKind == PlayerSectionKind.unassigned.value ||
        targetSectionKind == PlayerSectionKind.drop.value) {
      playersProvider.addUnassignedPlayer(draggedPlayer);
      return;
    }

    // 3. Target에서 기존 플레이어 제거 (자리가 차 있는 경우) - 교환 여부 확인
    Player? existingTargetPlayer;
    if (targetSectionKind == PlayerSectionKind.assigned.value) {
      existingTargetPlayer = playersProvider.removeAssignedPlayer(
        targetSectionIndex,
        targetSubIndex,
      );
    } else if (targetSectionKind == PlayerSectionKind.standby.value) {
      existingTargetPlayer = playersProvider.removeStandbyPlayer(
        targetSectionIndex,
        targetSubIndex,
      );
    }

    // 4. 드래그된 플레이어를 Target에 추가
    if (targetSectionKind == PlayerSectionKind.assigned.value) {
      playersProvider.addAssignedPlayer(
        draggedPlayer,
        targetSectionIndex,
        targetSubIndex,
      );
    } else if (targetSectionKind == PlayerSectionKind.standby.value) {
      playersProvider.addStandbyPlayer(
        draggedPlayer,
        targetSectionIndex,
        targetSubIndex,
      );
    }

    // 5. 기존 Target의 플레이어를 Source로 이동 (교환)
    if (sourceSectionKind == PlayerSectionKind.unassigned.value) {
      playersProvider.addUnassignedPlayer(existingTargetPlayer);
    } else if (sourceSectionKind == PlayerSectionKind.assigned.value) {
      playersProvider.addAssignedPlayer(
        existingTargetPlayer,
        sourceSectionIndex,
        sourceSubIndex,
      );
    } else if (sourceSectionKind == PlayerSectionKind.standby.value) {
      playersProvider.addStandbyPlayer(
        existingTargetPlayer,
        sourceSectionIndex,
        sourceSubIndex,
      );
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

    final gamesCount = player1.gamesPlayedWith[player2.id.hexString];
    return gamesCount?.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final isMobileSize = !isTablet;
    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(context);

    final List<List<Player?>> sectionData = playersProvider.assignedPlayers;
    final List<List<Player?>> standbyCourts = playersProvider.standbyPlayers;

    return Container(
      // MainWrapper의 모서리 둥글기(20dp)를 고려하지만, 공간 활용을 위해 패딩 최소화
      padding: EdgeInsets.only(
        top: isMobileSize ? 4.0 : 8.0,
        left: 0,
        right: 0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Column(
              children: [
                CourtViewSelector(
                  selectedView: selectedView,
                  onSelectionChanged: (value) {
                    setState(() {
                      selectedView = value;
                    });
                  },
                ),

                Expanded(
                  child: switch (selectedView) {
                    CourtViewSection.assignedView => CourtSectionsView(
                      // '경기 코트' 뷰
                      isMobileSize: isMobileSize,
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
                        playersProvider
                            .incrementWaitedTimeForAllUnassignedPlayers();
                        playersProvider.movePlayersFromCourtToUnassigned(
                          sectionIndex: sectionIndex,
                          targetCourtKind: PlayerSectionKind.assigned.value,
                        );
                        setState(() {
                          _courtGameStartedState[sectionIndex] = false;
                        });
                      },
                      onPopStandByCourt: (sectionIndex) {
                        _playersProvider.popStandByPlayers(sectionIndex);
                      },
                    ),

                    CourtViewSection.standbyView => StandbyCourtSectionsView(
                      // '대기 코트' 뷰
                      isMobileSize: isMobileSize,
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
                      },
                      onAddStandByCourt: _playersProvider.addStandByPlayers,
                      onRemoveStandByCourt: (sectionIndex) =>
                          _playersProvider.removeStandByPlayers(sectionIndex),
                    ),
                  },
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1.0, color: Colors.grey),
          Expanded(
            flex: 1,
            child: WaitingPlayersPanel(
              showDeleteOverlay: _showCourtHighlight,
              onPlayerDrop: _handlePlayerDrop,
            ),
          ),
        ],
      ),
    );
  }
}
