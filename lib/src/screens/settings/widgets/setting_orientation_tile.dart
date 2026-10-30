import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/enums/widget_feature.dart';

/// 화면 방향(자동, 세로 고정, 가로 고정)을 선택하는 설정 타일 위젯.
class SettingOrientationTile extends StatelessWidget {
  /// 현재 선택된 화면 방향 모드.
  final ScreenOrientationMode selectedMode;

  /// 화면 방향 변경 시 호출되는 콜백.
  final ValueChanged<ScreenOrientationMode> onChanged;

  /// 기본 아이콘 및 폰트 크기.
  final double iconAndFontSize;

  /// [SettingOrientationTile] 생성자.
  const SettingOrientationTile({
    super.key,
    required this.selectedMode,
    required this.onChanged,
    required this.iconAndFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final textColor = baseColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '화면 방향 설정',
          style: TextStyle(
            fontSize: iconAndFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          '앱의 화면 회전 및 방향 고정 방식을 설정합니다',
          style: TextStyle(
            fontSize: iconAndFontSize * 0.75,
            color: textColor.withAlpha(160),
          ),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ScreenOrientationMode>(
            segments: const <ButtonSegment<ScreenOrientationMode>>[
              ButtonSegment<ScreenOrientationMode>(
                value: ScreenOrientationMode.auto,
                label: Text('자동 회전'),
                icon: Icon(Icons.screen_rotation),
              ),
              ButtonSegment<ScreenOrientationMode>(
                value: ScreenOrientationMode.portrait,
                label: Text('세로 고정'),
                icon: Icon(Icons.stay_current_portrait),
              ),
              ButtonSegment<ScreenOrientationMode>(
                value: ScreenOrientationMode.landscape,
                label: Text('가로 고정'),
                icon: Icon(Icons.stay_current_landscape),
              ),
            ],
            selected: <ScreenOrientationMode>{selectedMode},
            onSelectionChanged: (Set<ScreenOrientationMode> newSelection) {
              onChanged(newSelection.first);
            },
            showSelectedIcon: false,
          ),
        ),
      ],
    );
  }
}
