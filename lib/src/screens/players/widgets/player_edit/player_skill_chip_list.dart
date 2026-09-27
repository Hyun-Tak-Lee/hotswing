import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_skill_chip_button.dart';

class PlayerSkillChipList extends StatelessWidget {
  const PlayerSkillChipList({
    super.key,
    required this.currentSkillLevel,
    required this.onSelected,
  });

  final String currentSkillLevel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final levels = skillLevelToRate.keys.toList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: levels.map((level) {
        return PlayerSkillChipButton(
          level: level,
          isSelected: currentSkillLevel == level,
          onSelected: onSelected,
        );
      }).toList(),
    );
  }
}

