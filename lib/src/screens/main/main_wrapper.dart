import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/screens/home/home_screen.dart';
import 'package:hotswing/src/screens/players/players_screen.dart';
import 'package:hotswing/src/common/widgets/dialogs/manager_auth_overlay.dart';
import 'package:hotswing/src/screens/settings/settings_screen.dart';
import 'package:hotswing/src/screens/main/widgets/navigation/main_navigation_bar.dart';
import 'package:hotswing/src/screens/main/widgets/navigation/main_navigation_rail.dart';
import 'package:hotswing/src/screens/main/widgets/menu/left_side_menu.dart';
import 'package:hotswing/src/screens/main/widgets/menu/right_side_menu.dart';

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
        const HomeScreen(),
        PlayersScreen(key: _playersScreenKey),
        const SettingsScreen(),
      ],
    );
  }

  void _onDestinationSelected(int index) async {
    if (index == 1) {
      // 플레이어 화면(index=1) 진입 시 인증 오버레이 띄우기
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

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    if (isTablet) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF3E5F5), // 라벤더 미스트 (연보라)
              Color(0xFFE1F5FE), // 연하늘
            ],
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
              color: const Color(0xFF5D4037),
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
                  color: const Color(0xFF5D4037),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5), // 눈의 피로를 줄이기 위한 부드러운 오프화이트
                    borderRadius: BorderRadius.only(
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E5F5), // 라벤더 미스트 (연보라)
            Color(0xFFE1F5FE), // 연하늘
          ],
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
            color: const Color(0xFF5D4037), // 대비를 위한 따뜻한 다크 브라운
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              iconSize: 28.0,
              color: const Color(0xFF5D4037),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        drawer: const LeftSideMenu(isMobileSize: true),
        endDrawer: const RightSideMenu(isMobileSize: true),
        body: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5), // 눈의 피로를 줄이기 위한 부드러운 오프화이트
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
