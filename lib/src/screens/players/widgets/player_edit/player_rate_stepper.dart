import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_stepper_button.dart';

class PlayerRateStepper extends StatelessWidget {
  const PlayerRateStepper({
    super.key,
    required this.currentRate,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int currentRate;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: formColors.stepperBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "레이팅",
                style: TextStyle(fontSize: 12, color: formColors.stepperLabelText),
              ),
              Text(
                currentRate.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: formColors.stepperValueText,
                ),
              ),
            ],
          ),
          Row(
            children: [
              PlayerStepperButton(icon: Icons.remove, onPressed: onDecrease),
              const SizedBox(width: 12),
              PlayerStepperButton(icon: Icons.add, onPressed: onIncrease),
            ],
          ),
        ],
      ),
    );
  }
}

