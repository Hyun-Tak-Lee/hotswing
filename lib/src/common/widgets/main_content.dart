import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';

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

    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    final playerList = playersProvider.unassignedPlayers;
    final List<List<Player?>> sectionData = playersProvider.assignedPlayers;
    final bool shouldShowDivider = optionsProvider.divideTeam;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // 세로 스크롤
                  child: Column(
                    // 세로로 배열
                    children: sectionData.map((item) {
                      return Container(
                        margin: const EdgeInsets.all(5.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: pastelBlue,
                          borderRadius: BorderRadius.circular(
                            20.0,
                          ),
                        ),
                        height: isMobileSize
                            ? screenHeight * 0.25
                            : screenHeight * 0.2,
                        child: Column(
                          children: [
                            Expanded(
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
                                          item.asMap().containsKey(0) ? item[0]?.name ?? "" : "",
                                          style: TextStyle(fontSize: 36.0),
                                        ),
                                      ),
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
                                          item.asMap().containsKey(1) ? item[1]?.name ?? "" : "",
                                          style: TextStyle(fontSize: 36.0),
                                        ),
                                      ),
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
                                          item.asMap().containsKey(2) ? item[2]?.name ?? "" : "",
                                          style: TextStyle(fontSize: 36.0),
                                        ),
                                      ),
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
                                          item.asMap().containsKey(3) ? item[3]?.name ?? "" : "",
                                          style: TextStyle(fontSize: 36.0),
                                        ),
                                      ),
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
          const VerticalDivider(width: 1.0, color: Colors.grey),
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Center(
                child: FractionallySizedBox(
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
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
