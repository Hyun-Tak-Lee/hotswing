import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/screens/solo_match/widgets/waiting_players_panel.dart'; // SortCriterion 참조용

class WaitingTabItem {
  final String label;      // UI에 노출될 탭 라벨 (예: "전체", "그룹 A", "개인")
  final String type;       // 'all', 'group', 'individual'
  final String? groupLabel; // group 타입일 때 필터링에 매핑할 실제 그룹 라벨 (예: "A")

  WaitingTabItem({
    required this.label,
    required this.type,
    this.groupLabel,
  });
}

class GroupWaitingPlayersPanel extends StatefulWidget {
  final bool showDeleteOverlay;
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

  const GroupWaitingPlayersPanel({
    super.key,
    required this.showDeleteOverlay,
    required this.onPlayerDrop,
  });

  @override
  State<GroupWaitingPlayersPanel> createState() => _GroupWaitingPlayersPanelState();
}

class _GroupWaitingPlayersPanelState extends State<GroupWaitingPlayersPanel> {
  SortCriterion _sortCriterion = SortCriterion.played;
  bool _sortAscending = true;

  // 각 탭에 따른 플레이어 필터링 처리
  List<Player> _filterPlayersByTab(WaitingTabItem tabItem, List<Player> players, PlayersProvider provider) {
    switch (tabItem.type) {
      case 'all':
        return players;
      case 'individual':
        return players.where((p) => provider.getGroupInfo(p.id) == null).toList();
      case 'group':
        return players.where((p) {
          final info = provider.getGroupInfo(p.id);
          return info != null && info.label == tabItem.groupLabel;
        }).toList();
      default:
        return players;
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    final allUnassignedPlayers = List<Player>.from(playersProvider.unassignedPlayers);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // 전체 리스트 정렬
    allUnassignedPlayers.sort((a, b) {
      int compareResult;
      switch (_sortCriterion) {
        case SortCriterion.played:
          int activateCompare = (b.activate ? 1 : 0).compareTo(
            a.activate ? 1 : 0,
          );
          if (activateCompare != 0) {
            return activateCompare;
          }
          int playedCompare = (a.played + a.lated).compareTo(
            b.played + b.lated,
          );
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
      ...sortedGroups.map((g) => WaitingTabItem(label: '그룹 $g', type: 'group', groupLabel: g)),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                    unselectedLabelColor: baseColors.textSecondary,
                                    indicatorColor: baseColors.primaryAccent,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    dividerColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    tabs: List.generate(tabItems.length, (index) {
                                      final tabItem = tabItems[index];
                                      final filteredCount = _filterPlayersByTab(tabItem, allUnassignedPlayers, playersProvider).length;
                                      return Tab(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(tabItem.label),
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: baseColors.primaryAccent.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '$filteredCount',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: baseColors.primaryAccent,
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
                                      children: List.generate(tabItems.length, (index) {
                                        final tabItem = tabItems[index];
                                        final tabPlayers = _filterPlayersByTab(tabItem, allUnassignedPlayers, playersProvider);
                                        
                                        if (tabPlayers.isEmpty) {
                                          return Center(
                                            child: Text(
                                              '대기 중인 회원이 없습니다.',
                                              style: TextStyle(
                                                color: baseColors.textSecondary,
                                                fontSize: isTablet ? 16.0 : 14.0,
                                              ),
                                            ),
                                          );
                                        }

                                        return SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: tabPlayers.asMap().entries.map<Widget>((entry) {
                                              int playerIndex = entry.key;
                                              Player player = entry.value;
                                              final String playerSectionId = 'unassigned_group_${tabItem.label}_$playerIndex';
                                              
                                              return SizedBox(
                                                width: isTablet ? 200.0 : 160.0,
                                                child: PlayerDropZone(
                                                  player: player,
                                                  sectionId: playerSectionId,
                                                  sectionKind: PlayerSectionKind.unassigned.value,
                                                  sectionIndex: -1,
                                                  subIndex: playerIndex,
                                                  onPlayerDropped: (
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
                                            }).toList(),
                                          ),
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
                        _buildLandscapeHeader(
                          context,
                          isTablet,
                          allUnassignedPlayers.length,
                          baseColors,
                          courtColors,
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildHeader(context, isTablet, allUnassignedPlayers.length, baseColors, courtColors),
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
                                    unselectedLabelColor: baseColors.textSecondary,
                                    indicatorColor: baseColors.primaryAccent,
                                    indicatorSize: TabBarIndicatorSize.label,
                                    dividerColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    tabs: List.generate(tabItems.length, (index) {
                                      final tabItem = tabItems[index];
                                      final filteredCount = _filterPlayersByTab(tabItem, allUnassignedPlayers, playersProvider).length;
                                      return Tab(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(tabItem.label),
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: baseColors.primaryAccent.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '$filteredCount',
                                                style: TextStyle(
                                                  fontSize: 10.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: baseColors.primaryAccent,
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
                                      children: List.generate(tabItems.length, (index) {
                                        final tabItem = tabItems[index];
                                        final tabPlayers = _filterPlayersByTab(tabItem, allUnassignedPlayers, playersProvider);
                                        
                                        if (tabPlayers.isEmpty) {
                                          return Center(
                                            child: Text(
                                              '대기 중인 회원이 없습니다.',
                                              style: TextStyle(
                                                color: baseColors.textSecondary,
                                                fontSize: isTablet ? 16.0 : 14.0,
                                              ),
                                            ),
                                          );
                                        }

                                        return SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            children: tabPlayers.asMap().entries.map<Widget>((entry) {
                                              int playerIndex = entry.key;
                                              Player player = entry.value;
                                              final String playerSectionId = 'unassigned_group_${tabItem.label}_$playerIndex';
                                              
                                              return PlayerDropZone(
                                                player: player,
                                                sectionId: playerSectionId,
                                                sectionKind: PlayerSectionKind.unassigned.value,
                                                sectionIndex: -1,
                                                subIndex: playerIndex,
                                                onPlayerDropped: (
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
                                            }).toList(),
                                          ),
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
              builder: (
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

  Widget _buildHeader(
    BuildContext context,
    bool isTablet,
    int count,
    BaseColors baseColors,
    CourtColors courtColors,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: courtColors.waitingPanelHeaderBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (isTablet) ...[
                  TextSpan(
                    text: "대기",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: courtColors.waitingPanelHeaderTitle,
                    ),
                  ),
                  const TextSpan(text: " "),
                ],
                TextSpan(
                  text: '$count',
                  style: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: baseColors.primaryAccent,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<SortCriterion>(
            tooltip: '정렬 기준',
            initialValue: _sortCriterion,
            color: courtColors.waitingPanelHeaderBg,
            elevation: 6,
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (SortCriterion newValue) {
              setState(() {
                _sortCriterion = newValue;
                _sortAscending = true;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<SortCriterion>(
                  value: SortCriterion.played,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort_rounded,
                        color: baseColors.primaryAccent,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '경기 적은 순',
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          color: baseColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<SortCriterion>(
                  value: SortCriterion.name,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort_by_alpha_rounded,
                        color: baseColors.primaryAccent,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '이름 가나다 순',
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          color: baseColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            child: isTablet
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: courtColors.waitingPanelSortBtnBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: courtColors.waitingPanelSortBtnBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _sortCriterion == SortCriterion.played
                              ? '경기 적은 순'
                              : '이름 가나다 순',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: baseColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.0,
                          color: baseColors.textSecondary,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(Icons.sort, size: 24.0, color: baseColors.textSecondary),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeHeader(
    BuildContext context,
    bool isTablet,
    int count,
    BaseColors baseColors,
    CourtColors courtColors,
  ) {
    return Container(
      width: isTablet ? 110.0 : 80.0,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: courtColors.waitingPanelHeaderBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "대기\n",
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 13.0,
                    fontWeight: FontWeight.bold,
                    color: courtColors.waitingPanelHeaderTitle,
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: '$count',
                  style: TextStyle(
                    fontSize: isTablet ? 22.0 : 18.0,
                    fontWeight: FontWeight.w900,
                    color: baseColors.primaryAccent,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          PopupMenuButton<SortCriterion>(
            tooltip: '정렬 기준',
            initialValue: _sortCriterion,
            color: courtColors.waitingPanelHeaderBg,
            elevation: 6,
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (SortCriterion newValue) {
              setState(() {
                _sortCriterion = newValue;
                _sortAscending = true;
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<SortCriterion>(
                  value: SortCriterion.played,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort_rounded,
                        color: baseColors.primaryAccent,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '경기 적은 순',
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          color: baseColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<SortCriterion>(
                  value: SortCriterion.name,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.sort_by_alpha_rounded,
                        color: baseColors.primaryAccent,
                        size: isTablet ? 24 : 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '이름 가나다 순',
                        style: TextStyle(
                          fontSize: isTablet ? 16.0 : 14.0,
                          color: baseColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: courtColors.waitingPanelSortBtnBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: courtColors.waitingPanelSortBtnBorder.withAlpha(100)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: isTablet ? 20.0 : 16.0,
                    color: baseColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _sortCriterion == SortCriterion.played ? '경기순' : '이름순',
                    style: TextStyle(
                      fontSize: isTablet ? 12.0 : 10.0,
                      color: baseColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
