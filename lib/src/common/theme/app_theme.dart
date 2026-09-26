import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 애플리케이션의 라이트 및 다크 테마 데이터를 구성하고 제공하는 유틸리티 클래스.
abstract final class AppTheme {
  /// 전달된 [brightness]에 따라 커스텀 색상 확장이 포함된 [ThemeData]를 생성하여 반환.
  static ThemeData buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB0E0E6),
      brightness: brightness,
    );

    final isDark = brightness == Brightness.dark;

    // ── 다크 모드 팔레트 (M3 Surface Elevation 표준 계층) ─────────
    // L0 (Background):  Slate-900 (#0F172A) 최하단 전체 배경
    // L1 (Surface):     Slate-800 (#1E293B) 대기 패널, 메인 컨텐츠 영역
    // L2 (Card/Raised): Slate-750 (#243248) 코트 카드, 패널 헤더
    // L3 (Slot/Active): Slate-700 (#2D3C54~#334460) 코트 내 플레이어 슬롯/카드
    // ──────────────────────────────────────────────────────────────
    const bgBase = Color(0xFF0F172A); // L0: 최하단 화면 배경
    const bgSurface = Color(0xFF1E293B); // L1: 대기 패널, 컨텐츠 베이스
    const bgRaised = Color(0xFF243248); // L2: 코트 카드, 엘리베이션 표면
    const bgHighest = Color(0xFF334460); // L3: 배치된 플레이어 카드, 모달 헤더
    const accent = Color(0xFF60A5FA); // Sky-400 (주 액센트)
    const accentDim = Color(0xFF93C5FD); // Sky-300 (보조 액센트)
    const textPri = Color(0xFFF8FAFC); // Slate-50 (최상급 명암비 본문 텍스트)
    const textSec = Color(0xFFCBD5E1); // Slate-300 (보조 텍스트)
    const border = Color(0xFF475569); // Slate-600 (선명한 경계선)

    final baseColors = BaseColors(
      gradientStart: isDark ? bgBase : const Color(0xFFF3E5F5),
      gradientEnd: isDark ? bgBase : const Color(0xFFE1F5FE),
      contentBg: isDark ? bgSurface : const Color(0xFFF5F5F5),
      menuIcon: isDark ? textPri : const Color(0xFF5D4037),
      cardBg: isDark ? bgSurface : Colors.white,
      cardShadow: isDark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.04),
      textPrimary: isDark ? textPri : Colors.black,
      primaryAccent: isDark ? accent : Colors.blueAccent,
      darkAccent: isDark ? accentDim : Colors.blueAccent.shade700,
      inactiveTrack: isDark
          ? accent.withValues(alpha: 0.25)
          : Colors.blue.withValues(alpha: 0.2),
      thumbColor: isDark ? Colors.white : Colors.white,
      cardBorderColor: isDark ? border : Colors.transparent,
      sliderIndicatorText: isDark ? textPri : Colors.white,
      textSecondary: isDark ? textSec : Colors.black54,
      navBarSelected: isDark ? accent : const Color(0xFF3E2723),
      navBarUnselected: isDark ? textSec : const Color(0xFF4E342E),
      navBarBg: isDark ? bgSurface : const Color(0xFFF3E5F5),
      navBarIndicator: isDark
          ? accent.withValues(alpha: 0.2)
          : const Color(0xFFD1C4E9),
    );

    final playerColors = PlayerColors(
      playerItemActiveStart: isDark ? bgHighest : const Color(0xFFE3F2FD),
      playerItemActiveEnd: isDark ? bgHighest : const Color(0xFFF3E5F5),
      playerItemInactive: isDark
          ? const Color(0xFF202A3B)
          : const Color(0x55333333),
      playerHeaderGradientStart: isDark ? bgHighest : const Color(0xFFE0C3FC),
      playerHeaderGradientEnd: isDark ? bgHighest : const Color(0xFF8EC5FC),
      playerHeaderFg: isDark ? textPri : Colors.black87,
      playerHeaderFgVariant: isDark ? textSec : Colors.black54,
      playerSearchBg: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.white.withValues(alpha: 0.8),
      chipBg: isDark ? bgRaised : const Color(0xFFF9FAFB),
      playerInputFill: isDark ? bgRaised : const Color(0xFFFAFAFA),
      managerToggleActiveBg: isDark
          ? Colors.orange.withValues(alpha: 0.18)
          : const Color(0xFFFFF3E0),
      managerToggleInactiveBg: isDark ? bgRaised : const Color(0xFFFAFAFA),
      infoTagBg: isDark ? bgRaised : Colors.white,
      rateWidgetLabel: isDark ? textSec : Colors.black54,
      rateWidgetValue: isDark ? textPri : Colors.black87,
      rateWidgetSkill: isDark ? accent : Colors.blueAccent.shade700,
      roleManager: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      roleUser: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
      roleGuest: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      genderTag: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
    );

    final formColors = FormColors(
      filterDivider: isDark ? border : const Color(0xFFE5E7EB),
      filterTabActiveText: isDark ? textPri : Colors.black87,
      filterTabInactiveText: isDark ? textSec : Colors.black45,
      filterTabIndicator: isDark ? accent : const Color(0xFF2563EB),
      filterChipActiveBg: isDark ? accent : const Color(0xFF2563EB),
      filterChipInactiveBg: isDark ? bgRaised : const Color(0xFFF9FAFB),
      filterChipActiveText: isDark ? bgBase : Colors.white,
      filterChipInactiveText: isDark ? textSec : const Color(0xFF6B7280),
      editFormBg: isDark ? bgSurface : Colors.white.withValues(alpha: 0.9),
      editFormBorder: isDark
          ? border
          : Colors.blue.withValues(alpha: 0.1),
      editFormShadow: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.blue.withValues(alpha: 0.05),
      inputBorder: isDark ? border : Colors.grey.shade300,
      inputFocusBorder: isDark ? accent : Colors.blue,
      managerToggleActiveBorder: isDark
          ? Colors.orange.shade400
          : Colors.orange.withValues(alpha: 0.3),
      managerToggleInactiveBorder: isDark
          ? border
          : Colors.grey.withValues(alpha: 0.1),
      managerToggleInactiveText: isDark ? textSec : Colors.grey,
      genderActiveBg: isDark
          ? accent.withValues(alpha: 0.18)
          : Colors.blue.withValues(alpha: 0.1),
      genderActiveBorder: isDark
          ? accent.withValues(alpha: 0.5)
          : Colors.blue.withValues(alpha: 0.4),
      genderInactiveBg: isDark ? bgRaised : Colors.grey.shade50,
      genderInactiveText: isDark ? textSec : Colors.grey,
      genderActiveText: isDark ? accent : Colors.blue.shade900,
      skillChipActiveBg: isDark
          ? accent.withValues(alpha: 0.22)
          : Colors.blue.shade100,
      skillChipCheckmark: isDark ? accent : Colors.blue.shade900,
      skillChipActiveText: isDark ? accent : Colors.blue.shade900,
      stepperBg: isDark
          ? bgRaised
          : Colors.blue.shade50.withValues(alpha: 0.5),
      stepperLabelText: isDark ? textSec : Colors.blueGrey,
      stepperValueText: isDark ? accent : Colors.blue,
      stepperBtnBg: isDark ? bgHighest : Colors.white,
      stepperBtnIcon: isDark ? accent : Colors.blue,
      footerCancelText: isDark ? textSec : Colors.grey,
      footerSubmitBg: isDark ? accent : Colors.blue,
      footerSubmitText: isDark ? bgBase : Colors.white,
      footerSubmitShadow: isDark
          ? accent.withValues(alpha: 0.35)
          : Colors.blue.withValues(alpha: 0.4),
    );

    final courtColors = CourtColors(
      homeDivider: isDark ? border : Colors.grey,
      courtSelectBg: isDark ? bgRaised : Colors.grey.shade200,
      courtSelectActiveBgStart: isDark
          ? accent.withValues(alpha: 0.25)
          : const Color(0xFFFCE4EC),
      courtSelectActiveBgEnd: isDark
          ? accent.withValues(alpha: 0.25)
          : const Color(0xFFF8BBD0),
      courtSelectActiveText: isDark ? accentDim : Colors.black87,
      courtSelectInactiveText: isDark ? textSec : Colors.grey.shade600,
      waitingPanelBgStart: isDark ? bgSurface : const Color(0xFFF8FAFC),
      waitingPanelBgEnd: isDark ? bgSurface : const Color(0xFFF1F5F9),
      waitingPanelHeaderBg: isDark ? bgRaised : Colors.white,
      waitingPanelHeaderTitle: isDark ? textPri : Colors.black,
      waitingPanelSortBtnBg: isDark
          ? accent.withValues(alpha: 0.16)
          : const Color(0xFFE3F2FD),
      waitingPanelSortBtnBorder: isDark
          ? accent.withValues(alpha: 0.4)
          : const Color(0xFFBBDEFB),
      // --- 코트 카드 (L2: 배경 위에 떠있는 카드) ---
      courtCardBgStart: isDark
          ? const Color(0xFF243248)
          : const Color(0xFFECFDF5),
      courtCardBgEnd: isDark
          ? const Color(0xFF243248)
          : const Color(0xFFECFDF5),
      courtCardText: isDark ? const Color(0xFF93C5FD) : const Color(0xFF065F46),
      // --- 대기 존 ---
      standbyZoneBgStart: isDark
          ? const Color(0xFF2D263D)
          : const Color(0xFFFEF3C7),
      standbyZoneBgEnd: isDark
          ? const Color(0xFF2D263D)
          : const Color(0xFFFDE68A),
      standbyZoneBorder: isDark ? border : Colors.white,
      standbyZoneIcon: isDark
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706),
      // 버튼들 — 600~700 계열 명도/채도 확보
      btnAutoMatchStart: isDark
          ? const Color(0xFF15803D)
          : const Color(0xFF86EFAC),
      btnAutoMatchEnd: isDark
          ? const Color(0xFF16A34A)
          : const Color(0xFF4ADE80),
      btnRemoveStart: isDark
          ? const Color(0xFFB91C1C)
          : const Color(0xFFEF9A9A),
      btnRemoveEnd: isDark ? const Color(0xFFDC2626) : const Color(0xFFE57373),
      btnFinishStart: isDark
          ? const Color(0xFFC2410C)
          : const Color(0xFFFFB74D),
      btnFinishEnd: isDark ? const Color(0xFFEA580C) : const Color(0xFFE57373),
      btnSwapStart: isDark ? const Color(0xFF1D4ED8) : const Color(0xFF64B5F6),
      btnSwapEnd: isDark ? const Color(0xFF2563EB) : const Color(0xFF2196F3),
      btnRemoveCourtStart: isDark
          ? const Color(0xFFB45309)
          : const Color(0xFFFDBA74),
      btnRemoveCourtEnd: isDark
          ? const Color(0xFFD97706)
          : const Color(0xFFFB923C),
      playerItemTextPrimary: isDark ? textPri : const Color(0xFF1E293B),
      playerItemTextSecondary: isDark ? textSec : const Color(0xFF64748B),
      playerItemGenderText: isDark ? accentDim : Colors.blueAccent.shade700,
      playerItemRateLabel: isDark ? textSec : Colors.black54,
      playerItemDivider: isDark ? border : Colors.grey.shade300,
      // --- 코트 내 플레이어 칸 (L3: 코트 카드 내부 슬롯은 어두운 구멍이 아닌 자연스러운 슬롯 표면) ---
      dropZoneEmptyBg: isDark
          ? const Color(0xFF2D3C54) // 코트 카드(0xFF243248)보다 한 단계 올라온 밝은 빈 슬롯
          : const Color(0xFFF8FAFC),
      dropZoneInactiveBg: isDark
          ? const Color(0xFF202A3B) // 비활성 슬롯은 카드와 자연스럽게 어우러지는 톤
          : const Color(0xFFCBD5E1).withValues(alpha: 0.47),
      dropZoneActiveBg: isDark
          ? const Color(0xFF334460) // 플레이어가 배치된 활성 카드 (L3)
          : const Color(0xFFFFFFFF),
      dropZoneHoverBg: isDark
          ? const Color(0xFF3B4E6E) // 호버 피드백 (가장 밝은 하이라이트)
          : const Color(0xFFE2E8F0),
      dropZoneBorder: isDark
          ? const Color(0xFF4A5B75) // 슬롯 테두리
          : const Color(0xFFE2E8F0),
      dropZoneCloseIcon: isDark ? textSec : const Color(0xFF94A3B8),
    );

    final dialogColors = DialogColors(
      dialogTitleBgStart: isDark ? bgRaised : const Color(0xFFE3F2FD),
      dialogTitleBgEnd: isDark ? bgRaised : const Color(0xFFBBDEFB),
      dialogTitleManagerBgStart: isDark
          ? Colors.orange.withValues(alpha: 0.18)
          : const Color(0xFFFFF9C4),
      dialogTitleManagerBgEnd: isDark
          ? Colors.orange.withValues(alpha: 0.18)
          : const Color(0xFFFFE082),
      dialogButtonCancelText: isDark ? textSec : Colors.grey.shade700,
      dialogButtonConfirmBg: isDark ? accent : const Color(0xFFBBDEFB),
      dialogButtonConfirmText: isDark ? bgBase : Colors.blue.shade900,
      dialogSummaryBg: isDark ? bgBase : const Color(0xFFF8FAFC),
      dialogSummaryBorder: isDark ? border : const Color(0xFFE2E8F0),
    );

    // 글로벌 텍스트 테마 적용
    final baseTextTheme = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [
        baseColors,
        playerColors,
        formColors,
        courtColors,
        dialogColors,
      ],
      textTheme: baseTextTheme.apply(
        bodyColor: isDark ? Colors.white : Colors.black,
        displayColor: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  static ThemeData get light => buildTheme(Brightness.light);
  static ThemeData get dark => buildTheme(Brightness.dark);
}
