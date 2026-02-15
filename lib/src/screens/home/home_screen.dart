import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import './widgets/left_side_menu.dart';
import './widgets/right_side_menu.dart';
import './widgets/main_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    // 하위 위젯 호환성을 위해 유지 (추후 리팩토링 가능)
    final isMobileSize = !isTablet;

    final double iconSize = isTablet ? 76.0 : 24.0;
    final double appBarHeight = isTablet ? 92.0 : kToolbarHeight;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD1DC), Color(0xFFE6E6FA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: appBarHeight,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded),
            iconSize: iconSize,
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              iconSize: iconSize,
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        drawer: LeftSideMenu(isMobileSize: isMobileSize),
        endDrawer: RightSideMenu(isMobileSize: isMobileSize),
        body: MainContent(isMobileSize: isMobileSize),
      ),
    );
  }
}
