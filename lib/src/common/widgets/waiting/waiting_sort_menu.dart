import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/enums/widget_feature.dart';

class WaitingSortMenu extends StatelessWidget {
  const WaitingSortMenu({
    super.key,
    required this.isTablet,
    required this.sortCriterion,
    required this.onSortSelected,
    required this.borderRadius,
    required this.child,
  });

  final bool isTablet;
  final SortCriterion sortCriterion;
  final ValueChanged<SortCriterion> onSortSelected;
  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;

    return PopupMenuButton<SortCriterion>(
      tooltip: '정렬 기준',
      initialValue: sortCriterion,
      color: courtColors.waitingPanelHeaderBg,
      elevation: 6,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      onSelected: onSortSelected,
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<SortCriterion>(
            value: SortCriterion.played,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.sort_rounded,
                  color: baseColors.primaryAccent,
                  size: isTablet ? 24 : 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '경기 적은 순',
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: baseColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<SortCriterion>(
            value: SortCriterion.name,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.sort_by_alpha_rounded,
                  color: baseColors.primaryAccent,
                  size: isTablet ? 24 : 20,
                ),
                const SizedBox(width: 12),
                Text(
                  '이름 가나다 순',
                  style: TextStyle(
                    fontSize: isTablet ? 16.0 : 14.0,
                    color: baseColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ];
      },
      child: child,
    );
  }
}
