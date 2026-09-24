import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 모바일 및 세로 모드 화면 하단에 표시되는 메인 내비게이션 바 위젯.
class MainNavigationBar extends StatelessWidget {
  /// 현재 선택된 내비게이션 탭의 인덱스.
  final int selectedIndex;

  /// 목적지 탭 선택 시 호출되는 콜백.
  final ValueChanged<int> onDestinationSelected;

  /// [MainNavigationBar] 생성자.
  const MainNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: baseColors.navBarSelected,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            );
          }
          return TextStyle(
            color: baseColors.navBarUnselected,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: baseColors.navBarSelected, size: 30);
          }
          return IconThemeData(color: baseColors.navBarUnselected, size: 26);
        }),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: baseColors.navBarBg,
        indicatorColor: baseColors.navBarIndicator,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_tennis_outlined),
            selectedIcon: Icon(Icons.sports_tennis),
            label: '게임',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: '교류전',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: '회원 목록',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
