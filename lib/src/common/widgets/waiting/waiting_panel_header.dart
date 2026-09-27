import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/widgets/waiting/waiting_sort_menu.dart';
import 'package:hotswing/src/enums/widget_feature.dart';

/// 대기 플레이어 패널의 상단 헤더(세로 모드) 위젯.
class WaitingPanelHeader extends StatelessWidget {
  /// [WaitingPanelHeader] 생성자.
  const WaitingPanelHeader({
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
          WaitingSortMenu(
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

