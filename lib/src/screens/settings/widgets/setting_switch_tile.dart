import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 제목과 부제목, 토글 스위치를 포함하는 설정 행 위젯.
class SettingSwitchTile extends StatelessWidget {
  /// 설정 항목의 타이틀 텍스트.
  final String title;

  /// 설정 항목의 보조 설명 텍스트 (선택).
  final String? subtitle;

  /// 스위치 활성화 상태.
  final bool value;

  /// 스위치 토글 시 호출되는 콜백.
  final ValueChanged<bool> onChanged;

  /// 기본 아이콘 및 폰트 크기.
  final double iconAndFontSize;

  /// [SettingSwitchTile] 생성자.
  const SettingSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.iconAndFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final textColor = baseColors.textPrimary;
    final primaryColor = baseColors.primaryAccent;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
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
              if (subtitle != null) ...[
                const SizedBox(height: 4.0),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: iconAndFontSize * 0.75,
                    color: textColor.withAlpha(160),
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeTrackColor: primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

