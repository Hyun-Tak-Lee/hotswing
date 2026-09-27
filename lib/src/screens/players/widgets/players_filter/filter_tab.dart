import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class FilterTab extends StatelessWidget {
  const FilterTab({
    super.key,
    required this.title,
    required this.fontSize,
    required this.isSelected,
    required this.onTap,
    this.selectedCount = 0,
  });

  final String title;
  final double fontSize;
  final bool isSelected;
  final VoidCallback onTap;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? formColors.filterTabActiveText
                      : formColors.filterTabInactiveText,
                ),
              ),
              if (selectedCount > 0) ...[
                const SizedBox(width: 3),
                Text(
                  '($selectedCount)',
                  style: TextStyle(
                    fontSize: fontSize * 0.85,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? formColors.filterTabIndicator
                        : formColors.filterTabInactiveText,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: selectedCount > 0 ? 44 : 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? formColors.filterTabIndicator
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

