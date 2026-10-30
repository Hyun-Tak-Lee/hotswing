import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 모바일 세로 전체화면에서 코트 뷰 선택기 옆에 배치되는 원형 전체화면 종료 버튼.
class CourtFullscreenExitButton extends StatelessWidget {
  /// 전체화면 축소(종료) 콜백.
  final VoidCallback onExitFullScreen;

  /// [CourtFullscreenExitButton] 생성자.
  const CourtFullscreenExitButton({super.key, required this.onExitFullScreen});

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;

    return Tooltip(
      message: '전체 화면 종료',
      child: Material(
        color: courtColors.courtSelectBg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onExitFullScreen,
          child: SizedBox(
            width: 42.0,
            height: 42.0,
            child: Icon(
              Icons.fullscreen_exit_rounded,
              size: 24.0,
              color: baseColors.primaryAccent,
            ),
          ),
        ),
      ),
    );
  }
}
