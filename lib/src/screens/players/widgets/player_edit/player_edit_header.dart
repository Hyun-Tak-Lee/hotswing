import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_manager_toggle.dart';

class PlayerEditHeader extends StatelessWidget {
  const PlayerEditHeader({
    super.key,
    required this.controller,
    required this.isManager,
    required this.isGuest,
    required this.onToggleManager,
  });

  final TextEditingController controller;
  final bool isManager;
  final bool isGuest;
  final VoidCallback onToggleManager;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final formColors = context.formColors;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: baseColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: "이름",
              labelStyle: TextStyle(color: baseColors.textSecondary),
              prefixIcon: Icon(
                Icons.edit_note,
                size: 20,
                color: baseColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: formColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: formColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: formColors.inputFocusBorder,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: playerColors.playerInputFill,
            ),
            validator: (val) => (val == null || val.isEmpty) ? "필수" : null,
          ),
        ),
        const SizedBox(width: 16),
        PlayerManagerToggle(
          isManager: isManager,
          isGuest: isGuest,
          onToggle: onToggleManager,
        ),
      ],
    );
  }
}

