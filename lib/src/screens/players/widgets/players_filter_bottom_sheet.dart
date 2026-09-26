import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 플레이어 필터(역할, 성별, 급수)를 선택할 수 있는 바텀 시트 위젯.
class PlayersFilterBottomSheet extends StatefulWidget {
  /// [PlayersFilterBottomSheet] 생성자.
  const PlayersFilterBottomSheet({super.key});

  @override
  State<PlayersFilterBottomSheet> createState() =>
      _PlayersFilterBottomSheetState();
}

class _PlayersFilterBottomSheetState extends State<PlayersFilterBottomSheet> {
  // 0: 역할, 1: 성별, 2: 급수
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlayersViewModel>();
    final isTablet = ResponsiveUtils.isTablet(context);

    final baseColors = context.baseColors;
    final formColors = context.formColors;

    final double tabFontSize = isTablet ? 20.0 : 16.0;
    final double chipFontSize = isTablet ? 18.0 : 16.0;

    final double minHeightRatio = isTablet ? 0.4 : 0.5;

    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * minHeightRatio,
      ),
      decoration: BoxDecoration(
        color: baseColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.only(
        top: 12.0,
        left: 24.0,
        right: 24.0,
        bottom: 32.0,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 바텀시트 상단 드래그 핸들 (시각적 균형감 확보)
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: formColors.filterDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Types (Tabs) & Top Actions
            Row(
              children: [
                _FilterTab(
                  title: '역할',
                  fontSize: tabFontSize,
                  isSelected: _selectedTabIndex == 0,
                  selectedCount: viewModel.selectedRoles.length,
                  onTap: () => setState(() => _selectedTabIndex = 0),
                ),
                const SizedBox(width: 16),
                _FilterTab(
                  title: '성별',
                  fontSize: tabFontSize,
                  isSelected: _selectedTabIndex == 1,
                  selectedCount: viewModel.selectedGenders.length,
                  onTap: () => setState(() => _selectedTabIndex = 1),
                ),
                const SizedBox(width: 16),
                _FilterTab(
                  title: '급수',
                  fontSize: tabFontSize,
                  isSelected: _selectedTabIndex == 2,
                  selectedCount: viewModel.selectedSkills.length,
                  onTap: () => setState(() => _selectedTabIndex = 2),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _FilterTopActions(
                    onClear: viewModel.clearAllFilters,
                    onApply: () => Navigator.of(context).pop(),
                    fontSize: isTablet ? 14.0 : 12.5,
                  ),
                ),
              ],
            ),

            Divider(
              height: 1,
              thickness: 1,
              color: formColors.filterDivider,
            ),
            const SizedBox(height: 24),

            // Filter Options
            if (_selectedTabIndex == 0)
              _FilterOptions<PlayerRole>(
                values: PlayerRole.values,
                selectedValues: viewModel.selectedRoles,
                onSelected: viewModel.toggleRoleFilter,
                labelBuilder: (role) => role.label,
                chipFontSize: chipFontSize,
              )
            else if (_selectedTabIndex == 1)
              _FilterOptions<PlayerGender>(
                values: PlayerGender.values,
                selectedValues: viewModel.selectedGenders,
                onSelected: viewModel.toggleGenderFilter,
                labelBuilder: (gender) => gender.label,
                chipFontSize: chipFontSize,
              )
            else if (_selectedTabIndex == 2)
              _FilterOptions<String>(
                values: skillLevelToRate.keys.toList(),
                selectedValues: viewModel.selectedSkills,
                onSelected: viewModel.toggleSkillFilter,
                labelBuilder: (skill) => skill,
                chipFontSize: chipFontSize,
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.title,
    required this.fontSize,
    required this.isSelected,
    required this.onTap,
    this.selectedCount = 0,
  });

  final String title;
  final double fontSize;
  final bool isSelected;
  final VoidCallback onTap;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? formColors.filterTabActiveText
                      : formColors.filterTabInactiveText,
                ),
              ),
              if (selectedCount > 0) ...[
                const SizedBox(width: 3),
                Text(
                  '($selectedCount)',
                  style: TextStyle(
                    fontSize: fontSize * 0.85,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? formColors.filterTabIndicator
                        : formColors.filterTabInactiveText,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: selectedCount > 0 ? 44 : 32,
            decoration: BoxDecoration(
              color: isSelected
                  ? formColors.filterTabIndicator
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterOptions<T> extends StatelessWidget {
  const _FilterOptions({
    required this.values,
    required this.selectedValues,
    required this.onSelected,
    required this.labelBuilder,
    required this.chipFontSize,
  });

  final List<T> values;
  final Set<T> selectedValues;
  final Function(T) onSelected;
  final String Function(T) labelBuilder;
  final double chipFontSize;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: values.map((value) {
        final isSelected = selectedValues.contains(value);
        return GestureDetector(
          onTap: () {
            onSelected(value);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? formColors.filterChipActiveBg
                  : formColors.filterChipInactiveBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labelBuilder(value),
              style: TextStyle(
                fontSize: chipFontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? formColors.filterChipActiveText
                    : formColors.filterChipInactiveText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FilterTopActions extends StatelessWidget {
  const _FilterTopActions({
    required this.onClear,
    required this.onApply,
    required this.fontSize,
  });

  final VoidCallback onClear;
  final VoidCallback onApply;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 일괄 해제
        InkWell(
          onTap: onClear,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              '일괄 해제',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: formColors.filterTabInactiveText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // 적용
        InkWell(
          onTap: onApply,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: formColors.filterChipActiveBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '적용',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: formColors.filterChipActiveText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
