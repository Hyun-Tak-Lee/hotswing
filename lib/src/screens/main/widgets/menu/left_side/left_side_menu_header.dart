import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 좌측 서랍 헤더 위젯.
class LeftSideMenuHeader extends StatelessWidget {
  const LeftSideMenuHeader({
    super.key,
    required this.playerCount,
    required this.isMobile,
    required this.isTablet,
    required this.onClearAll,
    required this.onAddGuest,
    required this.onAddRegular,
  });

  final int playerCount;
  final bool isMobile;
  final bool isTablet;
  final VoidCallback onClearAll;
  final VoidCallback onAddGuest;
  final VoidCallback onAddRegular;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final double headerHeight = isTablet ? 160.0 : 110.0;
    final double titleFontSize = isTablet ? 22.0 : 17.0;
    final double iconSize = isTablet ? 26.0 : 20.0;
    final EdgeInsets buttonPadding = EdgeInsets.all(isMobile ? 5.0 : 8.0);

    return SizedBox(
      height: headerHeight,
      child: DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColors.gradientStart, baseColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '참여자 ($playerCount명)',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: baseColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '전체 참여자 제외',
                  icon: const Icon(Icons.delete_sweep),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onClearAll,
                ),
                SizedBox(width: isMobile ? 4 : 8),
                IconButton(
                  tooltip: '게스트 추가',
                  icon: const Icon(Icons.person_pin),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onAddGuest,
                ),
                SizedBox(width: isMobile ? 4 : 8),
                IconButton(
                  tooltip: '일반 참여자 추가',
                  icon: const Icon(Icons.person_add),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onAddRegular,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

