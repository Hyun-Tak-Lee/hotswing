import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/common/constants/player_constants.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:hotswing/src/screens/solo_match/widgets/waiting_panel_header.dart';

/// 대기 패널의 탭(전체, 그룹, 개인) 항목 데이터 모델.
class WaitingTabItem {
  /// UI에 노출될 탭 라벨 (예: "전체", "그룹 A", "개인").
  final String label;

  /// 탭 유형 ('all', 'group', 'individual').
  final String type;

  /// 그룹 유형일 때 필터링에 매핑할 실제 그룹 라벨 (예: "A").
  final String? groupLabel;

  /// [WaitingTabItem] 생성자.
  WaitingTabItem({required this.label, required this.type, this.groupLabel});
}

/// 단체전 화면에서 대기 중인 플레이어 목록 및 그룹별 탭을 표시하는 패널 위젯.
class GroupWaitingPlayersPanel extends StatefulWidget {
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

  /// [GroupWaitingPlayersPanel] 생성자.
  const GroupWaitingPlayersPanel({
    super.key,
    required this.showDeleteOverlay,
    required this.onPlayerDrop,
  });

  @override
  State<GroupWaitingPlayersPanel> createState() =>
      _GroupWaitingPlayersPanelState();
}

class _GroupWaitingPlayersPanelState extends State<GroupWaitingPlayersPanel> {
  SortCriterion _sortCriterion = SortCriterion.played;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    SharedProvider().getString(PlayerConstants.waitingSortCriterionKey).then((val) {
      if (val != null && mounted) {
        setState(
          () => _sortCriterion = val == 'name'
              ? SortCriterion.name
              : SortCriterion.played,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);
    final playersProvider = context.watch<PlayersProvider>();
    final allUnassignedPlayers = playersProvider.getSortedUnassignedPlayers(
      criterion: _sortCriterion,
      ascending: _sortAscending,
    );
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // 1. 대기 참여자 중에서 존재하는 모든 그룹 라벨 수집
    final Set<String> activeGroups = {};
    for (var player in allUnassignedPlayers) {
      final info = playersProvider.getGroupInfo(player.id);
      if (info != null) {
        activeGroups.add(info.label);
      }
    }
    final sortedGroups = activeGroups.toList()..sort();

    // 2. 동적 탭 리스트 생성
    final List<WaitingTabItem> tabItems = [
      ...sortedGroups.map(
        (g) => WaitingTabItem(label: '그룹 $g', type: 'group', groupLabel: g),
      ),
      WaitingTabItem(label: '미할당', type: 'individual'),
    ];

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Center(
            child: FractionallySizedBox(
              child: isLandscape
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: DefaultTabController(
                            key: ValueKey(tabItems.length),
                            length: tabItems.length,
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
                              child: Column(
                                children: [
                                  TabBar(
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.start,
                                    labelColor: baseColors.primaryAccent,
                                    unselectedLabelColor:
                                        baseColors.textSecondary,
                                    indicatorColor: baseColors.primaryAccent,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    dividerColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    tabs: List.generate(tabItems.length, (
                                      index,
                                    ) {
                                      final tabItem = tabItems[index];
                                      final filteredCount = _filterPlayersByTab(
                                        tabItem,
                                        allUnassignedPlayers,
                                        playersProvider,
                                      ).length;
                                      return Tab(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(tabItem.label),
                                            const SizedBox(width: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: baseColors.primaryAccent
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '$filteredCount',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      baseColors.primaryAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: List.generate(tabItems.length, (
                                        index,
                                      ) {
                                        final tabItem = tabItems[index];
                                        final tabPlayers = _filterPlayersByTab(
                                          tabItem,
                                          allUnassignedPlayers,
                                          playersProvider,
                                        );

                                        if (tabPlayers.isEmpty) {
                                          return Center(
                                            child: Text(
                                              '대기 중인 회원이 없습니다.',
                                              style: TextStyle(
                                                color: baseColors.textSecondary,
                                                fontSize: isTablet
                                                    ? 16.0
                                                    : 14.0,
                                              ),
                                            ),
                                          );
                                        }

                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: tabPlayers.length,
                                          itemBuilder: (context, playerIndex) {
                                            Player player =
                                                tabPlayers[playerIndex];
                                            final String playerSectionId =
                                                'unassigned_group_${tabItem.label}_$playerIndex';

                                            return SizedBox(
                                              width: isTablet ? 200.0 : 160.0,
                                              child: PlayerDropZone(
                                                player: player,
                                                sectionId: playerSectionId,
                                                sectionKind: PlayerSectionKind
                                                    .unassigned
                                                    .value,
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
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        WaitingPanelLandscapeHeader(
                          isTablet: isTablet,
                          count: allUnassignedPlayers.length,
                          sortCriterion: _sortCriterion,
                          onSortSelected: _onSortSelected,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        WaitingPanelHeader(
                          isTablet: isTablet,
                          count: allUnassignedPlayers.length,
                          sortCriterion: _sortCriterion,
                          onSortSelected: _onSortSelected,
                        ),
                        SizedBox(height: isTablet ? 8.0 : 4.0),
                        Expanded(
                          child: DefaultTabController(
                            key: ValueKey(tabItems.length),
                            length: tabItems.length,
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
                              child: Column(
                                children: [
                                  TabBar(
                                    isScrollable: true,
                                    tabAlignment: TabAlignment.start,
                                    labelColor: baseColors.primaryAccent,
                                    unselectedLabelColor:
                                        baseColors.textSecondary,
                                    indicatorColor: baseColors.primaryAccent,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    dividerColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    tabs: List.generate(tabItems.length, (
                                      index,
                                    ) {
                                      final tabItem = tabItems[index];
                                      final filteredCount = _filterPlayersByTab(
                                        tabItem,
                                        allUnassignedPlayers,
                                        playersProvider,
                                      ).length;
                                      return Tab(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(tabItem.label),
                                            const SizedBox(width: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: baseColors.primaryAccent
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '$filteredCount',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      baseColors.primaryAccent,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      children: List.generate(tabItems.length, (
                                        index,
                                      ) {
                                        final tabItem = tabItems[index];
                                        final tabPlayers = _filterPlayersByTab(
                                          tabItem,
                                          allUnassignedPlayers,
                                          playersProvider,
                                        );

                                        if (tabPlayers.isEmpty) {
                                          return Center(
                                            child: Text(
                                              '대기 중인 회원이 없습니다.',
                                              style: TextStyle(
                                                color: baseColors.textSecondary,
                                                fontSize: isTablet
                                                    ? 16.0
                                                    : 14.0,
                                              ),
                                            ),
                                          );
                                        }

                                        return ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: tabPlayers.length,
                                          itemBuilder: (context, playerIndex) {
                                            Player player =
                                                tabPlayers[playerIndex];
                                            final String playerSectionId =
                                                'unassigned_group_${tabItem.label}_$playerIndex';

                                            return PlayerDropZone(
                                              player: player,
                                              sectionId: playerSectionId,
                                              sectionKind: PlayerSectionKind
                                                  .unassigned
                                                  .value,
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
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
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
    setState(() {
      _sortCriterion = newValue;
      _sortAscending = true;
    });
    SharedProvider().saveString(PlayerConstants.waitingSortCriterionKey, newValue.name);
  }

  List<Player> _filterPlayersByTab(
    WaitingTabItem tabItem,
    List<Player> players,
    PlayersProvider provider,
  ) {
    switch (tabItem.type) {
      case 'all':
        return players;
      case 'individual':
        return players
            .where((p) => provider.getGroupInfo(p.id) == null)
            .toList();
      case 'group':
        return players.where((p) {
          final info = provider.getGroupInfo(p.id);
          return info != null && info.label == tabItem.groupLabel;
        }).toList();
      default:
        return players;
    }
  }
}
