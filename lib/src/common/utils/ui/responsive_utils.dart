import 'package:flutter/material.dart';

/// 화면 크기에 따른 모바일/태블릿 반응형 레이아웃 및 텍스트 스케일링 유틸리티.
class ResponsiveUtils {
  /// 태블릿을 구분하기 위한 너비 기준값(dp)입니다.
  static const double tabletThreshold = 600.0;

  /// 현재 화면 너비가 태블릿 기준값보다 작은 모바일 환경인지 확인합니다.
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletThreshold;
  }

  /// 현재 화면 너비가 태블릿 기준값 이상인 태블릿 환경인지 확인합니다.
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletThreshold;
  }

  /// 기기 유형에 따라 적절한 폰트 크기 비율을 반환합니다.
  static double getTextScale(BuildContext context) {
    return isMobile(context) ? 1.0 : 1.25;
  }

  /// 기존 스타일을 기반으로 반응형 폰트 크기가 적용된 스타일을 반환합니다.
  static TextStyle? getResponsiveStyle(
    BuildContext context,
    TextStyle? baseStyle,
  ) {
    if (baseStyle == null) return null;
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14.0) * getTextScale(context),
    );
  }
}
