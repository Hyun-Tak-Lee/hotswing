import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/enums/widget_feature.dart';

class WaitingPanelHeader extends StatelessWidget {
  const WaitingPanelHeader({
    super.key,
    required this.isTablet,
    required this.count,
    required this.sortCriterion,
    required this.onSortSelected,
  });

  final bool isTablet;
  final int count;
  final SortCriterion sortCriterion;
  final ValueChanged<SortCriterion> onSortSelected;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: courtColors.waitingPanelHeaderBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                if (isTablet) ...[
                  TextSpan(
                    text: "대기",
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: courtColors.waitingPanelHeaderTitle,
                    ),
                  ),
                  const TextSpan(text: " "),
                ],
                TextSpan(
                  text: '$count',
                  style: TextStyle(
                    fontSize: isTablet ? 18.0 : 16.0,
                    fontWeight: FontWeight.bold,
                    color: baseColors.primaryAccent,
                  ),
                ),
              ],
            ),
          ),
          _WaitingSortMenu(
            isTablet: isTablet,
            sortCriterion: sortCriterion,
            onSortSelected: onSortSelected,
            borderRadius: 12,
            child: isTablet
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: courtColors.waitingPanelSortBtnBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: courtColors.waitingPanelSortBtnBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sortCriterion == SortCriterion.played
                              ? '경기 적은 순'
                              : '이름 가나다 순',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: baseColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.0,
                          color: baseColors.textSecondary,
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.sort,
                      size: 24.0,
                      color: baseColors.textSecondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class WaitingPanelLandscapeHeader extends StatelessWidget {
  const WaitingPanelLandscapeHeader({
    super.key,
    required this.isTablet,
    required this.count,
    required this.sortCriterion,
    required this.onSortSelected,
  });

  final bool isTablet;
  final int count;
  final SortCriterion sortCriterion;
  final ValueChanged<SortCriterion> onSortSelected;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;

    return Container(
      width: isTablet ? 110.0 : 80.0,
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: courtColors.waitingPanelHeaderBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "대기\n",
                    style: TextStyle(
                      fontSize: isTablet ? 16.0 : 13.0,
                      fontWeight: FontWeight.bold,
                      color: courtColors.waitingPanelHeaderTitle,
                      height: 1.2,
                    ),
                  ),
                  TextSpan(
                    text: '$count',
                    style: TextStyle(
                      fontSize: isTablet ? 22.0 : 18.0,
                      fontWeight: FontWeight.w900,
                      color: baseColors.primaryAccent,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: _WaitingSortMenu(
              isTablet: isTablet,
              sortCriterion: sortCriterion,
              onSortSelected: onSortSelected,
              borderRadius: 16,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: courtColors.waitingPanelSortBtnBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      size: isTablet ? 22.0 : 18.0,
                      color: baseColors.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sortCriterion == SortCriterion.played ? '경기순' : '이름순',
                      style: TextStyle(
                        fontSize: isTablet ? 12.0 : 10.0,
                        color: baseColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingSortMenu extends StatelessWidget {
  const _WaitingSortMenu({
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
