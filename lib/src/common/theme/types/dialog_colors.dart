import 'package:flutter/material.dart';

@immutable
class DialogColors extends ThemeExtension<DialogColors> {
  final Color dialogTitleBgStart;
  final Color dialogTitleBgEnd;
  final Color dialogTitleManagerBgStart;
  final Color dialogTitleManagerBgEnd;
  final Color dialogButtonCancelText;
  final Color dialogButtonConfirmBg;
  final Color dialogButtonConfirmText;
  final Color dialogSummaryBg;
  final Color dialogSummaryBorder;

  const DialogColors({
    required this.dialogTitleBgStart,
    required this.dialogTitleBgEnd,
    required this.dialogTitleManagerBgStart,
    required this.dialogTitleManagerBgEnd,
    required this.dialogButtonCancelText,
    required this.dialogButtonConfirmBg,
    required this.dialogButtonConfirmText,
    required this.dialogSummaryBg,
    required this.dialogSummaryBorder,
  });

  @override
  DialogColors copyWith({
    Color? dialogTitleBgStart,
    Color? dialogTitleBgEnd,
    Color? dialogTitleManagerBgStart,
    Color? dialogTitleManagerBgEnd,
    Color? dialogButtonCancelText,
    Color? dialogButtonConfirmBg,
    Color? dialogButtonConfirmText,
    Color? dialogSummaryBg,
    Color? dialogSummaryBorder,
  }) {
    return DialogColors(
      dialogTitleBgStart: dialogTitleBgStart ?? this.dialogTitleBgStart,
      dialogTitleBgEnd: dialogTitleBgEnd ?? this.dialogTitleBgEnd,
      dialogTitleManagerBgStart: dialogTitleManagerBgStart ?? this.dialogTitleManagerBgStart,
      dialogTitleManagerBgEnd: dialogTitleManagerBgEnd ?? this.dialogTitleManagerBgEnd,
      dialogButtonCancelText: dialogButtonCancelText ?? this.dialogButtonCancelText,
      dialogButtonConfirmBg: dialogButtonConfirmBg ?? this.dialogButtonConfirmBg,
      dialogButtonConfirmText: dialogButtonConfirmText ?? this.dialogButtonConfirmText,
      dialogSummaryBg: dialogSummaryBg ?? this.dialogSummaryBg,
      dialogSummaryBorder: dialogSummaryBorder ?? this.dialogSummaryBorder,
    );
  }

  @override
  DialogColors lerp(covariant DialogColors? other, double t) {
    if (other == null) {
      return this;
    }
    return DialogColors(
      dialogTitleBgStart: Color.lerp(dialogTitleBgStart, other.dialogTitleBgStart, t)!,
      dialogTitleBgEnd: Color.lerp(dialogTitleBgEnd, other.dialogTitleBgEnd, t)!,
      dialogTitleManagerBgStart: Color.lerp(dialogTitleManagerBgStart, other.dialogTitleManagerBgStart, t)!,
      dialogTitleManagerBgEnd: Color.lerp(dialogTitleManagerBgEnd, other.dialogTitleManagerBgEnd, t)!,
      dialogButtonCancelText: Color.lerp(dialogButtonCancelText, other.dialogButtonCancelText, t)!,
      dialogButtonConfirmBg: Color.lerp(dialogButtonConfirmBg, other.dialogButtonConfirmBg, t)!,
      dialogButtonConfirmText: Color.lerp(dialogButtonConfirmText, other.dialogButtonConfirmText, t)!,
      dialogSummaryBg: Color.lerp(dialogSummaryBg, other.dialogSummaryBg, t)!,
      dialogSummaryBorder: Color.lerp(dialogSummaryBorder, other.dialogSummaryBorder, t)!,
    );
  }
}
