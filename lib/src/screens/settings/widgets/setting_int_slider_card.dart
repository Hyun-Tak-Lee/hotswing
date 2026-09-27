import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 정수(int) 값을 조절하기 위한 슬라이더 카드 위젯.
class SettingIntSliderCard extends StatelessWidget {
  final String title;
  final String leftText;
  final String rightText;
  final int value;
  final int min;
  final int max;
  final int divisions;
  final String unit;
  final ValueChanged<int> onChanged;
  final double iconAndFontSize;

  const SettingIntSliderCard({
    super.key,
    required this.title,
    required this.leftText,
    required this.rightText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
    required this.iconAndFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = '$value$unit';
    final baseColors = context.baseColors;
    final cardBg = baseColors.cardBg;
    final shadowColor = baseColors.cardShadow;
    final textColor = baseColors.textPrimary;
    final textVariantColor = baseColors.textSecondary;
    final primaryColor = baseColors.primaryAccent;
    final darkAccent = baseColors.darkAccent;
    final inactiveTrack = baseColors.inactiveTrack;
    final thumbColor = baseColors.thumbColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColors.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: iconAndFontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    leftText,
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.8,
                      color: textVariantColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: darkAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rightText,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.8,
                      color: textVariantColor,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primaryColor,
                inactiveTrackColor: inactiveTrack,
                thumbColor: thumbColor,
                overlayColor: primaryColor.withValues(alpha: 0.2),
                valueIndicatorColor: primaryColor,
                valueIndicatorTextStyle: TextStyle(
                  color: baseColors.sliderIndicatorText,
                ),
                trackHeight: 6.0,
              ),
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: divisions,
                label: '$value$unit',
                onChanged: (double v) => onChanged(v.round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
