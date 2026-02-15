import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';

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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isMobile = screenWidth < 600;

    final textTheme = Theme.of(context).textTheme;
    final double dialogWidth = isMobile ? screenWidth * 0.9 : 500.0;
    final double dialogHeight = isMobile ? screenHeight * 0.5 : 400.0;

    final sortedNotPlayedWithNames = List<String>.from(notPlayedWithNames)
      ..sort();
    final bool hasNotPlayedWith = notPlayedWithNames.isNotEmpty;

    return AlertDialog(
      title: Text(
        '${player.name}님과 함께 플레이한 사람',
        style: textTheme.headlineSmall,
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.separated(
            itemCount: gamesPlayedWithMap.length + (hasNotPlayedWith ? 1 : 0),
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              if (hasNotPlayedWith && index == 0) {
                return ListTile(
                  dense: true,
                  title: Text(
                    '기록 없음',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    sortedNotPlayedWithNames.join(', '),
                    style: textTheme.bodyMedium,
                  ),
                );
              } else {
                final mapIndex = hasNotPlayedWith ? index - 1 : index;
                final entry = gamesPlayedWithMap.entries.elementAt(mapIndex);
                return ListTile(
                  dense: true,
                  title: Text(entry.key, style: textTheme.bodyLarge),
                  trailing: Text(
                    '${entry.value} 회',
                    style: textTheme.bodyLarge,
                  ),
                );
              }
            },
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('닫기', style: textTheme.titleMedium),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
