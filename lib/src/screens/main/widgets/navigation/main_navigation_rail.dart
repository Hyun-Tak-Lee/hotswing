import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 태블릿 및 가로 모드 화면 좌측에 표시되는 메인 내비게이션 레일 위젯.
class MainNavigationRail extends StatelessWidget {
  /// 현재 선택된 내비게이션 탭의 인덱스.
  final int selectedIndex;

  /// 목적지 탭 선택 시 호출되는 콜백.
  final ValueChanged<int> onDestinationSelected;

  /// [MainNavigationRail] 생성자.
  const MainNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;

    return SizedBox(
      width: 72,
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Colors.transparent, // 전체 그라데이션이 투과되어 보임
        indicatorColor: baseColors.navBarIndicator,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        selectedLabelTextStyle: TextStyle(
          color: baseColors.navBarSelected,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: baseColors.navBarUnselected,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        selectedIconTheme: IconThemeData(
          color: baseColors.navBarSelected,
          size: 30,
        ),
        unselectedIconTheme: IconThemeData(
          color: baseColors.navBarUnselected,
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
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: Text(
              '교류전',
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
