import 'package:flutter/material.dart';
import 'package:hotswing/src/providers/players_provider.dart';

class GamePlayedDialog extends StatelessWidget {
  final Player player;
  final Map<String, int> gamesPlayedWithMap;
  final List<String> notPlayedWithNames;

  const GamePlayedDialog({
    Key? key,
    required this.gamesPlayedWithMap,
    required this.player,
    required this.notPlayedWithNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;

    final double titleFontSize = isMobileSize ? 20 : 32;
    final double contentFontSize = isMobileSize ? 16 : 28;
    final double buttonFontSize = isMobileSize ? 14 : 24;
    final double dialogWidth = isMobileSize
        ? screenWidth * 0.8
        : screenWidth * 0.5;
    final double dialogHeight = isMobileSize
        ? screenHeight * 0.4
        : screenHeight * 0.4;

    bool hasNotPlayedWith = notPlayedWithNames.isNotEmpty;

    return AlertDialog(
      title: Text(
        '${player.name}님과 함께 플레이한 사람',
        style: TextStyle(fontSize: titleFontSize),
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: gamesPlayedWithMap.length + (hasNotPlayedWith ? 1 : 0),
            itemBuilder: (BuildContext context, int index) {
              if (hasNotPlayedWith && index == 0) {
                // Display notPlayedWithNames first if it exists
                return ListTile(
                  dense: true,
                  title: Text(
                    '기록 없음: \n${notPlayedWithNames.join(', ')}',
                    style: TextStyle(fontSize: contentFontSize),
                  ),
                );
              } else {
                final mapIndex = hasNotPlayedWith ? index - 1 : index;
                final entry = gamesPlayedWithMap.entries.elementAt(mapIndex);
                return ListTile(
                  dense: true,
                  title: Text(
                    '${entry.key}: ${entry.value} 회',
                    style: TextStyle(fontSize: contentFontSize),
                  ),
                );
              }
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
