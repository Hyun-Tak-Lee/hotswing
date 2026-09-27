import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class PlayerGenderButton extends StatelessWidget {
  const PlayerGenderButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;
    final isTablet = ResponsiveUtils.isTablet(context);

    return Expanded(
      child: InkWell(
        onTap: () => onSelected(label),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: isTablet ? 14 : 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? formColors.genderActiveBg
                : formColors.genderInactiveBg,
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            border: Border.all(
              color: isSelected
                  ? formColors.genderActiveBorder
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: isSelected
                  ? formColors.genderActiveText
                  : formColors.genderInactiveText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

