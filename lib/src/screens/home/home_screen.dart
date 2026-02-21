import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/assigned_court.dart';
import 'package:hotswing/src/common/widgets/courts/standby_court.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
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
  bool _showCourtHighlight = false;

  CourtViewSection selectedView = CourtViewSection.assignedView;

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

    // [1] 소스 처리 (Extraction): 드래그가 시작된 위치에서 플레이어를 제거하고 정보를 가져옵니다.
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

    // [2] 타겟 처리 (Move Only): 타겟이 대기 목록이나 삭제 영역인 경우, 단순 이동 처리 후 종료합니다 (조기 리턴).
    if (targetSectionKind == PlayerSectionKind.unassigned.value ||
        targetSectionKind == PlayerSectionKind.drop.value) {
      playersProvider.addUnassignedPlayer(draggedPlayer);
      return;
    }

    // [3] 타겟 처리 (Exchange): 타겟이 코트 슬롯인 경우, 기존 플레이어를 추출하고 드래그된 플레이어로 교체합니다.
    Player? existingTargetPlayer;
    if (targetSectionKind == PlayerSectionKind.assigned.value) {
      existingTargetPlayer = playersProvider.removeAssignedPlayer(
        targetSectionIndex,
        targetSubIndex,
      );
      playersProvider.addAssignedPlayer(
        draggedPlayer,
        targetSectionIndex,
        targetSubIndex,
      );
    } else if (targetSectionKind == PlayerSectionKind.standby.value) {
      existingTargetPlayer = playersProvider.removeStandbyPlayer(
        targetSectionIndex,
        targetSubIndex,
      );
      playersProvider.addStandbyPlayer(
        draggedPlayer,
        targetSectionIndex,
        targetSubIndex,
      );
    }

    // [4] 소스 복구 (Swap): 타겟에 원래 있던 플레이어를 드래그가 시작되었던 소스 위치로 이동시켜 배치를 완료합니다.
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

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final isMobileSize = !isTablet;

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
                      onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
                      onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
                      onPlayerDrop: _handlePlayerDrop,
                    ),

                    CourtViewSection.standbyView => StandbyCourtSectionsView(
                      onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
                      onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
                      onPlayerDrop: _handlePlayerDrop,
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
