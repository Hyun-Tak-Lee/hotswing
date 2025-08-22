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

    // 각 내부 리스트는 이제 4개의 문자열을 가집니다.
    final List<List<String>> sectionData = [
      ["1-1", "1-2", "1-3", "1-4"],
      ["2-1", "2-2", "2-3", "2-4"],
      ["3-1", "3-2", "3-3", "3-4"],
      ["4-1", "4-2", "4-3", "4-4"],
      ["5-1", "5-2", "5-3", "5-4"] // 스크롤을 확인하기 위한 추가 데이터
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
                        child: Column( // 세로로 2분할
                          children: [
                            Expanded( // 첫 번째 가로 줄 (2칸)
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Center(child: Text(item[0])),
                                  ),
                                  Expanded(
                                    child: Center(child: Text(item[1])),
                                  ),
                                ],
                              ),
                            ),
                            Expanded( // 두 번째 가로 줄 (2칸)
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Center(child: Text(item[2])),
                                  ),
                                  Expanded(
                                    child: Center(child: Text(item[3])),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
