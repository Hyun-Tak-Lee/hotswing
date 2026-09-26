import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 플레이어의 급수(Skill Level)와 레이팅(Rate)을 시각적으로 표시하는 위젯.
class PlayerSkillRateWidget extends StatelessWidget {
  /// 플레이어 급수 문자열 (예: 'A', 'B', 'C').
  final String skillLevel;

  /// 플레이어 레이팅 점수.
  final int rate;

  /// [PlayerSkillRateWidget] 생성자.
  const PlayerSkillRateWidget({
    super.key,
    required this.skillLevel,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final textScale = ResponsiveUtils.getTextScale(context);
    final playerColors = context.playerColors;

    final double valueFontSize = (isTablet ? 16.0 : 14.0) * textScale;
    final double rateFontSize = (isTablet ? 13.0 : 11.0) * textScale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          skillLevel,
          style: TextStyle(
            fontSize: valueFontSize + 2, // 급수 강조
            color: playerColors.rateWidgetSkill,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          rate.toString(),
          style: TextStyle(
            fontSize: rateFontSize,
            color: playerColors.rateWidgetValue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
