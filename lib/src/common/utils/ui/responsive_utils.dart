import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double tabletThreshold = 600.0;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletThreshold;
  }

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
