import 'package:flutter/material.dart';
import 'app_colors.dart';

/// 애플리케이션의 라이트 및 다크 테마 데이터를 구성하고 제공하는 유틸리티 클래스.
abstract final class AppTheme {
  /// 전달된 [brightness]에 따라 커스텀 색상 확장이 포함된 [ThemeData]를 생성하여 반환.
  static ThemeData buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF059669),
      brightness: brightness,
    );

    final isDark = brightness == Brightness.dark;

    // ── 다크 모드 팔레트 (M3 Surface Elevation 표준 계층) ─────────
    // L0 (Background):  Slate-900 (#0F172A) 최하단 전체 배경
    // L1 (Surface):     Slate-800 (#1E293B) 대기 패널, 메인 컨텐츠 영역
    // L2 (Card/Raised): Slate-750 (#243248) 코트 카드, 패널 헤더
    // L3 (Slot/Active): Slate-700 (#2D3C54~#334460) 코트 내 플레이어 슬롯/카드
    // ──────────────────────────────────────────────────────────────
    const darkBgBase = Color(0xFF0F172A); // L0: 최하단 화면 배경
    const darkBgSurface = Color(0xFF1E293B); // L1: 대기 패널, 컨텐츠 베이스
    const darkBgRaised = Color(0xFF243248); // L2: 코트 카드, 엘리베이션 표면
    const darkBgHighest = Color(0xFF334460); // L3: 배치된 플레이어 카드, 모달 헤더
    const darkAccent = Color(0xFF60A5FA); // Sky-400 (주 액센트)
    const darkAccentDim = Color(0xFF93C5FD); // Sky-300 (보조 액센트)
    const darkTextPri = Color(0xFFF8FAFC); // Slate-50 (최상급 명암비 본문 텍스트)
    const darkTextSec = Color(0xFFCBD5E1); // Slate-300 (보조 텍스트)
    const darkBorder = Color(0xFF475569); // Slate-600 (선명한 경계선)

    // ── 라이트 모드 팔레트 (맑은 베이스 + 연녹색 & 버터 옐로우 조화) ────
    // Base:      맑고 산뜻한 소프트 화이트 (#F6F9F7 / #FFFFFF)
    // Court:     싱그럽고 눈이 편안한 연한 녹색 (#ECFDF5 ~ #D1FAE5)
    // Standby:   따뜻하고 활력 있는 버터 옐로우 (#FFFBEB ~ #FEF3C7)
    // Accent:    경쾌한 에메랄드 (#059669) & 따뜻한 앰버 (#D97706)
    // Text:      선명하고 쨍한 Slate 차콜 (#0F172A)로 완벽한 가독성 확보
    // ──────────────────────────────────────────────────────────────
    const lightBgBase = Color(0xFFF6F9F7); // L0: 맑고 은은한 라이트 배경
    const lightBgSurface = Color(0xFFFFFFFF); // L1: 대기 패널, 메인 컨텐츠 영역
    const lightBgRaised = Color(0xFFFFFFFF); // L2: 카드/다이얼로그 Pure White
    const lightBgSlot = Color(0xFFF1F7F3); // L3: 내부 빈 슬롯 베이스
    const lightAccent = Color(0xFF059669); // Emerald Green (산뜻하고 눈 편안한 메인)
    const lightAccentDim = Color(0xFF047857); // Deep Emerald
    const lightTextPri = Color(0xFF0F172A); // Slate-900 (또렷하고 선명한 최고 가독성)
    const lightTextSec = Color(0xFF475569); // Slate-600 (안정적인 보조 텍스트)
    const lightBorder = Color(0xFFE2E8F0); // 세련되고 정돈된 보더

    final baseColors = BaseColors(
      gradientStart: isDark ? darkBgBase : const Color(0xFFF6F9F7),
      gradientEnd: isDark ? darkBgBase : const Color(0xFFEDF5F0),
      contentBg: isDark ? darkBgSurface : const Color(0xFFFFFFFF),
      menuIcon: isDark ? darkTextPri : lightTextPri,
      cardBg: isDark ? darkBgSurface : lightBgRaised,
      cardShadow: isDark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.05),
      textPrimary: isDark ? darkTextPri : lightTextPri,
      primaryAccent: isDark ? darkAccent : lightAccent,
      darkAccent: isDark ? darkAccentDim : lightAccentDim,
      inactiveTrack: isDark
          ? darkAccent.withValues(alpha: 0.25)
          : lightAccent.withValues(alpha: 0.2),
      thumbColor: Colors.white,
      cardBorderColor: isDark ? darkBorder : lightBorder,
      sliderIndicatorText: Colors.white,
      textSecondary: isDark ? darkTextSec : lightTextSec,
      navBarSelected: isDark ? darkAccent : lightAccent,
      navBarUnselected: isDark ? darkTextSec : const Color(0xFF64748B),
      navBarBg: isDark ? darkBgSurface : lightBgRaised,
      navBarIndicator: isDark
          ? darkAccent.withValues(alpha: 0.2)
          : const Color(0xFFD1FAE5),
    );

    final playerColors = PlayerColors(
      playerItemActiveStart: isDark ? darkBgHighest : const Color(0xFFFFFFFF),
      playerItemActiveEnd: isDark ? darkBgHighest : const Color(0xFFF8FAF9),
      playerItemInactive: isDark
          ? const Color(0xFF202A3B)
          : const Color(0xFFE2E8F0),
      playerHeaderGradientStart: isDark
          ? darkBgHighest
          : const Color(0xFFD1FAE5), // 연한 녹색
      playerHeaderGradientEnd: isDark
          ? darkBgHighest
          : const Color(0xFFFEF3C7), // 버터 옐로우
      playerHeaderFg: isDark ? darkTextPri : lightTextPri,
      playerHeaderFgVariant: isDark ? darkTextSec : lightTextSec,
      playerSearchBg: isDark
          ? Colors.white.withValues(alpha: 0.12)
          : const Color(0xFFF1F5F9),
      chipBg: isDark ? darkBgRaised : const Color(0xFFF1F5F9),
      playerInputFill: isDark ? darkBgRaised : const Color(0xFFF8FAFC),
      managerToggleActiveBg: isDark
          ? Colors.orange.withValues(alpha: 0.18)
          : const Color(0xFFFEF3C7),
      managerToggleInactiveBg: isDark ? darkBgRaised : const Color(0xFFF1F5F9),
      infoTagBg: isDark ? darkBgRaised : lightBgRaised,
      rateWidgetLabel: isDark ? darkTextSec : const Color(0xFF64748B),
      rateWidgetValue: isDark ? darkTextPri : lightTextPri,
      rateWidgetSkill: isDark ? darkAccent : lightAccent,
      roleManager: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      roleUser: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
      roleGuest: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      genderTag: isDark ? const Color(0xFF818CF8) : const Color(0xFF059669),
    );

    final formColors = FormColors(
      filterDivider: isDark ? darkBorder : lightBorder,
      filterTabActiveText: isDark ? darkTextPri : lightTextPri,
      filterTabInactiveText: isDark ? darkTextSec : const Color(0xFF64748B),
      filterTabIndicator: isDark ? darkAccent : lightAccent,
      filterChipActiveBg: isDark ? darkAccent : lightAccent,
      filterChipInactiveBg: isDark ? darkBgRaised : const Color(0xFFF1F5F9),
      filterChipActiveText: isDark ? darkBgBase : Colors.white,
      filterChipInactiveText: isDark ? darkTextSec : lightTextSec,
      editFormBg: isDark ? darkBgSurface : lightBgRaised,
      editFormBorder: isDark ? darkBorder : lightBorder,
      editFormShadow: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.05),
      inputBorder: isDark ? darkBorder : const Color(0xFFCBD5E1),
      inputFocusBorder: isDark ? darkAccent : lightAccent,
      managerToggleActiveBorder: isDark
          ? Colors.orange.shade400
          : const Color(0xFFF59E0B),
      managerToggleInactiveBorder: isDark ? darkBorder : lightBorder,
      managerToggleInactiveText: isDark ? darkTextSec : const Color(0xFF64748B),
      genderActiveBg: isDark
          ? darkAccent.withValues(alpha: 0.18)
          : const Color(0xFFD1FAE5),
      genderActiveBorder: isDark
          ? darkAccent.withValues(alpha: 0.5)
          : lightAccent,
      genderInactiveBg: isDark ? darkBgRaised : const Color(0xFFF8FAFC),
      genderInactiveText: isDark ? darkTextSec : const Color(0xFF64748B),
      genderActiveText: isDark ? darkAccent : lightAccentDim,
      skillChipActiveBg: isDark
          ? darkAccent.withValues(alpha: 0.22)
          : const Color(0xFFD1FAE5),
      skillChipCheckmark: isDark ? darkAccent : lightAccent,
      skillChipActiveText: isDark ? darkAccent : lightAccentDim,
      stepperBg: isDark ? darkBgRaised : const Color(0xFFF1F5F9),
      stepperLabelText: isDark ? darkTextSec : lightTextSec,
      stepperValueText: isDark ? darkAccent : lightAccent,
      stepperBtnBg: isDark ? darkBgHighest : lightBgRaised,
      stepperBtnIcon: isDark ? darkAccent : lightAccent,
      footerCancelText: isDark ? darkTextSec : const Color(0xFF64748B),
      footerSubmitBg: isDark ? darkAccent : lightAccent,
      footerSubmitText: isDark ? darkBgBase : Colors.white,
      footerSubmitShadow: isDark
          ? darkAccent.withValues(alpha: 0.35)
          : lightAccent.withValues(alpha: 0.3),
    );

    final courtColors = CourtColors(
      homeDivider: isDark ? darkBorder : lightBorder,
      courtSelectBg: isDark ? darkBgRaised : const Color(0xFFE2E8F0),
      courtSelectActiveBgStart: isDark
          ? darkAccent.withValues(alpha: 0.25)
          : const Color(0xFF10B981),
      courtSelectActiveBgEnd: isDark
          ? darkAccent.withValues(alpha: 0.25)
          : const Color(0xFF059669),
      courtSelectActiveText: isDark ? darkAccentDim : Colors.white,
      courtSelectInactiveText: isDark ? darkTextSec : const Color(0xFF334155),
      waitingPanelBgStart: isDark ? darkBgSurface : Colors.white,
      waitingPanelBgEnd: isDark ? darkBgSurface : const Color(0xFFF8FAF9),
      waitingPanelHeaderBg: isDark ? darkBgRaised : lightBgRaised,
      waitingPanelHeaderTitle: isDark ? darkTextPri : lightTextPri,
      waitingPanelSortBtnBg: isDark
          ? darkAccent.withValues(alpha: 0.16)
          : const Color(0xFFD1FAE5),
      waitingPanelSortBtnBorder: isDark
          ? darkAccent.withValues(alpha: 0.4)
          : const Color(0xFFA7F3D0),
      // --- 코트 카드 (싱그러운 연한 녹색) ---
      courtCardBgStart: isDark
          ? const Color(0xFF243248)
          : const Color(0xFFECFDF5),
      courtCardBgEnd: isDark
          ? const Color(0xFF243248)
          : const Color(0xFFD1FAE5),
      courtCardText: isDark ? const Color(0xFF93C5FD) : const Color(0xFF065F46),
      // --- 대기 존 (화사하고 따뜻한 버터 옐로우) ---
      standbyZoneBgStart: isDark
          ? const Color(0xFF2D263D)
          : const Color(0xFFFFFBEB),
      standbyZoneBgEnd: isDark
          ? const Color(0xFF2D263D)
          : const Color(0xFFFEF3C7),
      standbyZoneBorder: isDark ? darkBorder : const Color(0xFFFCD34D),
      standbyZoneIcon: isDark
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706),
      // 버튼들 — 상쾌한 그린 & 웜 앰버
      btnAutoMatchStart: isDark
          ? const Color(0xFF15803D)
          : const Color(0xFF059669),
      btnAutoMatchEnd: isDark
          ? const Color(0xFF16A34A)
          : const Color(0xFF047857),
      btnRemoveStart: isDark
          ? const Color(0xFFB91C1C)
          : const Color(0xFFDC2626),
      btnRemoveEnd: isDark ? const Color(0xFFDC2626) : const Color(0xFFB91C1C),
      btnFinishStart: isDark
          ? const Color(0xFFC2410C)
          : const Color(0xFFD97706),
      btnFinishEnd: isDark ? const Color(0xFFEA580C) : const Color(0xFFB45309),
      btnSwapStart: isDark ? const Color(0xFF1D4ED8) : const Color(0xFF0284C7),
      btnSwapEnd: isDark ? const Color(0xFF2563EB) : const Color(0xFF0369A1),
      btnRemoveCourtStart: isDark
          ? const Color(0xFFB45309)
          : const Color(0xFFD97706),
      btnRemoveCourtEnd: isDark
          ? const Color(0xFFD97706)
          : const Color(0xFFB45309),
      playerItemTextPrimary: isDark ? darkTextPri : lightTextPri,
      playerItemTextSecondary: isDark ? darkTextSec : lightTextSec,
      playerItemGenderText: isDark ? darkAccentDim : lightAccent,
      playerItemRateLabel: isDark ? darkTextSec : const Color(0xFF64748B),
      playerItemDivider: isDark ? darkBorder : lightBorder,
      // --- 코트 내 플레이어 칸 ---
      dropZoneEmptyBg: isDark
          ? const Color(0xFF2D3C54)
          : const Color(0xFFFFFFFF).withValues(alpha: 0.8),
      dropZoneInactiveBg: isDark
          ? const Color(0xFF202A3B)
          : const Color(0xFFE2E8F0),
      dropZoneActiveBg: isDark ? const Color(0xFF334460) : lightBgRaised,
      dropZoneHoverBg: isDark
          ? const Color(0xFF3B4E6E)
          : const Color(0xFFD1FAE5),
      dropZoneBorder: isDark
          ? const Color(0xFF4A5B75)
          : const Color(0xFFA7F3D0),
      dropZoneCloseIcon: isDark ? darkTextSec : const Color(0xFF64748B),
    );

    final dialogColors = DialogColors(
      dialogTitleBgStart: isDark ? darkBgRaised : const Color(0xFFD1FAE5),
      dialogTitleBgEnd: isDark ? darkBgRaised : const Color(0xFFFEF3C7),
      dialogTitleManagerBgStart: isDark
          ? Colors.orange.withValues(alpha: 0.18)
          : const Color(0xFFFFFBEB),
      dialogTitleManagerBgEnd: isDark
          ? Colors.orange.withValues(alpha: 0.18)
          : const Color(0xFFFEF3C7),
      dialogButtonCancelText: isDark ? darkTextSec : const Color(0xFF64748B),
      dialogButtonConfirmBg: isDark ? darkAccent : lightAccent,
      dialogButtonConfirmText: isDark ? darkBgBase : Colors.white,
      dialogSummaryBg: isDark ? darkBgBase : const Color(0xFFF8FAF9),
      dialogSummaryBorder: isDark ? darkBorder : lightBorder,
    );

    // 글로벌 텍스트 테마 적용
    final baseTextTheme = isDark
        ? Typography.material2021().white
        : Typography.material2021().black;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? darkBgBase : lightBgBase,
      cardTheme: CardThemeData(
        color: isDark ? darkBgSurface : lightBgRaised,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: isDark ? darkTextPri : lightTextPri,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? darkBgSurface : lightBgRaised,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: [
        baseColors,
        playerColors,
        formColors,
        courtColors,
        dialogColors,
      ],
      textTheme: baseTextTheme.apply(
        bodyColor: isDark ? Colors.white : lightTextPri,
        displayColor: isDark ? Colors.white : lightTextPri,
      ),
    );
  }

  static ThemeData get light => buildTheme(Brightness.light);
  static ThemeData get dark => buildTheme(Brightness.dark);
}
