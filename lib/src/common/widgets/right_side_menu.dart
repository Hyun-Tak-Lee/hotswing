import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';

class RightSideMenu extends StatelessWidget {
  const RightSideMenu({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    final optionsProvider = Provider.of<OptionsProvider>(context);
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
              decoration: BoxDecoration(color: Colors.lightBlue),
              child: Text('옵션', style: TextStyle(fontSize: 24)),
            ),
          ),
          SwitchListTile(
            title: Text(
              '팀 나누기',
              style: const TextStyle(fontSize: 24),
            ),
            value: optionsProvider.divideTeam,
            onChanged: (bool value) {
              optionsProvider.toggleDivideTeam();
            },
            activeColor: Colors.blueAccent,
            tileColor: Colors.black.withAlpha(13),
          ),
        ],
      ),
    );
  }
}
