import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class FilterOptions<T> extends StatelessWidget {
  const FilterOptions({
    super.key,
    required this.values,
    required this.selectedValues,
    required this.onSelected,
    required this.labelBuilder,
    required this.chipFontSize,
  });

  final List<T> values;
  final Set<T> selectedValues;
  final Function(T) onSelected;
  final String Function(T) labelBuilder;
  final double chipFontSize;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: values.map((value) {
        final isSelected = selectedValues.contains(value);
        return GestureDetector(
          onTap: () {
            onSelected(value);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? formColors.filterChipActiveBg
                  : formColors.filterChipInactiveBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labelBuilder(value),
              style: TextStyle(
                fontSize: chipFontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? formColors.filterChipActiveText
                    : formColors.filterChipInactiveText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

