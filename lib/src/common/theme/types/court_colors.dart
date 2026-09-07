import 'package:flutter/material.dart';

@immutable
class CourtColors extends ThemeExtension<CourtColors> {
  final Color homeDivider;
  final Color courtSelectBg;
  final Color courtSelectActiveBgStart;
  final Color courtSelectActiveBgEnd;
  final Color courtSelectActiveText;
  final Color courtSelectInactiveText;
  final Color waitingPanelBgStart;
  final Color waitingPanelBgEnd;
  final Color waitingPanelHeaderBg;
  final Color waitingPanelHeaderTitle;
  final Color waitingPanelSortBtnBg;
  final Color waitingPanelSortBtnBorder;
  final Color courtCardBgStart;
  final Color courtCardBgEnd;
  final Color courtCardText;
  final Color standbyZoneBgStart;
  final Color standbyZoneBgEnd;
  final Color standbyZoneBorder;
  final Color standbyZoneIcon;
  final Color btnAutoMatchStart;
  final Color btnAutoMatchEnd;
  final Color btnRemoveStart;
  final Color btnRemoveEnd;
  final Color btnFinishStart;
  final Color btnFinishEnd;
  final Color btnSwapStart;
  final Color btnSwapEnd;
  final Color btnRemoveCourtStart;
  final Color btnRemoveCourtEnd;
  final Color playerItemTextPrimary;
  final Color playerItemTextSecondary;
  final Color playerItemGenderText;
  final Color playerItemRateLabel;
  final Color playerItemDivider;
  final Color dropZoneEmptyBg;
  final Color dropZoneInactiveBg;
  final Color dropZoneActiveBg;
  final Color dropZoneHoverBg;
  final Color dropZoneBorder;
  final Color dropZoneCloseIcon;

  const CourtColors({
    required this.homeDivider,
    required this.courtSelectBg,
    required this.courtSelectActiveBgStart,
    required this.courtSelectActiveBgEnd,
    required this.courtSelectActiveText,
    required this.courtSelectInactiveText,
    required this.waitingPanelBgStart,
    required this.waitingPanelBgEnd,
    required this.waitingPanelHeaderBg,
    required this.waitingPanelHeaderTitle,
    required this.waitingPanelSortBtnBg,
    required this.waitingPanelSortBtnBorder,
    required this.courtCardBgStart,
    required this.courtCardBgEnd,
    required this.courtCardText,
    required this.standbyZoneBgStart,
    required this.standbyZoneBgEnd,
    required this.standbyZoneBorder,
    required this.standbyZoneIcon,
    required this.btnAutoMatchStart,
    required this.btnAutoMatchEnd,
    required this.btnRemoveStart,
    required this.btnRemoveEnd,
    required this.btnFinishStart,
    required this.btnFinishEnd,
    required this.btnSwapStart,
    required this.btnSwapEnd,
    required this.btnRemoveCourtStart,
    required this.btnRemoveCourtEnd,
    required this.playerItemTextPrimary,
    required this.playerItemTextSecondary,
    required this.playerItemGenderText,
    required this.playerItemRateLabel,
    required this.playerItemDivider,
    required this.dropZoneEmptyBg,
    required this.dropZoneInactiveBg,
    required this.dropZoneActiveBg,
    required this.dropZoneHoverBg,
    required this.dropZoneBorder,
    required this.dropZoneCloseIcon,
  });

