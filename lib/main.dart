import 'package:flutter/material.dart';
import 'package:hotswing/src/common/widgets/left_side_menu.dart';
import 'package:hotswing/src/common/widgets/right_side_menu.dart';
import 'package:hotswing/src/common/widgets/main_content.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayersProvider()),
        ChangeNotifierProvider(create: (_) => OptionsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB0E0E6)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;
    final double iconSize = isMobileSize ? 24.0 : 76.0;
    final double appBarHeight = isMobileSize ? kToolbarHeight : 88.0; // 조건부 AppBar 높이 (태블릿에서 72.0)

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFD1DC), const Color(0xFFE6E6FA)],
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
          toolbarHeight: appBarHeight, // 수정된 AppBar 높이 적용
          leading: IconButton(
            icon: const Icon(Icons.menu),
            iconSize: iconSize,
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.menu),
              iconSize: iconSize,
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
          ],
        ),
        drawer: LeftSideMenu(isMobileSize: isMobileSize),
        endDrawer: RightSideMenu(isMobileSize: isMobileSize),
        body: MainContent(
          isMobileSize: isMobileSize,
        ),
      ),
    );
  }
}
