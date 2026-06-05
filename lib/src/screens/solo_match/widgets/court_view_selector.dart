import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class CourtViewSelector extends StatelessWidget {
  final CourtViewSection selectedView;
  final ValueChanged<CourtViewSection> onSelectionChanged;
  final bool isLandscape;

  const CourtViewSelector({
    super.key,
    required this.selectedView,
    required this.onSelectionChanged,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);

    final children = [
      _buildSegmentOption(
        context,
        courtColors,
        '경기 코트',
        CourtViewSection.assignedView,
        isLandscape,
        isTablet,
      ),
      if (isLandscape) const SizedBox(height: 12.0) else const SizedBox(width: 0),
      _buildSegmentOption(
        context,
        courtColors,
        '대기 코트',
        CourtViewSection.standbyView,
        isLandscape,
        isTablet,
      ),
    ];

    return Container(
      width: isLandscape ? (isTablet ? 110.0 : 80.0) : double.infinity,
      padding: isLandscape ? const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0) : const EdgeInsets.all(4.0),
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: courtColors.courtSelectBg,
        borderRadius: BorderRadius.circular(isLandscape ? 20 : 25),
        boxShadow: isLandscape ? [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: isLandscape
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            )
          : Row(
              children: children
                  .map((w) => w is GestureDetector ? Expanded(child: w) : w)
                  .toList(),
            ),
    );
  }

  Widget _buildSegmentOption(
    BuildContext context,
    CourtColors courtColors,
    String label,
    CourtViewSection value,
    bool isLandscape,
    bool isTablet,
  ) {
    final bool isSelected = (selectedView == value);
    String displayLabel = isLandscape ? label.replaceAll(' ', '\n') : label;

    return GestureDetector(
      onTap: () => onSelectionChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          vertical: isLandscape ? 12.0 : 8.0, 
          horizontal: isLandscape ? 4.0 : 0.0
        ),
        width: isLandscape ? double.infinity : null,
        decoration: BoxDecoration(
          color: isSelected ? null : Colors.transparent,
          gradient: isSelected
              ? RadialGradient(
                  colors: [
                    courtColors.courtSelectActiveBgStart,
                    courtColors.courtSelectActiveBgEnd,
                  ],
                  radius: isLandscape ? 1.0 : 1.5,
                )
              : null,
          borderRadius: BorderRadius.circular(isLandscape ? 16 : 20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          displayLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? 18.0 : (isLandscape ? 14.0 : 15.0),
            height: isLandscape ? 1.3 : null,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? courtColors.courtSelectActiveText : courtColors.courtSelectInactiveText,
          ),
        ),
      ),
    );
  }
}
