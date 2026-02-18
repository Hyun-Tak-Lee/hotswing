import 'package:flutter/material.dart';

class MainNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const MainNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Colors.transparent, // 전체 그라데이션이 투과되어 보임
        indicatorColor: const Color(0xFFD1C4E9),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        selectedLabelTextStyle: const TextStyle(
          color: Color(0xFF3E2723),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: Color(0xFF4E342E),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: const IconThemeData(
          color: Color(0xFF3E2723),
          size: 30,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xFF4E342E),
          size: 26,
        ),
        groupAlignment: 0.0,
        minWidth: 72.0,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.sports_tennis_outlined),
            selectedIcon: Icon(Icons.sports_tennis),
            label: Text(
              '게임',
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
            ),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: Text(
              '회원 목록',
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
            ),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: Text(
              '설정',
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
