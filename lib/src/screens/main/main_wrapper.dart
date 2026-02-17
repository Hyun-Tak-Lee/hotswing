import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/screens/home/home_screen.dart';
import 'package:hotswing/src/screens/players/players_screen.dart';
import 'package:hotswing/src/screens/settings/settings_screen.dart';
import 'package:hotswing/src/screens/main/widgets/main_navigation_bar.dart';
import 'package:hotswing/src/screens/main/widgets/main_navigation_rail.dart';
import 'package:hotswing/src/screens/home/widgets/left_side_menu.dart';
import 'package:hotswing/src/screens/home/widgets/right_side_menu.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlayersScreen(),
    const SettingsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    if (isTablet) {
      return Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: null, // explicit null or just remove it
          automaticallyImplyLeading: false, // Ensure no default icon
          actions: [
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
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
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _screens),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      drawer: const LeftSideMenu(isMobileSize: true),
      endDrawer: const RightSideMenu(isMobileSize: true),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: MainNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