  @override
  CourtColors copyWith({
    Color? homeDivider,
    Color? courtSelectBg,
    Color? courtSelectActiveBgStart,
    Color? courtSelectActiveBgEnd,
    Color? courtSelectActiveText,
    Color? courtSelectInactiveText,
    Color? waitingPanelBgStart,
    Color? waitingPanelBgEnd,
    Color? waitingPanelHeaderBg,
    Color? waitingPanelHeaderTitle,
    Color? waitingPanelSortBtnBg,
    Color? waitingPanelSortBtnBorder,
    Color? courtCardBgStart,
    Color? courtCardBgEnd,
    Color? courtCardText,
    Color? standbyZoneBgStart,
    Color? standbyZoneBgEnd,
    Color? standbyZoneBorder,
    Color? standbyZoneIcon,
    Color? btnAutoMatchStart,
    Color? btnAutoMatchEnd,
    Color? btnRemoveStart,
    Color? btnRemoveEnd,
    Color? btnFinishStart,
    Color? btnFinishEnd,
    Color? btnSwapStart,
    Color? btnSwapEnd,
    Color? btnRemoveCourtStart,
    Color? btnRemoveCourtEnd,
    Color? playerItemTextPrimary,
    Color? playerItemTextSecondary,
    Color? playerItemGenderText,
    Color? playerItemRateLabel,
    Color? playerItemDivider,
    Color? dropZoneEmptyBg,
    Color? dropZoneInactiveBg,
    Color? dropZoneActiveBg,
    Color? dropZoneHoverBg,
    Color? dropZoneBorder,
    Color? dropZoneCloseIcon,
  }) {
    return CourtColors(
      homeDivider: homeDivider ?? this.homeDivider,
      courtSelectBg: courtSelectBg ?? this.courtSelectBg,
      courtSelectActiveBgStart: courtSelectActiveBgStart ?? this.courtSelectActiveBgStart,
      courtSelectActiveBgEnd: courtSelectActiveBgEnd ?? this.courtSelectActiveBgEnd,
      courtSelectActiveText: courtSelectActiveText ?? this.courtSelectActiveText,
      courtSelectInactiveText: courtSelectInactiveText ?? this.courtSelectInactiveText,
      waitingPanelBgStart: waitingPanelBgStart ?? this.waitingPanelBgStart,
      waitingPanelBgEnd: waitingPanelBgEnd ?? this.waitingPanelBgEnd,
      waitingPanelHeaderBg: waitingPanelHeaderBg ?? this.waitingPanelHeaderBg,
      waitingPanelHeaderTitle: waitingPanelHeaderTitle ?? this.waitingPanelHeaderTitle,
      waitingPanelSortBtnBg: waitingPanelSortBtnBg ?? this.waitingPanelSortBtnBg,
      waitingPanelSortBtnBorder: waitingPanelSortBtnBorder ?? this.waitingPanelSortBtnBorder,
      courtCardBgStart: courtCardBgStart ?? this.courtCardBgStart,
      courtCardBgEnd: courtCardBgEnd ?? this.courtCardBgEnd,
      courtCardText: courtCardText ?? this.courtCardText,
      standbyZoneBgStart: standbyZoneBgStart ?? this.standbyZoneBgStart,
      standbyZoneBgEnd: standbyZoneBgEnd ?? this.standbyZoneBgEnd,
      standbyZoneBorder: standbyZoneBorder ?? this.standbyZoneBorder,
      standbyZoneIcon: standbyZoneIcon ?? this.standbyZoneIcon,
      btnAutoMatchStart: btnAutoMatchStart ?? this.btnAutoMatchStart,
      btnAutoMatchEnd: btnAutoMatchEnd ?? this.btnAutoMatchEnd,
      btnRemoveStart: btnRemoveStart ?? this.btnRemoveStart,
      btnRemoveEnd: btnRemoveEnd ?? this.btnRemoveEnd,
      btnFinishStart: btnFinishStart ?? this.btnFinishStart,
      btnFinishEnd: btnFinishEnd ?? this.btnFinishEnd,
      btnSwapStart: btnSwapStart ?? this.btnSwapStart,
      btnSwapEnd: btnSwapEnd ?? this.btnSwapEnd,
      btnRemoveCourtStart: btnRemoveCourtStart ?? this.btnRemoveCourtStart,
      btnRemoveCourtEnd: btnRemoveCourtEnd ?? this.btnRemoveCourtEnd,
      playerItemTextPrimary: playerItemTextPrimary ?? this.playerItemTextPrimary,
      playerItemTextSecondary: playerItemTextSecondary ?? this.playerItemTextSecondary,
      playerItemGenderText: playerItemGenderText ?? this.playerItemGenderText,
      playerItemRateLabel: playerItemRateLabel ?? this.playerItemRateLabel,
      playerItemDivider: playerItemDivider ?? this.playerItemDivider,
      dropZoneEmptyBg: dropZoneEmptyBg ?? this.dropZoneEmptyBg,
      dropZoneInactiveBg: dropZoneInactiveBg ?? this.dropZoneInactiveBg,
      dropZoneActiveBg: dropZoneActiveBg ?? this.dropZoneActiveBg,
      dropZoneHoverBg: dropZoneHoverBg ?? this.dropZoneHoverBg,
      dropZoneBorder: dropZoneBorder ?? this.dropZoneBorder,
      dropZoneCloseIcon: dropZoneCloseIcon ?? this.dropZoneCloseIcon,
    );
  }

