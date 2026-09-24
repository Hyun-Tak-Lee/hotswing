import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 플레이어 정보(성별, 그룹 등)를 뱃지 형태로 표시하는 위젯.
class PlayerInfoTag extends StatelessWidget {
  /// 표시할 텍스트.
  final String text;

  /// 태그의 테두리 및 그림자/텍스트 색상.
  final Color color;

  /// [PlayerInfoTag] 생성자.
  const PlayerInfoTag({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final playerColors = context.playerColors;
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
        color: playerColors.infoTagBg,
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
