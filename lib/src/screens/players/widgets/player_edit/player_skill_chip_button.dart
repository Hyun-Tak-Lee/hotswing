import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class PlayerSkillChipButton extends StatelessWidget {
  const PlayerSkillChipButton({
    super.key,
    required this.level,
    required this.isSelected,
    required this.onSelected,
  });

  final String level;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final formColors = context.formColors;
    final playerColors = context.playerColors;
    final isTablet = ResponsiveUtils.isTablet(context);

    return InkWell(
      onTap: () => onSelected(level),
      borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: BoxConstraints(
          minWidth: isTablet ? 54 : 44,
          minHeight: isTablet ? 48 : 42,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 14,
          vertical: isTablet ? 12 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? formColors.skillChipActiveBg
              : playerColors.chipBg,
          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          border: Border.all(
            color: isSelected
                ? formColors.skillChipActiveBg
                : formColors.inputBorder,
            width: 1.0,
          ),
        ),
        child: Center(
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: Text(
            level,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? formColors.skillChipActiveText
                  : baseColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}


