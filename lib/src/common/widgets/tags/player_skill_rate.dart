import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 플레이어의 급수(Skill Level)와 레이팅(Rate)을 시각적으로 표시하는 위젯.
class PlayerSkillRateWidget extends StatelessWidget {
  /// 플레이어 급수 문자열 (예: 'A', 'B', 'C').
  final String skillLevel;

  /// 플레이어 레이팅 점수.
  final int rate;

  /// 급수 텍스트 기준 폰트 크기 (미지정 시 기본 반응형 스케일 사용).
  final double? fontSize;

  /// 레이팅 점수 기준 폰트 크기 (미지정 시 fontSize의 0.82배 사용).
  final double? rateFontSize;

  /// [PlayerSkillRateWidget] 생성자.
  const PlayerSkillRateWidget({
    super.key,
    required this.skillLevel,
    required this.rate,
    this.fontSize,
    this.rateFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final textScale = ResponsiveUtils.getTextScale(context);
    final playerColors = context.playerColors;

    final double valueFontSize =
        fontSize ?? ((isTablet ? 15.0 : 13.0) * textScale);
    final double resolvedRateFontSize =
        rateFontSize ??
        (fontSize != null
            ? (fontSize! * 0.82).clamp(9.0, 16.0)
            : ((isTablet ? 12.0 : 10.5) * textScale));

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          skillLevel,
          style: TextStyle(
            fontSize: valueFontSize,
            color: playerColors.rateWidgetSkill,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          rate.toString(),
          style: TextStyle(
            fontSize: resolvedRateFontSize,
            color: playerColors.rateWidgetValue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
