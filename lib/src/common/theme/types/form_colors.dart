import 'package:flutter/material.dart';

@immutable
class FormColors extends ThemeExtension<FormColors> {
  final Color filterDivider;
  final Color filterTabActiveText;
  final Color filterTabInactiveText;
  final Color filterTabIndicator;
  final Color filterChipActiveBg;
  final Color filterChipInactiveBg;
  final Color filterChipActiveText;
  final Color filterChipInactiveText;
  final Color editFormBg;
  final Color editFormBorder;
  final Color editFormShadow;
  final Color inputBorder;
  final Color inputFocusBorder;
  final Color managerToggleActiveBorder;
  final Color managerToggleInactiveBorder;
  final Color managerToggleInactiveText;
  final Color genderActiveBg;
  final Color genderActiveBorder;
  final Color genderInactiveBg;
  final Color genderInactiveText;
  final Color genderActiveText;
  final Color skillChipActiveBg;
  final Color skillChipCheckmark;
  final Color skillChipActiveText;
  final Color stepperBg;
  final Color stepperLabelText;
  final Color stepperValueText;
  final Color stepperBtnBg;
  final Color stepperBtnIcon;
  final Color footerCancelText;
  final Color footerSubmitBg;
  final Color footerSubmitText;
  final Color footerSubmitShadow;

  const FormColors({
    required this.filterDivider,
    required this.filterTabActiveText,
    required this.filterTabInactiveText,
    required this.filterTabIndicator,
    required this.filterChipActiveBg,
    required this.filterChipInactiveBg,
    required this.filterChipActiveText,
    required this.filterChipInactiveText,
    required this.editFormBg,
    required this.editFormBorder,
    required this.editFormShadow,
    required this.inputBorder,
    required this.inputFocusBorder,
    required this.managerToggleActiveBorder,
    required this.managerToggleInactiveBorder,
    required this.managerToggleInactiveText,
    required this.genderActiveBg,
    required this.genderActiveBorder,
    required this.genderInactiveBg,
    required this.genderInactiveText,
    required this.genderActiveText,
    required this.skillChipActiveBg,
    required this.skillChipCheckmark,
    required this.skillChipActiveText,
    required this.stepperBg,
    required this.stepperLabelText,
    required this.stepperValueText,
    required this.stepperBtnBg,
    required this.stepperBtnIcon,
    required this.footerCancelText,
    required this.footerSubmitBg,
    required this.footerSubmitText,
    required this.footerSubmitShadow,
  });

  @override
  FormColors copyWith({
    Color? filterDivider,
    Color? filterTabActiveText,
    Color? filterTabInactiveText,
    Color? filterTabIndicator,
    Color? filterChipActiveBg,
    Color? filterChipInactiveBg,
    Color? filterChipActiveText,
    Color? filterChipInactiveText,
    Color? editFormBg,
    Color? editFormBorder,
    Color? editFormShadow,
    Color? inputBorder,
    Color? inputFocusBorder,
    Color? managerToggleActiveBorder,
    Color? managerToggleInactiveBorder,
    Color? managerToggleInactiveText,
    Color? genderActiveBg,
    Color? genderActiveBorder,
    Color? genderInactiveBg,
    Color? genderInactiveText,
    Color? genderActiveText,
    Color? skillChipActiveBg,
    Color? skillChipCheckmark,
    Color? skillChipActiveText,
    Color? stepperBg,
    Color? stepperLabelText,
    Color? stepperValueText,
    Color? stepperBtnBg,
    Color? stepperBtnIcon,
    Color? footerCancelText,
    Color? footerSubmitBg,
    Color? footerSubmitText,
    Color? footerSubmitShadow,
  }) {
    return FormColors(
      filterDivider: filterDivider ?? this.filterDivider,
      filterTabActiveText: filterTabActiveText ?? this.filterTabActiveText,
      filterTabInactiveText: filterTabInactiveText ?? this.filterTabInactiveText,
      filterTabIndicator: filterTabIndicator ?? this.filterTabIndicator,
      filterChipActiveBg: filterChipActiveBg ?? this.filterChipActiveBg,
      filterChipInactiveBg: filterChipInactiveBg ?? this.filterChipInactiveBg,
      filterChipActiveText: filterChipActiveText ?? this.filterChipActiveText,
      filterChipInactiveText: filterChipInactiveText ?? this.filterChipInactiveText,
      editFormBg: editFormBg ?? this.editFormBg,
      editFormBorder: editFormBorder ?? this.editFormBorder,
      editFormShadow: editFormShadow ?? this.editFormShadow,
      inputBorder: inputBorder ?? this.inputBorder,
      inputFocusBorder: inputFocusBorder ?? this.inputFocusBorder,
      managerToggleActiveBorder: managerToggleActiveBorder ?? this.managerToggleActiveBorder,
      managerToggleInactiveBorder: managerToggleInactiveBorder ?? this.managerToggleInactiveBorder,
      managerToggleInactiveText: managerToggleInactiveText ?? this.managerToggleInactiveText,
      genderActiveBg: genderActiveBg ?? this.genderActiveBg,
      genderActiveBorder: genderActiveBorder ?? this.genderActiveBorder,
      genderInactiveBg: genderInactiveBg ?? this.genderInactiveBg,
      genderInactiveText: genderInactiveText ?? this.genderInactiveText,
      genderActiveText: genderActiveText ?? this.genderActiveText,
      skillChipActiveBg: skillChipActiveBg ?? this.skillChipActiveBg,
      skillChipCheckmark: skillChipCheckmark ?? this.skillChipCheckmark,
      skillChipActiveText: skillChipActiveText ?? this.skillChipActiveText,
      stepperBg: stepperBg ?? this.stepperBg,
      stepperLabelText: stepperLabelText ?? this.stepperLabelText,
      stepperValueText: stepperValueText ?? this.stepperValueText,
      stepperBtnBg: stepperBtnBg ?? this.stepperBtnBg,
      stepperBtnIcon: stepperBtnIcon ?? this.stepperBtnIcon,
      footerCancelText: footerCancelText ?? this.footerCancelText,
      footerSubmitBg: footerSubmitBg ?? this.footerSubmitBg,
      footerSubmitText: footerSubmitText ?? this.footerSubmitText,
      footerSubmitShadow: footerSubmitShadow ?? this.footerSubmitShadow,
    );
  }

