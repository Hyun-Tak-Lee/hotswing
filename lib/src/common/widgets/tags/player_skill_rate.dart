import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class PlayerSkillRateWidget extends StatelessWidget {
  final String skillLevel;
  final int rate;

  const PlayerSkillRateWidget({
    super.key,
    required this.skillLevel,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final textScale = ResponsiveUtils.getTextScale(context);

    final double labelFontSize = (isTablet ? 12.0 : 10.0) * textScale;
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
            color: Colors.blueAccent.shade700,
            fontWeight: FontWeight.w900,
          ),
        ),
        Container(
          height: 12,
          width: 1.5,
          color: Colors.grey.shade400,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        Text(
          'Rate ',
          style: TextStyle(
            fontSize: labelFontSize,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          rate.toString(),
          style: TextStyle(
            fontSize: rateFontSize,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
