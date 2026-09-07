import 'package:flutter/material.dart';

@immutable
class BaseColors extends ThemeExtension<BaseColors> {
  final Color gradientStart;
  final Color gradientEnd;
  final Color contentBg;
  final Color menuIcon;
  final Color cardBg;
  final Color cardShadow;
  final Color textPrimary;
  final Color primaryAccent;
  final Color darkAccent;
  final Color inactiveTrack;
  final Color thumbColor;
  final Color cardBorderColor;
  final Color sliderIndicatorText;
  final Color textSecondary;
  final Color navBarSelected;
  final Color navBarUnselected;
  final Color navBarBg;
  final Color navBarIndicator;

  const BaseColors({
    required this.gradientStart,
    required this.gradientEnd,
    required this.contentBg,
    required this.menuIcon,
    required this.cardBg,
    required this.cardShadow,
    required this.textPrimary,
    required this.primaryAccent,
    required this.darkAccent,
    required this.inactiveTrack,
    required this.thumbColor,
    required this.cardBorderColor,
    required this.sliderIndicatorText,
    required this.textSecondary,
    required this.navBarSelected,
    required this.navBarUnselected,
    required this.navBarBg,
    required this.navBarIndicator,
  });

  @override
  BaseColors copyWith({
    Color? gradientStart,
    Color? gradientEnd,
    Color? contentBg,
    Color? menuIcon,
    Color? cardBg,
    Color? cardShadow,
    Color? textPrimary,
    Color? primaryAccent,
    Color? darkAccent,
    Color? inactiveTrack,
    Color? thumbColor,
    Color? cardBorderColor,
    Color? sliderIndicatorText,
    Color? textSecondary,
    Color? navBarSelected,
    Color? navBarUnselected,
    Color? navBarBg,
    Color? navBarIndicator,
  }) {
    return BaseColors(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      contentBg: contentBg ?? this.contentBg,
      menuIcon: menuIcon ?? this.menuIcon,
      cardBg: cardBg ?? this.cardBg,
      cardShadow: cardShadow ?? this.cardShadow,
      textPrimary: textPrimary ?? this.textPrimary,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      darkAccent: darkAccent ?? this.darkAccent,
      inactiveTrack: inactiveTrack ?? this.inactiveTrack,
      thumbColor: thumbColor ?? this.thumbColor,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      sliderIndicatorText: sliderIndicatorText ?? this.sliderIndicatorText,
      textSecondary: textSecondary ?? this.textSecondary,
      navBarSelected: navBarSelected ?? this.navBarSelected,
      navBarUnselected: navBarUnselected ?? this.navBarUnselected,
      navBarBg: navBarBg ?? this.navBarBg,
      navBarIndicator: navBarIndicator ?? this.navBarIndicator,
    );
  }

  @override
  BaseColors lerp(covariant BaseColors? other, double t) {
    if (other == null) {
      return this;
    }
    return BaseColors(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      contentBg: Color.lerp(contentBg, other.contentBg, t)!,
      menuIcon: Color.lerp(menuIcon, other.menuIcon, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      darkAccent: Color.lerp(darkAccent, other.darkAccent, t)!,
      inactiveTrack: Color.lerp(inactiveTrack, other.inactiveTrack, t)!,
      thumbColor: Color.lerp(thumbColor, other.thumbColor, t)!,
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t)!,
      sliderIndicatorText: Color.lerp(sliderIndicatorText, other.sliderIndicatorText, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      navBarSelected: Color.lerp(navBarSelected, other.navBarSelected, t)!,
      navBarUnselected: Color.lerp(navBarUnselected, other.navBarUnselected, t)!,
      navBarBg: Color.lerp(navBarBg, other.navBarBg, t)!,
      navBarIndicator: Color.lerp(navBarIndicator, other.navBarIndicator, t)!,
    );
  }
}
