import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 설정 화면 섹션 헤더 위젯. 접기/펼치기 토글 기능을 제공합니다.
class SettingSectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ColorScheme colorScheme;

  const SettingSectionHeader({
    super.key,
    required this.title,
    required this.fontSize,
    required this.isExpanded,
    required this.onToggle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final primaryColor = baseColors.primaryAccent;
    final textColor = baseColors.textPrimary;
    final iconColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.onSurfaceVariant
        : Colors.grey.shade600;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: fontSize * 1.2,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: iconColor,
              size: fontSize * 1.2,
            ),
          ],
        ),
      ),
    );
  }
}
