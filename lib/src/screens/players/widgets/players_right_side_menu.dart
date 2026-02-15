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
    // 태블릿(넓은 화면)일 때 더 큰 폰트, 모바일일 때 작은 폰트
    final double iconAndFontSize = isTablet ? 48.0 : 24.0;

    return Drawer(
      width: isTablet
          ? MediaQuery.of(context).size.width * 0.60
          : MediaQuery.of(context).size.width * 0.75,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: isTablet ? 180 : 120,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA0E9FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Text('필터', style: TextStyle(fontSize: iconAndFontSize)),
            ),
          ),

          // 역할 필터 섹션
          ListTile(
            title: Text(
              '역할 (Role)',
              style: TextStyle(
                fontSize: iconAndFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...PlayerRole.values.map((role) {
            return CheckboxListTile(
              title: Text(
                role.label,
                style: TextStyle(fontSize: iconAndFontSize * 0.8),
              ),
              value: viewModel.selectedRoles.contains(role),
              onChanged: (bool? value) {
                if (value != null) {
                  viewModel.toggleRoleFilter(role);
                }
              },
            );
          }),

          const Divider(),

          // 성별 필터 섹션
          ListTile(
            title: Text(
              '성별 (Gender)',
              style: TextStyle(
                fontSize: iconAndFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 일반적인 관례에 따라 'M'과 'F'를 성별 값으로 가정
          // 성별 Enum이 있다면 정의하는 것이 좋지만, 현재는 String 상수를 사용
          CheckboxListTile(
            title: Text(
              '남성',
              style: TextStyle(fontSize: iconAndFontSize * 0.8),
            ),
            value: viewModel.selectedGenders.contains('남'), // DB에서 사용되는 '남'
            onChanged: (bool? value) {
              if (value != null) {
                viewModel.toggleGenderFilter('남');
              }
            },
          ),
          CheckboxListTile(
            title: Text(
              '여성',
              style: TextStyle(fontSize: iconAndFontSize * 0.8),
            ),
            value: viewModel.selectedGenders.contains('여'), // '여'
            onChanged: (bool? value) {
              if (value != null) {
                viewModel.toggleGenderFilter('여');
              }
            },
          ),
        ],
      ),
    );
  }
}
