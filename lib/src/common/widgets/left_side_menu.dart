import 'package:flutter/material.dart';

class LeftSideMenu extends StatelessWidget {
  const LeftSideMenu({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: isMobileSize ? MediaQuery.of(context).size.width * 0.75 : MediaQuery.of(context).size.width * 0.5, // Drawer 너비 설정
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: isMobileSize ? MediaQuery.of(context).size.height * 0.075 : 150, // DrawerHeader 높이 조절
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
    );
  }
}