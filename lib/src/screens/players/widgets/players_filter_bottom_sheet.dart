import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class PlayersFilterBottomSheet extends StatefulWidget {
  const PlayersFilterBottomSheet({super.key});

  @override
  State<PlayersFilterBottomSheet> createState() =>
      _PlayersFilterBottomSheetState();
}

class _PlayersFilterBottomSheetState extends State<PlayersFilterBottomSheet> {
  // 0: Role, 1: Gender
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PlayersViewModel>(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    final double tabFontSize = isTablet ? 20.0 : 16.0;
    final double chipFontSize = isTablet ? 18.0 : 16.0;

    final double minHeightRatio = isTablet ? 0.4 : 0.5;

    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * minHeightRatio,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
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
                  _buildTab('역할', 0, tabFontSize),
                  const SizedBox(width: 24),
                  _buildTab('성별', 1, tabFontSize),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 24),

            // Filter Options
            if (_selectedTabIndex == 0)
              _buildOptions<PlayerRole>(
                values: PlayerRole.values,
                selectedValues: viewModel.selectedRoles,
                onSelected: viewModel.toggleRoleFilter,
                labelBuilder: (role) => role.label,
                chipFontSize: chipFontSize,
              )
            else
              _buildOptions<PlayerGender>(
                values: PlayerGender.values,
                selectedValues: viewModel.selectedGenders,
                onSelected: viewModel.toggleGenderFilter,
                labelBuilder: (gender) => gender.label,
                chipFontSize: chipFontSize,
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, int index, double fontSize) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.black45,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions<T>({
    required List<T> values,
    required Set<T> selectedValues,
    required Function(T) onSelected,
    required String Function(T) labelBuilder,
    required double chipFontSize,
  }) {
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
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              labelBuilder(value),
              style: TextStyle(
                fontSize: chipFontSize,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
