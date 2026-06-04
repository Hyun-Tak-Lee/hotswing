import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class CourtViewSelector extends StatelessWidget {
  final CourtViewSection selectedView;
  final ValueChanged<CourtViewSection> onSelectionChanged;

  const CourtViewSelector({
    super.key,
    required this.selectedView,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: courtColors.courtSelectBg,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentOption(
              context,
              courtColors,
              '경기 코트',
              CourtViewSection.assignedView,
            ),
          ),
          Expanded(
            child: _buildSegmentOption(
              context,
              courtColors,
              '대기 코트',
              CourtViewSection.standbyView,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentOption(
    BuildContext context,
    CourtColors courtColors,
    String label,
    CourtViewSection value,
  ) {
    final bool isSelected = (selectedView == value);
    final isTablet = ResponsiveUtils.isTablet(context);

    return GestureDetector(
      onTap: () => onSelectionChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.transparent,
          gradient: isSelected
              ? RadialGradient(
                  colors: [
                    courtColors.courtSelectActiveBgStart,
                    courtColors.courtSelectActiveBgEnd,
                  ],
                  radius: 1.5,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 18.0 : 16.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? courtColors.courtSelectActiveText : courtColors.courtSelectInactiveText,
          ),
        ),
      ),
    );
  }
}
