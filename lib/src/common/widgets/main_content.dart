import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart'; // Added import

class MainContent extends StatelessWidget {
  const MainContent({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;

    final Color pastelBlue = Colors.lightBlue.shade50;
    final Color pastelLightBlue = Color(0xFFFAFFFF);

    // 각 내부 리스트는 이제 4개의 문자열을 가집니다.
    final List<List<String>> sectionData = [
      ["1-1", "1-2", "1-3", "1-4"],
      ["2-1", "2-2", "2-3", "2-4"],
      ["3-1", "3-2", "3-3", "3-4"],
      ["4-1", "4-2", "4-3", "4-4"],
      ["5-1", "5-2", "5-3", "5-4"],
    ];

    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    final playerList = playersProvider.unassignedPlayers;
    final bool shouldShowDivider = optionsProvider.divideTeam;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.90,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // 세로 스크롤
                  child: Column(
                    // 세로로 배열
                    children: sectionData.map((item) {
                      return Container(
                        margin: const EdgeInsets.all(5.0),
                        // 구역 간 간격
                        padding: const EdgeInsets.all(10.0),
                        // Added padding here
                        decoration: BoxDecoration(
                          // 둥근 모서리를 위한 BoxDecoration 추가
                          color: pastelBlue,
                          borderRadius: BorderRadius.circular(
                            20.0,
                          ), // 둥근 모서리 반경 설정
                        ),
                        height: isMobileSize
                            ? screenHeight * 0.25
                            : screenHeight * 0.2,
                        // 높이 지정
                        child: Column(
                          // 세로로 2분할
                          children: [
                            Expanded(
                              // 첫 번째 가로 줄 (2칸)
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(4.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: pastelLightBlue,
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item[0],
                                          style: TextStyle(fontSize: 36.0),
                                        ),
                                      ), // Updated text style
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(4.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: pastelLightBlue,
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item[1],
                                          style: TextStyle(fontSize: 36.0),
                                        ),
                                      ), // Updated text style
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: shouldShowDivider,
                              child: Divider(color: Colors.grey, thickness: 1),
                            ),
                            Expanded(
                              // 두 번째 가로 줄 (2칸)
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(4.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: pastelLightBlue,
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item[2],
                                          style: TextStyle(fontSize: 36.0),
                                        ),
                                      ), // Updated text style
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(4.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: pastelLightBlue,
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          item[3],
                                          style: TextStyle(fontSize: 36.0),
                                        ),
                                      ), // Updated text style
                                    ),
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
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.90,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: playerList.map((player) {
                      return Container(
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: pastelLightBlue,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        height: isMobileSize
                            ? screenHeight * 0.08
                            : screenHeight * 0.05,
                        // Adjusted height
                        child: Center(
                          child: Text(
                            player.name,
                            style: TextStyle(fontSize: 24.0),
                          ), // Assuming Player has a 'name' property
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
