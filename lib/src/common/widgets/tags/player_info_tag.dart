import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class PlayerInfoTag extends StatelessWidget {
  final String text;
  final Color color;

  const PlayerInfoTag({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final textScale = ResponsiveUtils.getTextScale(context);

    // 모바일/태블릿에 따른 동적 크기 설정
    final double paddingHorizontal = isTablet ? 12.0 : 8.0;
    final double paddingVertical = isTablet ? 6.0 : 4.0;
    final double fontSize = (isTablet ? 14.0 : 12.0) * textScale;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
