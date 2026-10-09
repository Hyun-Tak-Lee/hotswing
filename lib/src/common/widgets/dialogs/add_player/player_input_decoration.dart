import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

InputDecoration playerInputDecoration(
  BuildContext context, {
  required BaseColors baseColors,
  required PlayerColors playerColors,
  required FormColors formColors,
  String? labelText,
  String? hintText,
  required bool isManager,
  double? customVerticalPadding,
  double? customHorizontalPadding,
  Widget? suffixIcon,
  bool isDisabled = false,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    hintStyle: TextStyle(
      color: isDisabled
          ? baseColors.textSecondary.withValues(alpha: 0.5)
          : baseColors.textSecondary,
    ),
    labelStyle: TextStyle(
      color: isDisabled
          ? baseColors.textSecondary.withValues(alpha: 0.5)
          : baseColors.textSecondary,
    ),
    floatingLabelStyle: TextStyle(
      color: isDisabled
          ? baseColors.textSecondary.withValues(alpha: 0.5)
          : baseColors.textPrimary,
      fontWeight: FontWeight.bold,
    ),
    filled: true,
    fillColor: isDisabled ? playerColors.chipBg : playerColors.playerInputFill,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDisabled ? Colors.transparent : formColors.inputBorder,
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isDisabled ? Colors.transparent : formColors.inputBorder,
        width: 1,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.transparent, width: 0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: isManager
            ? playerColors.roleManager
            : formColors.inputFocusBorder,
        width: 2,
      ),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: customHorizontalPadding ?? 16,
      vertical:
          customVerticalPadding ??
          (ResponsiveUtils.isTablet(context) ? 16.0 : 12.0),
    ),
    suffixIcon: suffixIcon,
  );
}
