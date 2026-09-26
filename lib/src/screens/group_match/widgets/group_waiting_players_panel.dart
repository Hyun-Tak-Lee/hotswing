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
import 'package:hotswing/src/screens/group_match/widgets/edit_group_name_dialog.dart';

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
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);
    final playersProvider = context.watch<PlayersProvider>();
    final allUnassignedPlayers = playersProvider.getSortedUnassignedPlayers(
      criterion: sortCriterion,
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
        (g) => WaitingTabItem(label: g, type: 'group', groupLabel: g),
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
                                  _GroupWaitingTabBar(
                                    tabItems: tabItems,
                                    allUnassignedPlayers: allUnassignedPlayers,
                                    isTablet: isTablet,
                                    onEditGroupName: (tabItem) =>
                                        _showEditGroupNameDialog(context, tabItem),
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
                          sortCriterion: sortCriterion,
                          onSortSelected: _onSortSelected,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        WaitingPanelHeader(
                          isTablet: isTablet,
                          count: allUnassignedPlayers.length,
                          sortCriterion: sortCriterion,
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
                                  _GroupWaitingTabBar(
                                    tabItems: tabItems,
                                    allUnassignedPlayers: allUnassignedPlayers,
                                    isTablet: isTablet,
                                    onEditGroupName: (tabItem) =>
                                        _showEditGroupNameDialog(context, tabItem),
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
    if (_sortCriterion != newValue) {
      setState(() {
        _sortCriterion = newValue;
      });
    }
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

  void _showEditGroupNameDialog(BuildContext context, WaitingTabItem tabItem) {
    final playersProvider = context.read<PlayersProvider>();
    final groupLabel = tabItem.groupLabel ?? tabItem.label;

    final matchingPlayers = playersProvider.players.values.where((p) {
      final info = playersProvider.getGroupInfo(p.id);
      return info != null && info.label == groupLabel;
    }).toList();

    if (matchingPlayers.isEmpty) return;

    final firstPlayer = matchingPlayers.first;
    final groupInfo = playersProvider.getGroupInfo(firstPlayer.id);
    final groupMembers = matchingPlayers.map((p) => p.id).toList();

    EditGroupNameDialog.show(
      context: context,
      currentLabel: tabItem.label,
      defaultLabel: tabItem.groupLabel ?? tabItem.label,
      groupMembers: groupMembers,
      groupColor: groupInfo?.color ?? context.baseColors.primaryAccent,
    );
  }
}

/// 교류전 대기 패널의 탭 목록을 표시하고, 선택된 그룹 탭에만 수정 아이콘을 제공하는 위젯.
class _GroupWaitingTabBar extends StatelessWidget {
  final List<WaitingTabItem> tabItems;
  final List<Player> allUnassignedPlayers;
  final bool isTablet;
  final void Function(WaitingTabItem tabItem) onEditGroupName;

  const _GroupWaitingTabBar({
    required this.tabItems,
    required this.allUnassignedPlayers,
    required this.isTablet,
    required this.onEditGroupName,
  });

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    final baseColors = context.baseColors;
    final playersProvider = context.watch<PlayersProvider>();

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final selectedIndex = tabController.index;
        return TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: baseColors.primaryAccent,
          unselectedLabelColor: baseColors.textSecondary,
          indicatorColor: baseColors.primaryAccent,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          tabs: List.generate(tabItems.length, (index) {
            final tabItem = tabItems[index];
            final filteredCount = _filterPlayers(
              tabItem,
              allUnassignedPlayers,
              playersProvider,
            ).length;
            final isSelected = index == selectedIndex;
            final isEditableGroup = tabItem.type == 'group';

            return Tab(
              child: GestureDetector(
                onLongPress: isEditableGroup
                    ? () => onEditGroupName(tabItem)
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${tabItem.label} ($filteredCount)',
                      style: TextStyle(
                        fontSize: isTablet ? 15.0 : 13.0,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    if (isSelected && isEditableGroup) ...[
                      const SizedBox(width: 3.0),
                      GestureDetector(
                        onTap: () => onEditGroupName(tabItem),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            Icons.edit_outlined,
                            size: isTablet ? 14.0 : 12.0,
                            color: baseColors.primaryAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  List<Player> _filterPlayers(
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
