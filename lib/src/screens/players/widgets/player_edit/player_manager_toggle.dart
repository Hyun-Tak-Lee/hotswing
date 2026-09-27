import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class PlayerManagerToggle extends StatelessWidget {
  const PlayerManagerToggle({
    super.key,
    required this.isManager,
    required this.isGuest,
    required this.onToggle,
  });

  final bool isManager;
  final bool isGuest;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final playerColors = context.playerColors;
    final formColors = context.formColors;

    return InkWell(
      onTap: isGuest ? null : onToggle,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isManager
              ? playerColors.managerToggleActiveBg
              : playerColors.managerToggleInactiveBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isManager
                ? formColors.managerToggleActiveBorder
                : formColors.managerToggleInactiveBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isManager ? Icons.verified_user : Icons.person_outline,
              color: isManager
                  ? Colors.orange
                  : formColors.managerToggleInactiveText,
            ),
            Text(
              "운영진",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isManager
                    ? Colors.orange
                    : formColors.managerToggleInactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

