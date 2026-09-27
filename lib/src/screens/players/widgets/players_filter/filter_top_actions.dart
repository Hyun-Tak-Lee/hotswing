import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class FilterTopActions extends StatelessWidget {
  const FilterTopActions({
    super.key,
    required this.onClear,
    required this.onApply,
    required this.fontSize,
  });

  final VoidCallback onClear;
  final VoidCallback onApply;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 일괄 해제
        InkWell(
          onTap: onClear,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              '일괄 해제',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: formColors.filterTabInactiveText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // 적용
        InkWell(
          onTap: onApply,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: formColors.filterChipActiveBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '적용',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: formColors.filterChipActiveText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
