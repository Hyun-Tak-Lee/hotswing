import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/providers/theme_provider.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isThemeExpanded = true;
  bool _isCourtExpanded = true;
  bool _isMatchingExpanded = true;
  bool _isPlayerExpanded = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final optionsProvider = context.watch<OptionsProvider>();
    final playersProvider = context.read<PlayersProvider>();

    final baseColors = context.baseColors;
    final colorScheme = context.colorScheme;

    final dynamicCardBg = baseColors.cardBg;
    final dynamicCardShadow = baseColors.cardShadow;
    final dynamicBorder = Border.all(color: baseColors.cardBorderColor);
    final dynamicText = baseColors.textPrimary;
    final dynamicPrimary = baseColors.primaryAccent;
    final dynamicDarkAccent = baseColors.darkAccent;
    final dynamicInactiveTrack = baseColors.inactiveTrack;
    final dynamicThumb = baseColors.thumbColor;

    final isTablet = ResponsiveUtils.isTablet(context);
    final textScale = ResponsiveUtils.getTextScale(context);
    final iconAndFontSize = (isTablet ? 24.0 : 18.0) * textScale;
    final headerFontSize = iconAndFontSize * 1.2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32.0 : 16.0,
          vertical: 24.0,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              // 테마 설정 섹션
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingSectionHeader(
                    title: '테마 설정',
                    fontSize: headerFontSize,
                    isExpanded: _isThemeExpanded,
                    onToggle: () =>
                        setState(() => _isThemeExpanded = !_isThemeExpanded),
                    colorScheme: colorScheme,
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Container(
                      margin: const EdgeInsets.only(bottom: 24.0, top: 4.0),
                      decoration: BoxDecoration(
                        color: dynamicCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: dynamicBorder,
                        boxShadow: [
                          BoxShadow(
                            color: dynamicCardShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '화면 모드 설정',
                              style: TextStyle(
                                fontSize: iconAndFontSize,
                                fontWeight: FontWeight.bold,
                                color: dynamicText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<ThemeMode>(
                                segments: const <ButtonSegment<ThemeMode>>[
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.system,
                                    label: Text('시스템 설정'),
                                    icon: Icon(Icons.brightness_auto),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.light,
                                    label: Text('라이트 모드'),
                                    icon: Icon(Icons.light_mode),
                                  ),
                                  ButtonSegment<ThemeMode>(
                                    value: ThemeMode.dark,
                                    label: Text('다크 모드'),
                                    icon: Icon(Icons.dark_mode),
                                  ),
                                ],
                                selected: <ThemeMode>{themeProvider.themeMode},
                                onSelectionChanged:
                                    (Set<ThemeMode> newSelection) {
                                      themeProvider.setThemeMode(
                                        newSelection.first,
                                      );
                                    },
                                showSelectedIcon: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    crossFadeState: _isThemeExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 16),
                ],
              );

            case 1:
              // 코트 관리 섹션
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingSectionHeader(
                    title: '코트 관리',
                    fontSize: headerFontSize,
                    isExpanded: _isCourtExpanded,
                    onToggle: () =>
                        setState(() => _isCourtExpanded = !_isCourtExpanded),
                    colorScheme: colorScheme,
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Container(
                      margin: const EdgeInsets.only(bottom: 24.0, top: 4.0),
                      decoration: BoxDecoration(
                        color: dynamicCardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: dynamicBorder,
                        boxShadow: [
                          BoxShadow(
                            color: dynamicCardShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '코트 수 설정',
                                    style: TextStyle(
                                      fontSize: iconAndFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: dynamicText,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: dynamicPrimary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${optionsProvider.numberOfSections}개',
                                    style: TextStyle(
                                      fontSize: iconAndFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: dynamicDarkAccent,
                                    ),
                                  ),
                                ),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: dynamicPrimary,
                                inactiveTrackColor: dynamicInactiveTrack,
                                thumbColor: dynamicThumb,
                                overlayColor: dynamicPrimary.withValues(
                                  alpha: 0.2,
                                ),
                                valueIndicatorColor: dynamicPrimary,
                                trackHeight: 6.0,
                              ),
                              child: Slider(
                                value: optionsProvider.numberOfSections
                                    .toDouble(),
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label: optionsProvider.numberOfSections
                                    .round()
                                    .toString(),
                                onChanged: (double value) {
                                  int newNumberOfSections = value.round();
                                  optionsProvider.setNumberOfSections(
                                    newNumberOfSections,
                                  );
                                  playersProvider
                                      .updateAssignedPlayersListCount(
                                        newNumberOfSections,
                                      );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    crossFadeState: _isCourtExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 16),
                ],
              );

            case 2:
              // 매칭 조건 설정 섹션
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingSectionHeader(
                    title: '매칭 조건 설정',
                    fontSize: headerFontSize,
                    isExpanded: _isMatchingExpanded,
                    onToggle: () => setState(
                      () => _isMatchingExpanded = !_isMatchingExpanded,
                    ),
                    colorScheme: colorScheme,
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: dynamicCardBg,
                              borderRadius: BorderRadius.circular(16),
                              border: dynamicBorder,
                              boxShadow: [
                                BoxShadow(
                                  color: dynamicCardShadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 16.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '운영진 대기 (교류전 제외)',
                                    style: TextStyle(
                                      fontSize: iconAndFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: dynamicText,
                                    ),
                                  ),
                                  Switch.adaptive(
                                    value: optionsProvider.reserveManager,
                                    activeTrackColor: dynamicPrimary,
                                    onChanged: (bool value) {
                                      optionsProvider.setReserveManager(value);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SettingSliderCard(
                            title: '실력 매칭',
                            leftText: '2명씩 균등',
                            rightText: '4인 균등',
                            value: optionsProvider.skillWeight,
                            onChanged: (double value) =>
                                optionsProvider.setSkillWeight(value),
                            iconAndFontSize: iconAndFontSize,
                          ),
                          SettingSliderCard(
                            title: '성별 분포',
                            leftText: '남2여2 혼성',
                            rightText: '단일 성별 위주',
                            value: optionsProvider.genderWeight,
                            onChanged: (double value) =>
                                optionsProvider.setGenderWeight(value),
                            iconAndFontSize: iconAndFontSize,
                          ),
                          SettingSliderCard(
                            title: '대기 횟수 우선순위',
                            leftText: '조합 우선',
                            rightText: '대기 긴 사람 우선',
                            value: optionsProvider.waitedWeight,
                            onChanged: (double value) =>
                                optionsProvider.setWaitedWeight(value),
                            iconAndFontSize: iconAndFontSize,
                          ),
                          SettingSliderCard(
                            title: '경기 횟수 보정',
                            leftText: '무시',
                            rightText: '균등한 경기 수 반영',
                            value: optionsProvider.playedWeight,
                            onChanged: (double value) =>
                                optionsProvider.setPlayedWeight(value),
                            iconAndFontSize: iconAndFontSize,
                          ),
                          SettingSliderCard(
                            title: '중복 매칭 피하기',
                            leftText: '무시',
                            rightText: '다양한 사람과 매칭',
                            value: optionsProvider.playedWithWeight,
                            onChanged: (double value) =>
                                optionsProvider.setPlayedWithWeight(value),
                            iconAndFontSize: iconAndFontSize,
                          ),
                          SettingIntSliderCard(
                            title: '무작위 수치',
                            leftText: '최적 조합',
                            rightText: '랜덤성 부여',
                            value: optionsProvider.randomPoolSize,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            unit: '',
                            onChanged: (int value) =>
                                optionsProvider.setRandomPoolSize(value),
                            iconAndFontSize: iconAndFontSize,
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _isMatchingExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 16),
                ],
              );

            case 3:
              // 플레이어 관리 섹션
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingSectionHeader(
                    title: '플레이어 관리',
                    fontSize: headerFontSize,
                    isExpanded: _isPlayerExpanded,
                    onToggle: () =>
                        setState(() => _isPlayerExpanded = !_isPlayerExpanded),
                    colorScheme: colorScheme,
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 24.0),
                      child: SettingIntSliderCard(
                        title: '미활동 플레이어 정리 기간',
                        leftText: '30일',
                        rightText: '180일',
                        value: optionsProvider.inactiveDaysThreshold,
                        min: 30,
                        max: 180,
                        divisions: 30,
                        unit: '일',
                        onChanged: (int value) =>
                            optionsProvider.setInactiveDaysThreshold(value),
                        iconAndFontSize: iconAndFontSize,
                      ),
                    ),
                    crossFadeState: _isPlayerExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 32),
                ],
              );

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class SettingSectionHeader extends StatelessWidget {
  final String title;
  final double fontSize;
  final bool isExpanded;
  final VoidCallback onToggle;
  final ColorScheme colorScheme;

  const SettingSectionHeader({
    super.key,
    required this.title,
    required this.fontSize,
    required this.isExpanded,
    required this.onToggle,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final primaryColor = baseColors.primaryAccent;
    final textColor = baseColors.textPrimary;
    final iconColor = colorScheme.brightness == Brightness.dark
        ? colorScheme.onSurfaceVariant
        : Colors.grey.shade600;

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: fontSize * 1.2,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: iconColor,
              size: fontSize * 1.2,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingSliderCard extends StatelessWidget {
  final String title;
  final String leftText;
  final String rightText;
  final double value;
  final ValueChanged<double> onChanged;
  final double iconAndFontSize;

  const SettingSliderCard({
    super.key,
    required this.title,
    required this.leftText,
    required this.rightText,
    required this.value,
    required this.onChanged,
    required this.iconAndFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final cardBg = baseColors.cardBg;
    final shadowColor = baseColors.cardShadow;
    final textColor = baseColors.textPrimary;
    final textVariantColor = baseColors.textSecondary;
    final primaryColor = baseColors.primaryAccent;
    final darkAccent = baseColors.darkAccent;
    final inactiveTrack = baseColors.inactiveTrack;
    final thumbColor = baseColors.thumbColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColors.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: iconAndFontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    leftText,
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.8,
                      color: textVariantColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: darkAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rightText,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.8,
                      color: textVariantColor,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primaryColor,
                inactiveTrackColor: inactiveTrack,
                thumbColor: thumbColor,
                overlayColor: primaryColor.withValues(alpha: 0.2),
                valueIndicatorColor: primaryColor,
                valueIndicatorTextStyle: TextStyle(
                  color: baseColors.sliderIndicatorText,
                ),
                trackHeight: 6.0,
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 2,
                divisions: 20,
                label: value.toStringAsFixed(1),
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingIntSliderCard extends StatelessWidget {
  final String title;
  final String leftText;
  final String rightText;
  final int value;
  final int min;
  final int max;
  final int divisions;
  final String unit;
  final ValueChanged<int> onChanged;
  final double iconAndFontSize;

  const SettingIntSliderCard({
    super.key,
    required this.title,
    required this.leftText,
    required this.rightText,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.onChanged,
    required this.iconAndFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = '$value$unit';
    final baseColors = context.baseColors;
    final cardBg = baseColors.cardBg;
    final shadowColor = baseColors.cardShadow;
    final textColor = baseColors.textPrimary;
    final textVariantColor = baseColors.textSecondary;
    final primaryColor = baseColors.primaryAccent;
    final darkAccent = baseColors.darkAccent;
    final inactiveTrack = baseColors.inactiveTrack;
    final thumbColor = baseColors.thumbColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: baseColors.cardBorderColor),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: iconAndFontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    leftText,
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.8,
                      color: textVariantColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: darkAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    rightText,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.8,
                      color: textVariantColor,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primaryColor,
                inactiveTrackColor: inactiveTrack,
                thumbColor: thumbColor,
                overlayColor: primaryColor.withValues(alpha: 0.2),
                valueIndicatorColor: primaryColor,
                valueIndicatorTextStyle: TextStyle(
                  color: baseColors.sliderIndicatorText,
                ),
                trackHeight: 6.0,
              ),
              child: Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: divisions,
                label: '$value$unit',
                onChanged: (double v) => onChanged(v.round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
