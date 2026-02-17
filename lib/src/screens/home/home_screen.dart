import 'package:flutter/material.dart';

import './widgets/main_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // HomeScreen은 이제 단순히 배경과 컨텐츠만 표시합니다.
    // 헤더와 드로어는 MainWrapper에서 처리합니다.
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD1DC), Color(0xFFE6E6FA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: const MainContent(),
    );
  }
}
