import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 전체화면 모드에서 코트 스크롤 영역 맨 앞(가로 모드 맨 왼쪽 / 세로 모드 맨 위)에 배치되는 퀵 컨트롤 바.
/// 추후 추가 버튼을 반반(50:50)으로 나누어 배치할 수 있도록 설계되어 있습니다.
class CourtFullscreenControlBar extends StatelessWidget {
  /// 가로 모드 여부.
  final bool isLandscape;

  /// 태블릿 화면 여부.
  final bool isTablet;

  /// 가로 모드일 때 코트의 최대 높이.
  final double? maxHeight;

  /// 전체화면 축소(종료) 콜백.
  final VoidCallback onExitFullScreen;

  /// [CourtFullscreenControlBar] 생성자.
  const CourtFullscreenControlBar({
    super.key,
    required this.isLandscape,
    required this.isTablet,
    this.maxHeight,
    required this.onExitFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final primaryColor = baseColors.primaryAccent;

    final EdgeInsets cardMargin = EdgeInsets.symmetric(
      vertical: isTablet ? 3.0 : 5.0,
      horizontal: 5.0,
    );

    // 가로 모드: 너비 46~56px의 수직 바 형태 (상/하 반반 슬롯)
    if (isLandscape) {
      final double barWidth = isTablet ? 56.0 : 46.0;

      return Container(
        width: barWidth,
        height: maxHeight,
        margin: cardMargin,
        decoration: BoxDecoration(
          color: baseColors.cardBg.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: baseColors.cardBorderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              // 상단 슬롯: 전체화면 축소 버튼
              Expanded(
                child: Tooltip(
                  message: '전체 화면 종료',
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15.0),
                    ),
                    onTap: onExitFullScreen,
                    child: Center(
                      child: Icon(
                        Icons.fullscreen_exit_rounded,
                        size: isTablet ? 28.0 : 22.0,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              // 상/하 슬롯 구분선
              Divider(
                height: 1.0,
                thickness: 1.0,
                color: baseColors.cardBorderColor,
              ),
              // 하단 슬롯: 추후 다른 기능 추가를 위한 예약 공간
              const Expanded(
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    // 세로 모드: 높이 40~48px의 수평 바 형태 (좌/우 반반 슬롯)
    final double barHeight = isTablet ? 48.0 : 40.0;

    return Container(
      width: double.infinity,
      height: barHeight,
      margin: cardMargin,
      decoration: BoxDecoration(
        color: baseColors.cardBg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: baseColors.cardBorderColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            // 좌측 슬롯: 전체화면 축소 버튼
            Expanded(
              child: Tooltip(
                message: '전체 화면 종료',
                child: InkWell(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(13.0),
                  ),
                  onTap: onExitFullScreen,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen_exit_rounded,
                          size: isTablet ? 26.0 : 20.0,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '화면 복귀',
                          style: TextStyle(
                            fontSize: isTablet ? 14.0 : 12.0,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 좌/우 슬롯 구분선
            VerticalDivider(
              width: 1.0,
              thickness: 1.0,
              color: baseColors.cardBorderColor,
            ),
            // 우측 슬롯: 추후 다른 기능 추가를 위한 예약 공간
            const Expanded(
              child: SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
