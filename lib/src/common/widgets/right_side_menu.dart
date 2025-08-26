import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';

class RightSideMenu extends StatelessWidget {
  const RightSideMenu({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    final optionsProvider = Provider.of<OptionsProvider>(context);
    final playersProvider = Provider.of<PlayersProvider>(
      context,
      listen: false,
    );

    return Drawer(
      width: isMobileSize
          ? MediaQuery.of(context).size.width * 0.5
          : MediaQuery.of(context).size.width * 0.25,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: isMobileSize
                ? MediaQuery.of(context).size.height * 0.1
                : 150,
            child: const DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA0E9FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Text('옵션', style: TextStyle(fontSize: 24)),
            ),
          ),
          SwitchListTile(
            title: const Text('팀 나누기', style: TextStyle(fontSize: 24)),
            value: optionsProvider.divideTeam,
            onChanged: (bool value) {
              optionsProvider.toggleDivideTeam();
            },
            activeColor: Colors.blueAccent,
            tileColor: Colors.black.withAlpha(13),
          ),
          const SizedBox(height: 10), // 옵션 간 간격 추가
          ListTile(
            tileColor: Colors.black.withAlpha(13),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '코트 수: ${optionsProvider.numberOfSections}',
                  style: const TextStyle(fontSize: 24),
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
        ],
      ),
    );
  }
}
