import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/screens/solo_match/widgets/waiting_panel_header.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/common/constants/player_constants.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';

/// 대기 중인 플레이어 목록 및 정렬 헤더를 표시하는 패널 위젯.
class WaitingPlayersPanel extends StatefulWidget {
  /// 드래그 중인 플레이어를 대기 패널로 삭제/해제할 때 표시할 오버레이 활성화 여부.
  final bool showDeleteOverlay;

  /// 플레이어 드롭 시 호출되는 콜백.
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

  /// [WaitingPlayersPanel] 생성자.
  const WaitingPlayersPanel({
    super.key,
    required this.showDeleteOverlay,
    required this.onPlayerDrop,
  });

  @override
  State<WaitingPlayersPanel> createState() => _WaitingPlayersPanelState();
}

class _WaitingPlayersPanelState extends State<WaitingPlayersPanel> {
  SortCriterion? _sortCriterion;
  final bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    SharedProvider().getString(PlayerConstants.waitingSortCriterionKey).then((val) {
      if (mounted) {
        setState(() {
          _sortCriterion = val == 'name'
              ? SortCriterion.name
              : SortCriterion.played;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sortCriterion == null) {
      return const SizedBox.shrink();
    }
    final sortCriterion = _sortCriterion!;
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);
    final playersProvider = context.watch<PlayersProvider>();
    final playerList = playersProvider.getSortedUnassignedPlayers(
      criterion: sortCriterion,
      ascending: _sortAscending,
    );
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // 가로 모드일 때 화면 전체 너비에 비례하는 카드 가로폭 지정 (SizedBox용)
    final double cardWidth = isTablet
        ? (screenWidth * 0.16)
        : (screenWidth * 0.28);

    // 가로 모드일 때 화면 전체 세로 높이에 비례하는 패널 최대 높이 지정
    final double maxPanelHeight = isTablet
        ? (screenHeight * 0.25)
        : (screenHeight * 0.22);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          constraints: isLandscape
              ? BoxConstraints(maxHeight: maxPanelHeight)
              : null,
          child: Center(
            child: FractionallySizedBox(
              child: isLandscape
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  courtColors.waitingPanelBgStart,
                                  courtColors.waitingPanelBgEnd,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: playerList.length,
                              itemBuilder: (context, playerIndex) {
                                Player player = playerList[playerIndex];
                                final String playerSectionId =
                                    'unassigned_$playerIndex';
                                return SizedBox(
                                  width: cardWidth,
                                  child: PlayerDropZone(
                                    player: player,
                                    sectionId: playerSectionId,
                                    sectionKind:
                                        PlayerSectionKind.unassigned.value,
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
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        WaitingPanelLandscapeHeader(
                          isTablet: isTablet,
                          count: playerList.length,
                          sortCriterion: sortCriterion,
                          onSortSelected: _onSortSelected,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        WaitingPanelHeader(
                          isTablet: isTablet,
                          count: playerList.length,
                          sortCriterion: sortCriterion,
                          onSortSelected: _onSortSelected,
                        ),
                        SizedBox(height: isTablet ? 8.0 : 4.0),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  courtColors.waitingPanelBgStart,
                                  courtColors.waitingPanelBgEnd,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(8),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: playerList.length,
                              itemBuilder: (context, playerIndex) {
                                Player player = playerList[playerIndex];
                                final String playerSectionId =
                                    'unassigned_$playerIndex';
                                return PlayerDropZone(
                                  player: player,
                                  sectionId: playerSectionId,
                                  sectionKind:
                                      PlayerSectionKind.unassigned.value,
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
                              },
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

  void _onSortSelected(SortCriterion newValue) {
    if (_sortCriterion != newValue) {
      setState(() {
        _sortCriterion = newValue;
      });
    }
    SharedProvider().saveString(PlayerConstants.waitingSortCriterionKey, newValue.name);
  }
}
