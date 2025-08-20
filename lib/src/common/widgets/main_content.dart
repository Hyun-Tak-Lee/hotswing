import 'package:flutter/material.dart';

class MainContent extends StatelessWidget {
  const MainContent({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;

    final Color pastelBlue = Colors.lightBlue.shade100;

    // 각 내부 리스트는 단일 문자열만 가집니다.
    final List<List<String>> sectionData = [
      ["첫 번째 구역 내용"],
      ["두 번째 구역 내용"],
      ["세 번째 구역 내용"],
      ["네 번째 구역 내용"],
      ["다섯 번째 구역 (스크롤 확인용)"] // 스크롤을 확인하기 위한 추가 데이터
    ];

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Center( // 95% 너비의 컨텐츠를 중앙 정렬
              child: FractionallySizedBox(
                widthFactor: 0.95,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // 세로 스크롤
                  child: Column( // 세로로 배열
                    children: sectionData.map((item) {
                      return Container(
                        margin: const EdgeInsets.all(5.0), // 구역 간 간격
                        decoration: BoxDecoration( // 둥근 모서리를 위한 BoxDecoration 추가
                          color: pastelBlue,
                          borderRadius: BorderRadius.circular(20.0), // 둥근 모서리 반경 설정
                        ),
                        height: isMobileSize ? screenHeight * 0.25 : screenHeight * 0.2, // 높이 지정
                        child: Center(child: Text(item[0])), // 내부 리스트의 첫 번째 (유일한) 문자열 표시
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: const Center(child: Text('Content Area 2 (1/3)')),
          ),
        ],
      ),
    );
  }
}
