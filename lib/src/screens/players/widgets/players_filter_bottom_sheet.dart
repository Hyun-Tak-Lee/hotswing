import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class PlayersFilterBottomSheet extends StatefulWidget {
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
        top: 24.0,
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
            // Filter Types (Tabs) - 스크롤 가능하도록 SingleChildScrollView 사용
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterTab(
                    title: '역할',
                    fontSize: tabFontSize,
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                  const SizedBox(width: 24),
                  _FilterTab(
                    title: '성별',
                    fontSize: tabFontSize,
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                  const SizedBox(width: 24),
                  _FilterTab(
                    title: '급수',
                    fontSize: tabFontSize,
                    isSelected: _selectedTabIndex == 2,
                    onTap: () => setState(() => _selectedTabIndex = 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
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
  });

  final String title;
  final double fontSize;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
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
