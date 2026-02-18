import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';

class PlayersRightSideMenu extends StatelessWidget {
  const PlayersRightSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<PlayersViewModel>(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    final double headerTitleFontSize = isTablet ? 28.0 : 20.0;

    return Drawer(
      width: isTablet
          ? MediaQuery.of(context).size.width * 0.40
          : MediaQuery.of(context).size.width * 0.75,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: isTablet ? 100 : 70,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA0E9FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '필터',
                  style: TextStyle(fontSize: headerTitleFontSize),
                ),
              ),
            ),
          ),

          // 역할 필터 섹션
          _FilterSection<PlayerRole>(
            title: '역할',
            values: PlayerRole.values,
            selectedValues: viewModel.selectedRoles,
            onSelected: viewModel.toggleRoleFilter,
            labelBuilder: (role) => role.label,
          ),

          const Divider(),

          // 성별 필터 섹션
          _FilterSection<PlayerGender>(
            title: '성별',
            values: PlayerGender.values,
            selectedValues: viewModel.selectedGenders,
            onSelected: viewModel.toggleGenderFilter,
            labelBuilder: (gender) => gender.label,
          ),
        ],
      ),
    );
  }
}

class _FilterSection<T> extends StatelessWidget {
  final String title;
  final List<T> values;
  final Set<T> selectedValues;
  final Function(T) onSelected;
  final String Function(T) labelBuilder;

  const _FilterSection({
    required this.title,
    required this.values,
    required this.selectedValues,
    required this.onSelected,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final double titleFontSize = isTablet ? 28.0 : 20.0;
    final double chipFontSize = isTablet ? 18.0 : 16.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: values.map((value) {
              return FilterChip(
                label: Text(
                  labelBuilder(value),
                  style: TextStyle(fontSize: chipFontSize),
                ),
                selected: selectedValues.contains(value),
                onSelected: (bool selected) {
                  onSelected(value);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
