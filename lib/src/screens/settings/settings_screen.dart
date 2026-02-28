import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCourtExpanded = true;
  bool _isMatchingExpanded = true;

  @override
  Widget build(BuildContext context) {
    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(
      context,
      listen: false,
    );

    final isTablet = ResponsiveUtils.isTablet(context);
    final textScale = ResponsiveUtils.getTextScale(context);
    final iconAndFontSize = (isTablet ? 24.0 : 18.0) * textScale;
    final headerFontSize = iconAndFontSize * 1.2;

    return Scaffold(
      backgroundColor: Colors.transparent, // 부모 컨테이너의 배경색 활용
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 32.0 : 16.0,
              vertical: 24.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 코트 관리 섹션
                _buildSectionHeader(
                  title: '코트 관리',
                  fontSize: headerFontSize,
                  isExpanded: _isCourtExpanded,
                  onToggle: () =>
                      setState(() => _isCourtExpanded = !_isCourtExpanded),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Container(
                    margin: const EdgeInsets.only(bottom: 24.0, top: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '코트 수 설정',
                                style: TextStyle(
                                  fontSize: iconAndFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${optionsProvider.numberOfSections}개',
                                  style: TextStyle(
                                    fontSize: iconAndFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.blueAccent,
                              inactiveTrackColor: Colors.blue.withValues(
                                alpha: 0.2,
                              ),
                              thumbColor: Colors.white,
                              overlayColor: Colors.blueAccent.withValues(
                                alpha: 0.2,
                              ),
                              valueIndicatorColor: Colors.blueAccent,
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
                                playersProvider.updateAssignedPlayersListCount(
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

                // 매칭 조건 설정 섹션
                const SizedBox(height: 16),
                _buildSectionHeader(
                  title: '매칭 조건 설정',
                  fontSize: headerFontSize,
                  isExpanded: _isMatchingExpanded,
                  onToggle: () => setState(
                    () => _isMatchingExpanded = !_isMatchingExpanded,
                  ),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '운영진 대기 (운영진 1명일 시 OFF)',
                                  style: TextStyle(
                                    fontSize: iconAndFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Switch.adaptive(
                                  value: optionsProvider.reserveManager,
                                  activeThumbColor: Colors.blueAccent,
                                  onChanged: (bool value) {
                                    optionsProvider.setReserveManager(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildSliderListItem(
                          context: context,
                          title: '실력 매칭',
                          leftText: '2명씩 균등',
                          rightText: '4인 균등',
                          value: optionsProvider.skillWeight,
                          onChanged: (double value) =>
                              optionsProvider.setSkillWeight(value),
                          iconAndFontSize: iconAndFontSize,
                        ),
                        _buildSliderListItem(
                          context: context,
                          title: '성별 분포',
                          leftText: '남2여2 혼성',
                          rightText: '단일 성별 위주',
                          value: optionsProvider.genderWeight,
                          onChanged: (double value) =>
                              optionsProvider.setGenderWeight(value),
                          iconAndFontSize: iconAndFontSize,
                        ),
                        _buildSliderListItem(
                          context: context,
                          title: '대기 횟수 우선순위',
                          leftText: '조합 우선',
                          rightText: '대기 긴 사람 우선',
                          value: optionsProvider.waitedWeight,
                          onChanged: (double value) =>
                              optionsProvider.setWaitedWeight(value),
                          iconAndFontSize: iconAndFontSize,
                        ),
                        _buildSliderListItem(
                          context: context,
                          title: '경기 횟수 보정',
                          leftText: '무시',
                          rightText: '균등한 경기 수 반영',
                          value: optionsProvider.playedWeight,
                          onChanged: (double value) =>
                              optionsProvider.setPlayedWeight(value),
                          iconAndFontSize: iconAndFontSize,
                        ),
                        _buildSliderListItem(
                          context: context,
                          title: '중복 매칭 피하기',
                          leftText: '무시',
                          rightText: '다양한 사람과 매칭',
                          value: optionsProvider.playedWithWeight,
                          onChanged: (double value) =>
                              optionsProvider.setPlayedWithWeight(value),
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

                const SizedBox(height: 48), // 하단 여백 추가
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required double fontSize,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
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
                color: Colors.blueAccent,
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
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
              size: fontSize * 1.2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderListItem({
    required BuildContext context,
    required String title,
    required String leftText,
    required String rightText,
    required double value,
    required ValueChanged<double> onChanged,
    required double iconAndFontSize,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  leftText,
                  style: TextStyle(
                    fontSize: iconAndFontSize * 0.8,
                    color: Colors.grey.shade600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: iconAndFontSize * 0.9,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent.shade700,
                    ),
                  ),
                ),
                Text(
                  rightText,
                  style: TextStyle(
                    fontSize: iconAndFontSize * 0.8,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.blue.withValues(alpha: 0.2),
                thumbColor: Colors.white,
                overlayColor: Colors.blueAccent.withValues(alpha: 0.2),
                valueIndicatorColor: Colors.blueAccent,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
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