  @override
  CourtColors lerp(covariant CourtColors? other, double t) {
    if (other == null) {
      return this;
    }
    return CourtColors(
      homeDivider: Color.lerp(homeDivider, other.homeDivider, t)!,
      courtSelectBg: Color.lerp(courtSelectBg, other.courtSelectBg, t)!,
      courtSelectActiveBgStart: Color.lerp(courtSelectActiveBgStart, other.courtSelectActiveBgStart, t)!,
      courtSelectActiveBgEnd: Color.lerp(courtSelectActiveBgEnd, other.courtSelectActiveBgEnd, t)!,
      courtSelectActiveText: Color.lerp(courtSelectActiveText, other.courtSelectActiveText, t)!,
      courtSelectInactiveText: Color.lerp(courtSelectInactiveText, other.courtSelectInactiveText, t)!,
      waitingPanelBgStart: Color.lerp(waitingPanelBgStart, other.waitingPanelBgStart, t)!,
      waitingPanelBgEnd: Color.lerp(waitingPanelBgEnd, other.waitingPanelBgEnd, t)!,
      waitingPanelHeaderBg: Color.lerp(waitingPanelHeaderBg, other.waitingPanelHeaderBg, t)!,
      waitingPanelHeaderTitle: Color.lerp(waitingPanelHeaderTitle, other.waitingPanelHeaderTitle, t)!,
      waitingPanelSortBtnBg: Color.lerp(waitingPanelSortBtnBg, other.waitingPanelSortBtnBg, t)!,
      waitingPanelSortBtnBorder: Color.lerp(waitingPanelSortBtnBorder, other.waitingPanelSortBtnBorder, t)!,
      courtCardBgStart: Color.lerp(courtCardBgStart, other.courtCardBgStart, t)!,
      courtCardBgEnd: Color.lerp(courtCardBgEnd, other.courtCardBgEnd, t)!,
      courtCardText: Color.lerp(courtCardText, other.courtCardText, t)!,
      standbyZoneBgStart: Color.lerp(standbyZoneBgStart, other.standbyZoneBgStart, t)!,
      standbyZoneBgEnd: Color.lerp(standbyZoneBgEnd, other.standbyZoneBgEnd, t)!,
      standbyZoneBorder: Color.lerp(standbyZoneBorder, other.standbyZoneBorder, t)!,
      standbyZoneIcon: Color.lerp(standbyZoneIcon, other.standbyZoneIcon, t)!,
      btnAutoMatchStart: Color.lerp(btnAutoMatchStart, other.btnAutoMatchStart, t)!,
      btnAutoMatchEnd: Color.lerp(btnAutoMatchEnd, other.btnAutoMatchEnd, t)!,
      btnRemoveStart: Color.lerp(btnRemoveStart, other.btnRemoveStart, t)!,
      btnRemoveEnd: Color.lerp(btnRemoveEnd, other.btnRemoveEnd, t)!,
      btnFinishStart: Color.lerp(btnFinishStart, other.btnFinishStart, t)!,
      btnFinishEnd: Color.lerp(btnFinishEnd, other.btnFinishEnd, t)!,
      btnSwapStart: Color.lerp(btnSwapStart, other.btnSwapStart, t)!,
      btnSwapEnd: Color.lerp(btnSwapEnd, other.btnSwapEnd, t)!,
      btnRemoveCourtStart: Color.lerp(btnRemoveCourtStart, other.btnRemoveCourtStart, t)!,
      btnRemoveCourtEnd: Color.lerp(btnRemoveCourtEnd, other.btnRemoveCourtEnd, t)!,
      playerItemTextPrimary: Color.lerp(playerItemTextPrimary, other.playerItemTextPrimary, t)!,
      playerItemTextSecondary: Color.lerp(playerItemTextSecondary, other.playerItemTextSecondary, t)!,
      playerItemGenderText: Color.lerp(playerItemGenderText, other.playerItemGenderText, t)!,
      playerItemRateLabel: Color.lerp(playerItemRateLabel, other.playerItemRateLabel, t)!,
      playerItemDivider: Color.lerp(playerItemDivider, other.playerItemDivider, t)!,
      dropZoneEmptyBg: Color.lerp(dropZoneEmptyBg, other.dropZoneEmptyBg, t)!,
      dropZoneInactiveBg: Color.lerp(dropZoneInactiveBg, other.dropZoneInactiveBg, t)!,
      dropZoneActiveBg: Color.lerp(dropZoneActiveBg, other.dropZoneActiveBg, t)!,
      dropZoneHoverBg: Color.lerp(dropZoneHoverBg, other.dropZoneHoverBg, t)!,
      dropZoneBorder: Color.lerp(dropZoneBorder, other.dropZoneBorder, t)!,
      dropZoneCloseIcon: Color.lerp(dropZoneCloseIcon, other.dropZoneCloseIcon, t)!,
    );
  }
}
