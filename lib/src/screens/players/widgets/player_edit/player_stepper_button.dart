import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class PlayerStepperButton extends StatelessWidget {
  const PlayerStepperButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Material(
      color: formColors.stepperBtnBg,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        icon: Icon(icon, color: formColors.stepperBtnIcon),
        onPressed: onPressed,
      ),
    );
  }
}

