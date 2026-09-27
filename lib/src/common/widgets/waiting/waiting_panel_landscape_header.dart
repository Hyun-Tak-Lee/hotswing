import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/widgets/waiting/waiting_sort_menu.dart';
import 'package:hotswing/src/enums/widget_feature.dart';

/// 대기 플레이어 패널의 상단 헤더(가로 모드) 위젯.
class WaitingPanelLandscapeHeader extends StatelessWidget {
  /// [WaitingPanelLandscapeHeader] 생성자.
  const WaitingPanelLandscapeHeader({
    super.key,
    required this.isTablet,
    required this.count,
    required this.sortCriterion,
    required this.onSortSelected,
  });

  /// 태블릿 화면 여부.
  final bool isTablet;

  /// 대기 중인 플레이어 수.
  final int count;

  /// 현재 정렬 기준.
  final SortCriterion sortCriterion;

  /// 정렬 기준 변경 시 호출되는 콜백.
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
            child: WaitingSortMenu(
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

