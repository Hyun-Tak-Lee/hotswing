import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB0E0E6),
      brightness: brightness,
    );

    final isDark = brightness == Brightness.dark;

    // ── 다크 모드 팔레트 ─────────────────────────────────────────
    // Base layer: Deep Navy Slate (Tailwind slate-900~800 계열)
    // Accent:     Sky Blue 400 (#60A5FA) — 가독성·눈 편안함 최우선
    // ──────────────────────────────────────────────────────────────
    const bgBase = Color(0xFF0F172A); // slate-900  (최하층 배경)
    const bgSurface = Color(0xFF1E293B); // slate-800  (카드·드로어)
    const bgRaised = Color(0xFF273549); // slate-700+ (떠있는 컴포넌트)
    const bgHighest = Color(0xFF2D3F57); // slate-600+ (최상층 엘리베이션)
    const accent = Color(0xFF60A5FA); // sky-400     (주 액센트)
    const accentDim = Color(0xFF38BDF8); // sky-300     (보조 액센트)
    const textPri = Color(0xFFF1F5F9); // slate-100   (본문 텍스트)
    const textSec = Color(0xFF94A3B8); // slate-400   (보조 텍스트)
    const border = Color(0xFF334155); // slate-700   (경계선)

    final baseColors = BaseColors(
      gradientStart: isDark ? bgBase : const Color(0xFFF3E5F5),
      gradientEnd: isDark ? bgBase : const Color(0xFFE1F5FE),
      contentBg: isDark ? bgSurface : const Color(0xFFF5F5F5),
      menuIcon: isDark ? textPri : const Color(0xFF5D4037),
      cardBg: isDark ? bgSurface : Colors.white,
      cardShadow: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.04),
      textPrimary: isDark ? textPri : Colors.black,
      primaryAccent: isDark ? accent : Colors.blueAccent,
      darkAccent: isDark ? accentDim : Colors.blueAccent.shade700,
      inactiveTrack: isDark
          ? accent.withValues(alpha: 0.2)
          : Colors.blue.withValues(alpha: 0.2),
      thumbColor: isDark ? Colors.white : Colors.white,
      cardBorderColor: isDark
          ? border.withValues(alpha: 0.6)
          : Colors.transparent,
      sliderIndicatorText: isDark ? textPri : Colors.white,
      textSecondary: isDark ? textSec : Colors.black54,
      navBarSelected: isDark ? accent : const Color(0xFF3E2723),
      navBarUnselected: isDark ? textSec : const Color(0xFF4E342E),
      navBarBg: isDark ? bgSurface : const Color(0xFFF3E5F5),
      navBarIndicator: isDark
          ? accent.withValues(alpha: 0.15)
          : const Color(0xFFD1C4E9),
    );

    final playerColors = PlayerColors(
      playerItemActiveStart: isDark ? bgRaised : const Color(0xFFE3F2FD),
      playerItemActiveEnd: isDark ? bgRaised : const Color(0xFFF3E5F5),
      playerItemInactive: isDark
          ? bgSurface.withValues(alpha: 0.5)
          : const Color(0x55333333),
      playerHeaderGradientStart: isDark ? bgHighest : const Color(0xFFE0C3FC),
      playerHeaderGradientEnd: isDark ? bgHighest : const Color(0xFF8EC5FC),
      playerHeaderFg: isDark ? textPri : Colors.black87,
      playerHeaderFgVariant: isDark ? textSec : Colors.black54,
      playerSearchBg: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.8),
      chipBg: isDark ? bgRaised : const Color(0xFFF9FAFB),
      playerInputFill: isDark ? bgRaised : const Color(0xFFFAFAFA),
      managerToggleActiveBg: isDark
          ? Colors.orange.withValues(alpha: 0.12)
          : const Color(0xFFFFF3E0),
      managerToggleInactiveBg: isDark ? bgRaised : const Color(0xFFFAFAFA),
      infoTagBg: isDark ? bgRaised : Colors.white,
      rateWidgetLabel: isDark ? textSec : Colors.black54,
      rateWidgetValue: isDark ? textPri : Colors.black87,
      rateWidgetSkill: isDark ? accent : Colors.blueAccent.shade700,
      roleManager: isDark ? Colors.orange.shade300 : Colors.orange,
      roleUser: isDark ? Colors.green.shade300 : Colors.green,
      roleGuest: isDark ? const Color(0xFF64748B) : Colors.grey,
      genderTag: isDark ? const Color(0xFF818CF8) : Colors.indigoAccent,
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
          ? border.withValues(alpha: 0.5)
          : Colors.blue.withValues(alpha: 0.1),
      editFormShadow: isDark
          ? Colors.black.withValues(alpha: 0.2)
          : Colors.blue.withValues(alpha: 0.05),
      inputBorder: isDark ? border : Colors.grey.shade300,
      inputFocusBorder: isDark ? accent : Colors.blue,
      managerToggleActiveBorder: isDark
          ? Colors.orange.withValues(alpha: 0.5)
          : Colors.orange.withValues(alpha: 0.3),
      managerToggleInactiveBorder: isDark
          ? border.withValues(alpha: 0.4)
          : Colors.grey.withValues(alpha: 0.1),
      managerToggleInactiveText: isDark ? textSec : Colors.grey,
      genderActiveBg: isDark
          ? accent.withValues(alpha: 0.12)
          : Colors.blue.withValues(alpha: 0.1),
      genderActiveBorder: isDark
          ? accent.withValues(alpha: 0.4)
          : Colors.blue.withValues(alpha: 0.4),
      genderInactiveBg: isDark ? bgRaised : Colors.grey.shade50,
      genderInactiveText: isDark ? textSec : Colors.grey,
      genderActiveText: isDark ? accent : Colors.blue.shade900,
      skillChipActiveBg: isDark
          ? accent.withValues(alpha: 0.18)
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
          ? accent.withValues(alpha: 0.2)
          : const Color(0xFFFCE4EC),
      courtSelectActiveBgEnd: isDark
          ? accent.withValues(alpha: 0.2)
          : const Color(0xFFF8BBD0),
      courtSelectActiveText: isDark ? accent : Colors.black87,
      courtSelectInactiveText: isDark ? textSec : Colors.grey.shade600,
      waitingPanelBgStart: isDark ? bgSurface : const Color(0xFFF8FAFC),
      waitingPanelBgEnd: isDark ? bgSurface : const Color(0xFFF1F5F9),
      waitingPanelHeaderBg: isDark ? bgRaised : Colors.white,
      waitingPanelHeaderTitle: isDark ? textPri : Colors.black,
      waitingPanelSortBtnBg: isDark
          ? accent.withValues(alpha: 0.12)
          : const Color(0xFFE3F2FD),
      waitingPanelSortBtnBorder: isDark
          ? accent.withValues(alpha: 0.3)
          : const Color(0xFFBBDEFB),
      // --- 코트 카드  ---
      courtCardBgStart: isDark
          ? const Color(0xFF283854)
          : const Color(0xFFECFDF5),
      courtCardBgEnd: isDark
          ? const Color(0xFF283854)
          : const Color(0xFFECFDF5),
      courtCardText: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF065F46),
      // --- 대기 존  ---
      standbyZoneBgStart: isDark
          ? const Color(0xFF2A1E35)
          : const Color(0xFFFEF3C7),
      standbyZoneBgEnd: isDark
          ? const Color(0xFF2A1E35)
          : const Color(0xFFFDE68A),
      standbyZoneBorder: isDark ? border : Colors.white,
      standbyZoneIcon: isDark
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706),
      // 버튼들 — 다크에서 채도 낮추고 단색화
      btnAutoMatchStart: isDark
          ? const Color(0xFF14532D)
          : const Color(0xFF86EFAC),
      btnAutoMatchEnd: isDark
          ? const Color(0xFF14532D)
          : const Color(0xFF4ADE80),
      btnRemoveStart: isDark
          ? const Color(0xFF7F1D1D)
          : const Color(0xFFEF9A9A),
      btnRemoveEnd: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFE57373),
      btnFinishStart: isDark
          ? const Color(0xFF7C2D12)
          : const Color(0xFFFFB74D),
      btnFinishEnd: isDark ? const Color(0xFF7C2D12) : const Color(0xFFE57373),
      btnSwapStart: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF64B5F6),
      btnSwapEnd: isDark ? const Color(0xFF1E3A8A) : const Color(0xFF2196F3),
      btnRemoveCourtStart: isDark
          ? const Color(0xFF9A3412)
          : const Color(0xFFFDBA74),
      btnRemoveCourtEnd: isDark
          ? const Color(0xFF9A3412)
          : const Color(0xFFFB923C),
      playerItemTextPrimary: isDark ? textPri : const Color(0xFF1E293B),
      playerItemTextSecondary: isDark ? textSec : const Color(0xFF64748B),
      playerItemGenderText: isDark ? accentDim : Colors.blueAccent.shade700,
      playerItemRateLabel: isDark ? textSec : Colors.black54,
      playerItemDivider: isDark ? border : Colors.grey.shade300,
      dropZoneEmptyBg: isDark
          ? const Color(0xFF121623) // 깊이감 있는 어두운 네이비
          : const Color(0xFFF8FAFC),
      dropZoneInactiveBg: isDark
          ? const Color(0xFF0A0D14).withValues(alpha: 0.6) // 더 깊은 배경
          : const Color(0xFFCBD5E1).withValues(alpha: 0.47),
      dropZoneActiveBg: isDark
          ? const Color(0xFF1A2235) // 활성: 은은하게 빛이 도는 인디고
          : const Color(0xFFFFFFFF),
      dropZoneHoverBg: isDark
          ? const Color(0xFF253047) // 호버: 명확하지만 눈부시지 않은 밝기
          : const Color(0xFFE2E8F0),
      dropZoneBorder: isDark
          ? const Color(0xFF2D3A54) // 경계선: 배경과 어우러지는 블루 그레이
          : const Color(0xFFE2E8F0),
      dropZoneCloseIcon: isDark ? textSec : const Color(0xFF94A3B8),
    );

    final dialogColors = DialogColors(
      dialogTitleBgStart: isDark ? bgRaised : const Color(0xFFE3F2FD),
      dialogTitleBgEnd: isDark ? bgRaised : const Color(0xFFBBDEFB),
      dialogTitleManagerBgStart: isDark
          ? Colors.orange.withValues(alpha: 0.15)
          : const Color(0xFFFFF9C4),
      dialogTitleManagerBgEnd: isDark
          ? Colors.orange.withValues(alpha: 0.15)
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
