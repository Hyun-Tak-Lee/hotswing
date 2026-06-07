import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/screens/solo_match/solo_match_screen.dart';
import 'package:hotswing/src/screens/group_match/group_match_screen.dart';
import 'package:hotswing/src/screens/players/players_screen.dart';
import 'package:hotswing/src/common/widgets/dialogs/manager_auth_overlay.dart';
import 'package:hotswing/src/screens/settings/settings_screen.dart';
import 'package:hotswing/src/screens/main/widgets/navigation/main_navigation_bar.dart';
import 'package:hotswing/src/screens/main/widgets/navigation/main_navigation_rail.dart';
import 'package:hotswing/src/screens/main/widgets/menu/left_side_menu.dart';
import 'package:hotswing/src/screens/main/widgets/menu/right_side_menu.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  Key _playersScreenKey = UniqueKey();

  Widget _buildContent() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        const SoloMatchScreen(),
        const GroupMatchScreen(),
        PlayersScreen(key: _playersScreenKey),
        const SettingsScreen(),
      ],
    );
  }

  void _onDestinationSelected(int index) async {
    final playersProvider = Provider.of<PlayersProvider>(
      context,
      listen: false,
    );
    // 개인전(0) <-> 교류전(1) 상호 전환 시 코트에 선수가 1명이라도 배정되어 있다면 전환을 차단합니다.
    if ((_selectedIndex == 0 && index == 1) ||
        (_selectedIndex == 1 && index == 0)) {
      if (playersProvider.hasActivePlayers) {
        _showMatchTypeConflictDialog(context);
        return;
      }
    }

    if (index == 2) {
      // 플레이어 화면(index=2) 진입 시 인증 오버레이 띄우기
      if (!mounted) return;
      final bool? isAuthenticated = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const ManagerAuthOverlay(),
      );

      // 인증 취소 또는 실패 시 화면 전환 중지
      if (isAuthenticated != true) {
        return;
      }
      _playersScreenKey = UniqueKey();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showMatchTypeConflictDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                '매칭 방식 전환 불가',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            '코트에 플레이어가 배치되었을 경우 모드 변경이 불가능합니다',
            style: TextStyle(fontSize: 15, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                '확인',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final baseColors = context.baseColors;

    // 다크모드 여부에 따른 그라데이션 배경색 정의
    final gradientColors = [baseColors.gradientStart, baseColors.gradientEnd];

    // 다크모드 여부에 따른 메인 컨텐츠 영역의 배경색
    final contentBgColor = baseColors.contentBg;

    // 다크모드 여부에 따른 메뉴 아이콘 색상
    final iconColor = baseColors.menuIcon;

    if (isTablet) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent, // 그라디언트가 보이도록 투명 배경
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 72.0,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              iconSize: 30.0,
              color: iconColor,
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            automaticallyImplyLeading: false,
            actions: [
              SizedBox(
                width: 72.0,
                child: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  iconSize: 30.0,
                  color: iconColor,
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
              ),
            ],
          ),
          drawer: const LeftSideMenu(isMobileSize: false),
          endDrawer: const RightSideMenu(isMobileSize: false),
          body: Row(
            children: [
              MainNavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _onDestinationSelected,
              ),
              const VerticalDivider(
                thickness: 1,
                width: 1,
                color: Colors.transparent,
              ), // 투명 구분선
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 0, right: 0, bottom: 0),
                  decoration: BoxDecoration(
                    color: contentBgColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias, // 둥근 모서리에 맞춰 내용 자르기
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent, // 그라디언트가 보이도록 투명 배경
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            iconSize: 28.0, // 터치 영역 확보를 위해 약간 크게 설정
            color: iconColor,
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              iconSize: 28.0,
              color: iconColor,
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        drawer: const LeftSideMenu(isMobileSize: true),
        endDrawer: const RightSideMenu(isMobileSize: true),
        body: Container(
          decoration: BoxDecoration(
            color: contentBgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildContent(),
        ),
        bottomNavigationBar: MainNavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
        ),
      ),
    );
  }
}
