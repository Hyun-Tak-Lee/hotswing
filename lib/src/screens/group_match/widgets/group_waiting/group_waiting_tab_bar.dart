import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/screens/group_match/widgets/group_waiting/waiting_tab_item.dart';
import 'package:provider/provider.dart';

/// 교류전 대기 패널의 탭 목록을 표시하고, 선택된 그룹 탭에만 수정 아이콘을 제공하는 위젯.
class GroupWaitingTabBar extends StatelessWidget {
  final List<WaitingTabItem> tabItems;
  final List<Player> allUnassignedPlayers;
  final bool isTablet;
  final void Function(WaitingTabItem tabItem) onEditGroupName;

  const GroupWaitingTabBar({
    super.key,
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
