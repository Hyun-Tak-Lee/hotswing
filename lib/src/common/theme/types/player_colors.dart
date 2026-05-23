import 'package:flutter/material.dart';

@immutable
class PlayerColors extends ThemeExtension<PlayerColors> {
  final Color playerItemActiveStart;
  final Color playerItemActiveEnd;
  final Color playerItemInactive;
  final Color playerHeaderGradientStart;
  final Color playerHeaderGradientEnd;
  final Color playerHeaderFg;
  final Color playerHeaderFgVariant;
  final Color playerSearchBg;
  final Color chipBg;
  final Color playerInputFill;
  final Color managerToggleActiveBg;
  final Color managerToggleInactiveBg;
  final Color infoTagBg;
  final Color rateWidgetLabel;
  final Color rateWidgetValue;
  final Color rateWidgetSkill;
  final Color roleManager;
  final Color roleUser;
  final Color roleGuest;
  final Color genderTag;

  const PlayerColors({
    required this.playerItemActiveStart,
    required this.playerItemActiveEnd,
    required this.playerItemInactive,
    required this.playerHeaderGradientStart,
    required this.playerHeaderGradientEnd,
    required this.playerHeaderFg,
    required this.playerHeaderFgVariant,
    required this.playerSearchBg,
    required this.chipBg,
    required this.playerInputFill,
    required this.managerToggleActiveBg,
    required this.managerToggleInactiveBg,
    required this.infoTagBg,
    required this.rateWidgetLabel,
    required this.rateWidgetValue,
    required this.rateWidgetSkill,
    required this.roleManager,
    required this.roleUser,
    required this.roleGuest,
    required this.genderTag,
  });

  @override
  PlayerColors copyWith({
    Color? playerItemActiveStart,
    Color? playerItemActiveEnd,
    Color? playerItemInactive,
    Color? playerHeaderGradientStart,
    Color? playerHeaderGradientEnd,
    Color? playerHeaderFg,
    Color? playerHeaderFgVariant,
    Color? playerSearchBg,
    Color? chipBg,
    Color? playerInputFill,
    Color? managerToggleActiveBg,
    Color? managerToggleInactiveBg,
    Color? infoTagBg,
    Color? rateWidgetLabel,
    Color? rateWidgetValue,
    Color? rateWidgetSkill,
    Color? roleManager,
    Color? roleUser,
    Color? roleGuest,
    Color? genderTag,
  }) {
    return PlayerColors(
      playerItemActiveStart: playerItemActiveStart ?? this.playerItemActiveStart,
      playerItemActiveEnd: playerItemActiveEnd ?? this.playerItemActiveEnd,
      playerItemInactive: playerItemInactive ?? this.playerItemInactive,
      playerHeaderGradientStart: playerHeaderGradientStart ?? this.playerHeaderGradientStart,
      playerHeaderGradientEnd: playerHeaderGradientEnd ?? this.playerHeaderGradientEnd,
      playerHeaderFg: playerHeaderFg ?? this.playerHeaderFg,
      playerHeaderFgVariant: playerHeaderFgVariant ?? this.playerHeaderFgVariant,
      playerSearchBg: playerSearchBg ?? this.playerSearchBg,
      chipBg: chipBg ?? this.chipBg,
      playerInputFill: playerInputFill ?? this.playerInputFill,
      managerToggleActiveBg: managerToggleActiveBg ?? this.managerToggleActiveBg,
      managerToggleInactiveBg: managerToggleInactiveBg ?? this.managerToggleInactiveBg,
      infoTagBg: infoTagBg ?? this.infoTagBg,
      rateWidgetLabel: rateWidgetLabel ?? this.rateWidgetLabel,
      rateWidgetValue: rateWidgetValue ?? this.rateWidgetValue,
      rateWidgetSkill: rateWidgetSkill ?? this.rateWidgetSkill,
      roleManager: roleManager ?? this.roleManager,
      roleUser: roleUser ?? this.roleUser,
      roleGuest: roleGuest ?? this.roleGuest,
      genderTag: genderTag ?? this.genderTag,
    );
  }

  @override
  PlayerColors lerp(ThemeExtension<PlayerColors>? other, double t) {
    if (other is! PlayerColors) {
      return this;
    }
    return PlayerColors(
      playerItemActiveStart: Color.lerp(playerItemActiveStart, other.playerItemActiveStart, t)!,
      playerItemActiveEnd: Color.lerp(playerItemActiveEnd, other.playerItemActiveEnd, t)!,
      playerItemInactive: Color.lerp(playerItemInactive, other.playerItemInactive, t)!,
      playerHeaderGradientStart: Color.lerp(playerHeaderGradientStart, other.playerHeaderGradientStart, t)!,
      playerHeaderGradientEnd: Color.lerp(playerHeaderGradientEnd, other.playerHeaderGradientEnd, t)!,
      playerHeaderFg: Color.lerp(playerHeaderFg, other.playerHeaderFg, t)!,
      playerHeaderFgVariant: Color.lerp(playerHeaderFgVariant, other.playerHeaderFgVariant, t)!,
      playerSearchBg: Color.lerp(playerSearchBg, other.playerSearchBg, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      playerInputFill: Color.lerp(playerInputFill, other.playerInputFill, t)!,
      managerToggleActiveBg: Color.lerp(managerToggleActiveBg, other.managerToggleActiveBg, t)!,
      managerToggleInactiveBg: Color.lerp(managerToggleInactiveBg, other.managerToggleInactiveBg, t)!,
      infoTagBg: Color.lerp(infoTagBg, other.infoTagBg, t)!,
      rateWidgetLabel: Color.lerp(rateWidgetLabel, other.rateWidgetLabel, t)!,
      rateWidgetValue: Color.lerp(rateWidgetValue, other.rateWidgetValue, t)!,
      rateWidgetSkill: Color.lerp(rateWidgetSkill, other.rateWidgetSkill, t)!,
      roleManager: Color.lerp(roleManager, other.roleManager, t)!,
      roleUser: Color.lerp(roleUser, other.roleUser, t)!,
      roleGuest: Color.lerp(roleGuest, other.roleGuest, t)!,
      genderTag: Color.lerp(genderTag, other.genderTag, t)!,
    );
  }
}
