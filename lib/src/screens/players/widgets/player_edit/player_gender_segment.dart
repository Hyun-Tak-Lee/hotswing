import 'package:flutter/material.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_gender_button.dart';

class PlayerGenderSegment extends StatelessWidget {
  const PlayerGenderSegment({
    super.key,
    required this.currentGender,
    required this.onSelected,
  });

  final String currentGender;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PlayerGenderButton(
          label: "남",
          isSelected: currentGender == "남",
          onSelected: onSelected,
        ),
        const SizedBox(width: 10),
        PlayerGenderButton(
          label: "여",
          isSelected: currentGender == "여",
          onSelected: onSelected,
        ),
      ],
    );
  }
}