  @override
  FormColors lerp(ThemeExtension<FormColors>? other, double t) {
    if (other is! FormColors) {
      return this;
    }
    return FormColors(
      filterDivider: Color.lerp(filterDivider, other.filterDivider, t)!,
      filterTabActiveText: Color.lerp(filterTabActiveText, other.filterTabActiveText, t)!,
      filterTabInactiveText: Color.lerp(filterTabInactiveText, other.filterTabInactiveText, t)!,
      filterTabIndicator: Color.lerp(filterTabIndicator, other.filterTabIndicator, t)!,
      filterChipActiveBg: Color.lerp(filterChipActiveBg, other.filterChipActiveBg, t)!,
      filterChipInactiveBg: Color.lerp(filterChipInactiveBg, other.filterChipInactiveBg, t)!,
      filterChipActiveText: Color.lerp(filterChipActiveText, other.filterChipActiveText, t)!,
      filterChipInactiveText: Color.lerp(filterChipInactiveText, other.filterChipInactiveText, t)!,
      editFormBg: Color.lerp(editFormBg, other.editFormBg, t)!,
      editFormBorder: Color.lerp(editFormBorder, other.editFormBorder, t)!,
      editFormShadow: Color.lerp(editFormShadow, other.editFormShadow, t)!,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t)!,
      inputFocusBorder: Color.lerp(inputFocusBorder, other.inputFocusBorder, t)!,
      managerToggleActiveBorder: Color.lerp(managerToggleActiveBorder, other.managerToggleActiveBorder, t)!,
      managerToggleInactiveBorder: Color.lerp(managerToggleInactiveBorder, other.managerToggleInactiveBorder, t)!,
      managerToggleInactiveText: Color.lerp(managerToggleInactiveText, other.managerToggleInactiveText, t)!,
      genderActiveBg: Color.lerp(genderActiveBg, other.genderActiveBg, t)!,
      genderActiveBorder: Color.lerp(genderActiveBorder, other.genderActiveBorder, t)!,
      genderInactiveBg: Color.lerp(genderInactiveBg, other.genderInactiveBg, t)!,
      genderInactiveText: Color.lerp(genderInactiveText, other.genderInactiveText, t)!,
      genderActiveText: Color.lerp(genderActiveText, other.genderActiveText, t)!,
      skillChipActiveBg: Color.lerp(skillChipActiveBg, other.skillChipActiveBg, t)!,
      skillChipCheckmark: Color.lerp(skillChipCheckmark, other.skillChipCheckmark, t)!,
      skillChipActiveText: Color.lerp(skillChipActiveText, other.skillChipActiveText, t)!,
      stepperBg: Color.lerp(stepperBg, other.stepperBg, t)!,
      stepperLabelText: Color.lerp(stepperLabelText, other.stepperLabelText, t)!,
      stepperValueText: Color.lerp(stepperValueText, other.stepperValueText, t)!,
      stepperBtnBg: Color.lerp(stepperBtnBg, other.stepperBtnBg, t)!,
      stepperBtnIcon: Color.lerp(stepperBtnIcon, other.stepperBtnIcon, t)!,
      footerCancelText: Color.lerp(footerCancelText, other.footerCancelText, t)!,
      footerSubmitBg: Color.lerp(footerSubmitBg, other.footerSubmitBg, t)!,
      footerSubmitText: Color.lerp(footerSubmitText, other.footerSubmitText, t)!,
      footerSubmitShadow: Color.lerp(footerSubmitShadow, other.footerSubmitShadow, t)!,
    );
  }
}
