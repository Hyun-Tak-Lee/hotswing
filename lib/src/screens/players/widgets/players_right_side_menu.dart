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

    // 폰트 사이즈 조정
    final double titleFontSize = isTablet ? 28.0 : 20.0;
    final double chipFontSize = isTablet ? 18.0 : 16.0;

    return Drawer(
      width: isTablet
          ? MediaQuery.of(context).size.width *
                0.40 // 탭에서는 60% 너무 큼 -> 40%
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
                child: Text('필터', style: TextStyle(fontSize: titleFontSize)),
              ),
            ),
          ),

          // 역할 필터 섹션
          ListTile(
            title: Text(
              '역할',
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
              runSpacing: 8.0, // runSpacing 조금 넒힘
              children: PlayerRole.values.map((role) {
                return FilterChip(
                  label: Text(
                    role.label,
                    style: TextStyle(fontSize: chipFontSize),
                  ),
                  selected: viewModel.selectedRoles.contains(role),
                  onSelected: (bool selected) {
                    viewModel.toggleRoleFilter(role);
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // 성별 필터 섹션
          ListTile(
            title: Text(
              '성별',
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
              children: [
                FilterChip(
                  label: Text('남성', style: TextStyle(fontSize: chipFontSize)),
                  selected: viewModel.selectedGenders.contains('남'),
                  onSelected: (bool selected) {
                    viewModel.toggleGenderFilter('남');
                  },
                ),
                FilterChip(
                  label: Text('여성', style: TextStyle(fontSize: chipFontSize)),
                  selected: viewModel.selectedGenders.contains('여'),
                  onSelected: (bool selected) {
                    viewModel.toggleGenderFilter('여');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
