import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue.shade200),
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75, // Drawer 너비 설정
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10, // DrawerHeader 높이 조절
              child: const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                ),
                child: Text('왼쪽 메뉴'),
              ),
            ),
            ListTile(
              title: const Text('항목 1'),
              onTap: () {
                // 항목 1 클릭 시 동작
                Navigator.pop(context); // Drawer 닫기
              },
            ),
            ListTile(
              title: const Text('항목 2'),
              onTap: () {
                // 항목 2 클릭 시 동작
                Navigator.pop(context); // Drawer 닫기
              },
            ),
          ],
        ),
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.75, // Drawer 너비 설정
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10, // DrawerHeader 높이 조절
              child: const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightBlue,
                ),
                child: Text('오른쪽 메뉴'),
              ),
            ),
            ListTile(
              title: const Text('옵션 A'),
              onTap: () {
                // 옵션 A 클릭 시 동작
                Navigator.pop(context); // Drawer 닫기
              },
            ),
            ListTile(
              title: const Text('옵션 B'),
              onTap: () {
                // 옵션 B 클릭 시 동작
                Navigator.pop(context); // Drawer 닫기
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Content'),
          ],
        ),
      ),
    );
  }
}
