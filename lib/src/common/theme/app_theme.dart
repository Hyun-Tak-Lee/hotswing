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
    const _bgBase = Color(0xFF0F172A); // slate-900  (최하층 배경)
    const _bgSurface = Color(0xFF1E293B); // slate-800  (카드·드로어)
    const _bgRaised = Color(0xFF273549); // slate-700+ (떠있는 컴포넌트)
    const _bgHighest = Color(0xFF2D3F57); // slate-600+ (최상층 엘리베이션)
    const _accent = Color(0xFF60A5FA); // sky-400     (주 액센트)
    const _accentDim = Color(0xFF38BDF8); // sky-300     (보조 액센트)
    const _textPri = Color(0xFFF1F5F9); // slate-100   (본문 텍스트)
    const _textSec = Color(0xFF94A3B8); // slate-400   (보조 텍스트)
    const _border = Color(0xFF334155); // slate-700   (경계선)

    final baseColors = BaseColors(
      gradientStart: isDark ? _bgBase : const Color(0xFFF3E5F5),
      gradientEnd: isDark ? _bgBase : const Color(0xFFE1F5FE),
      contentBg: isDark ? _bgSurface : const Color(0xFFF5F5F5),
      menuIcon: isDark ? _textPri : const Color(0xFF5D4037),
      cardBg: isDark ? _bgSurface : Colors.white,
      cardShadow: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.04),
      textPrimary: isDark ? _textPri : Colors.black,
      primaryAccent: isDark ? _accent : Colors.blueAccent,
      darkAccent: isDark ? _accentDim : Colors.blueAccent.shade700,
      inactiveTrack: isDark
          ? _accent.withValues(alpha: 0.2)
          : Colors.blue.withValues(alpha: 0.2),
      thumbColor: isDark ? Colors.white : Colors.white,
      cardBorderColor: isDark
          ? _border.withValues(alpha: 0.6)
          : Colors.transparent,
      sliderIndicatorText: isDark ? _textPri : Colors.white,
      textSecondary: isDark ? _textSec : Colors.black54,
      navBarSelected: isDark ? _accent : const Color(0xFF3E2723),
      navBarUnselected: isDark ? _textSec : const Color(0xFF4E342E),
      navBarBg: isDark ? _bgSurface : const Color(0xFFF3E5F5),
      navBarIndicator: isDark
          ? _accent.withValues(alpha: 0.15)
          : const Color(0xFFD1C4E9),
    );

    final playerColors = PlayerColors(
      playerItemActiveStart: isDark ? _bgRaised : const Color(0xFFE3F2FD),
      playerItemActiveEnd: isDark ? _bgRaised : const Color(0xFFF3E5F5),
      playerItemInactive: isDark
          ? _bgSurface.withValues(alpha: 0.5)
          : const Color(0x55333333),
      playerHeaderGradientStart: isDark ? _bgHighest : const Color(0xFFE0C3FC),
      playerHeaderGradientEnd: isDark ? _bgHighest : const Color(0xFF8EC5FC),
      playerHeaderFg: isDark ? _textPri : Colors.black87,
      playerHeaderFgVariant: isDark ? _textSec : Colors.black54,
      playerSearchBg: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.8),
      chipBg: isDark ? _bgRaised : const Color(0xFFF9FAFB),
      playerInputFill: isDark ? _bgRaised : const Color(0xFFFAFAFA),
      managerToggleActiveBg: isDark
          ? Colors.orange.withValues(alpha: 0.12)
          : const Color(0xFFFFF3E0),
      managerToggleInactiveBg: isDark ? _bgRaised : const Color(0xFFFAFAFA),
      infoTagBg: isDark ? _bgRaised : Colors.white,
      rateWidgetLabel: isDark ? _textSec : Colors.black54,
      rateWidgetValue: isDark ? _textPri : Colors.black87,
      rateWidgetSkill: isDark ? _accent : Colors.blueAccent.shade700,
      roleManager: isDark ? Colors.orange.shade300 : Colors.orange,
      roleUser: isDark ? Colors.green.shade300 : Colors.green,
      roleGuest: isDark ? const Color(0xFF64748B) : Colors.grey,
      genderTag: isDark ? const Color(0xFF818CF8) : Colors.indigoAccent,
    );

    final formColors = FormColors(
      filterDivider: isDark ? _border : const Color(0xFFE5E7EB),
      filterTabActiveText: isDark ? _textPri : Colors.black87,
      filterTabInactiveText: isDark ? _textSec : Colors.black45,
      filterTabIndicator: isDark ? _accent : const Color(0xFF2563EB),
      filterChipActiveBg: isDark ? _accent : const Color(0xFF2563EB),
      filterChipInactiveBg: isDark ? _bgRaised : const Color(0xFFF9FAFB),
      filterChipActiveText: isDark ? _bgBase : Colors.white,
      filterChipInactiveText: isDark ? _textSec : const Color(0xFF6B7280),
      editFormBg: isDark ? _bgSurface : Colors.white.withValues(alpha: 0.9),
      editFormBorder: isDark
          ? _border.withValues(alpha: 0.5)
          : Colors.blue.withValues(alpha: 0.1),
      editFormShadow: isDark
          ? Colors.black.withValues(alpha: 0.2)
          : Colors.blue.withValues(alpha: 0.05),
      inputBorder: isDark ? _border : Colors.grey.shade300,
      inputFocusBorder: isDark ? _accent : Colors.blue,
      managerToggleActiveBorder: isDark
          ? Colors.orange.withValues(alpha: 0.5)
          : Colors.orange.withValues(alpha: 0.3),
      managerToggleInactiveBorder: isDark
          ? _border.withValues(alpha: 0.4)
          : Colors.grey.withValues(alpha: 0.1),
      managerToggleInactiveText: isDark ? _textSec : Colors.grey,
      genderActiveBg: isDark
          ? _accent.withValues(alpha: 0.12)
          : Colors.blue.withValues(alpha: 0.1),
      genderActiveBorder: isDark
          ? _accent.withValues(alpha: 0.4)
          : Colors.blue.withValues(alpha: 0.4),
      genderInactiveBg: isDark ? _bgRaised : Colors.grey.shade50,
      genderInactiveText: isDark ? _textSec : Colors.grey,
      genderActiveText: isDark ? _accent : Colors.blue.shade900,
      skillChipActiveBg: isDark
          ? _accent.withValues(alpha: 0.18)
          : Colors.blue.shade100,
      skillChipCheckmark: isDark ? _accent : Colors.blue.shade900,
      skillChipActiveText: isDark ? _accent : Colors.blue.shade900,
      stepperBg: isDark
          ? _bgRaised
          : Colors.blue.shade50.withValues(alpha: 0.5),
      stepperLabelText: isDark ? _textSec : Colors.blueGrey,
      stepperValueText: isDark ? _accent : Colors.blue,
      stepperBtnBg: isDark ? _bgHighest : Colors.white,
      stepperBtnIcon: isDark ? _accent : Colors.blue,
      footerCancelText: isDark ? _textSec : Colors.grey,
      footerSubmitBg: isDark ? _accent : Colors.blue,
      footerSubmitText: isDark ? _bgBase : Colors.white,
      footerSubmitShadow: isDark
          ? _accent.withValues(alpha: 0.35)
          : Colors.blue.withValues(alpha: 0.4),
    );

    final courtColors = CourtColors(
      homeDivider: isDark ? _border : Colors.grey,
      courtSelectBg: isDark ? _bgRaised : Colors.grey.shade200,
      courtSelectActiveBgStart: isDark
          ? _accent.withValues(alpha: 0.2)
          : const Color(0xFFFCE4EC),
      courtSelectActiveBgEnd: isDark
          ? _accent.withValues(alpha: 0.2)
          : const Color(0xFFF8BBD0),
      courtSelectActiveText: isDark ? _accent : Colors.black87,
      courtSelectInactiveText: isDark ? _textSec : Colors.grey.shade600,
      waitingPanelBgStart: isDark ? _bgSurface : const Color(0xFFF8FAFC),
      waitingPanelBgEnd: isDark ? _bgSurface : const Color(0xFFF1F5F9),
      waitingPanelHeaderBg: isDark ? _bgRaised : Colors.white,
      waitingPanelHeaderTitle: isDark ? _textPri : Colors.black,
      waitingPanelSortBtnBg: isDark
          ? _accent.withValues(alpha: 0.12)
          : const Color(0xFFE3F2FD),
      waitingPanelSortBtnBorder: isDark
          ? _accent.withValues(alpha: 0.3)
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
      standbyZoneBorder: isDark ? _border : Colors.white,
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
      playerItemTextPrimary: isDark ? _textPri : const Color(0xFF1E293B),
      playerItemTextSecondary: isDark ? _textSec : const Color(0xFF64748B),
      playerItemGenderText: isDark ? _accentDim : Colors.blueAccent.shade700,
      playerItemRateLabel: isDark ? _textSec : Colors.black54,
      playerItemDivider: isDark ? _border : Colors.grey.shade300,
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
      dropZoneCloseIcon: isDark ? _textSec : const Color(0xFF94A3B8),
    );

    final dialogColors = DialogColors(
      dialogTitleBgStart: isDark ? _bgRaised : const Color(0xFFE3F2FD),
      dialogTitleBgEnd: isDark ? _bgRaised : const Color(0xFFBBDEFB),
      dialogTitleManagerBgStart: isDark
          ? Colors.orange.withValues(alpha: 0.15)
          : const Color(0xFFFFF9C4),
      dialogTitleManagerBgEnd: isDark
          ? Colors.orange.withValues(alpha: 0.15)
          : const Color(0xFFFFE082),
      dialogButtonCancelText: isDark ? _textSec : Colors.grey.shade700,
      dialogButtonConfirmBg: isDark ? _accent : const Color(0xFFBBDEFB),
      dialogButtonConfirmText: isDark ? _bgBase : Colors.blue.shade900,
      dialogSummaryBg: isDark ? _bgBase : const Color(0xFFF8FAFC),
      dialogSummaryBorder: isDark ? _border : const Color(0xFFE2E8F0),
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
