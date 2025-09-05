import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'dialogs/confirmation_dialog.dart';

class RightSideMenu extends StatelessWidget {
  const RightSideMenu({super.key, required this.isMobileSize});

  final bool isMobileSize;

  Widget _buildSliderListItem({
    required BuildContext context,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required double iconAndFontSize,
  }) {
    return ListTile(
      tileColor: Colors.black.withAlpha(13),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ${value.toStringAsFixed(1)}',
            style: TextStyle(fontSize: iconAndFontSize),
          ),
          Slider(
            value: value,
            min: 0,
            max: 2,
            divisions: 10,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(
      context,
      listen: false,
    );
    final iconAndFontSize = isMobileSize ? 24.0 : 48.0;
    final switchScale = isMobileSize ? 1.0 : 1.5;

    return Drawer(
      width: isMobileSize
          ? MediaQuery.of(context).size.width * 0.55
          : MediaQuery.of(context).size.width * 0.45,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: isMobileSize
                ? MediaQuery.of(context).size.height * 0.1
                : 180,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA0E9FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Text('옵션', style: TextStyle(fontSize: iconAndFontSize)),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.refresh, // 새로고침/초기화 아이콘
              size: iconAndFontSize,
              color: Colors.orangeAccent, // 주황색 계열로 강조
            ),
            title: Text(
              '플레이 정보 초기화',
              style: TextStyle(
                fontSize: iconAndFontSize,
                color: Colors.orangeAccent, // 아이콘과 동일한 색상으로 통일감
                fontWeight: FontWeight.bold, // 굵게 표시
              ),
            ),
            tileColor: Colors.orangeAccent.withOpacity(0.1), // 은은한 주황색 배경
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return ConfirmationDialog(
                    message: '모든 참여자의 플레이 정보들을 초기화 하시겠습니까?',
                    onConfirm: () {
                      playersProvider.resetPlayerStats();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('플레이 정보가 초기화되었습니다')),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text('팀 지정 (사용x)', style: TextStyle(fontSize: iconAndFontSize)),
            trailing: Transform.scale(
              scale: switchScale,
              child: Switch(
                value: optionsProvider.divideTeam,
                onChanged: (bool value) {
                  optionsProvider.toggleDivideTeam();
                },
                activeColor: Colors.blueAccent,
              ),
            ),
            tileColor: Colors.black.withAlpha(13),
            onTap: () {
              optionsProvider.toggleDivideTeam();
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.black.withAlpha(13),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '코트 수: ${optionsProvider.numberOfSections}',
                  style: TextStyle(fontSize: iconAndFontSize),
                ),
                Slider(
                  value: optionsProvider.numberOfSections.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                  label: optionsProvider.numberOfSections.round().toString(),
                  onChanged: (double value) {
                    int newNumberOfSections = value.round();
                    optionsProvider.setNumberOfSections(newNumberOfSections);
                    playersProvider.updateAssignedPlayersListCount(
                      newNumberOfSections,
                    );
                  },
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSliderListItem(
            context: context,
            title: '실력 가중치',
            value: optionsProvider.skillWeight,
            onChanged: (double value) {
              optionsProvider.setSkillWeight(value);
            },
            iconAndFontSize: iconAndFontSize,
          ),
          const SizedBox(height: 10),
          _buildSliderListItem(
            context: context,
            title: '성별 가중치',
            value: optionsProvider.genderWeight,
            onChanged: (double value) {
              optionsProvider.setGenderWeight(value);
            },
            iconAndFontSize: iconAndFontSize,
          ),
          const SizedBox(height: 10),
          _buildSliderListItem(
            context: context,
            title: '대기 가중치',
            value: optionsProvider.waitedWeight,
            onChanged: (double value) {
              optionsProvider.setWaitedWeight(value);
            },
            iconAndFontSize: iconAndFontSize,
          ),
          const SizedBox(height: 10),
          _buildSliderListItem(
            context: context,
            title: '플레이 횟수 가중치',
            value: optionsProvider.playedWeight,
            onChanged: (double value) {
              optionsProvider.setPlayedWeight(value);
            },
            iconAndFontSize: iconAndFontSize,
          ),
          const SizedBox(height: 10),
          _buildSliderListItem(
            context: context,
            title: '중복 방지 가중치',
            value: optionsProvider.playedWithWeight,
            onChanged: (double value) {
              optionsProvider.setPlayedWithWeight(value);
            },
            iconAndFontSize: iconAndFontSize,
          ),
        ],
      ),
    );
  }
}
