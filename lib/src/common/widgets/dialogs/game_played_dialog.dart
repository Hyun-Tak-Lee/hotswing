import 'package:flutter/material.dart';
import 'package:hotswing/src/providers/players_provider.dart';

class GamePlayedDialog extends StatelessWidget {
  final Player player;
  final Map<String, int> gamesPlayedWithMap;

  const GamePlayedDialog(
      {Key? key, required this.gamesPlayedWithMap, required this.player})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;

    final double titleFontSize = isMobileSize ? 20 : 32;
    final double contentFontSize = isMobileSize ? 16 : 28;
    final double buttonFontSize = isMobileSize ? 14 : 24;
    final double dialogWidth =
        isMobileSize ? screenWidth * 0.8 : screenWidth * 0.5;
    final double dialogHeight =
        isMobileSize ? screenHeight * 0.4 : screenHeight * 0.4;

    return AlertDialog(
      title: Text('${player.name}님과 함께 플레이한 사람',
          style: TextStyle(fontSize: titleFontSize)),
      content: gamesPlayedWithMap.isEmpty
          ? Text('플레이 기록이 없습니다',
              style: TextStyle(fontSize: contentFontSize))
          : SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: gamesPlayedWithMap.length,
                  itemBuilder: (BuildContext context, int index) {
                    final entry = gamesPlayedWithMap.entries.elementAt(index);
                    return ListTile(
                      dense: true, // dense 속성 추가
                      title: Text('${entry.key}: ${entry.value} 회',
                          style: TextStyle(fontSize: contentFontSize)),
                    );
                  },
                ),
              ),
            ),
      actions: <Widget>[
        TextButton(
          child: Text('닫기', style: TextStyle(fontSize: buttonFontSize)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
