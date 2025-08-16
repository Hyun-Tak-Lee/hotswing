import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/players_provider.dart';
import './confirmation_dialog.dart'; // ConfirmationDialog import 추가

class LeftSideMenu extends StatelessWidget {
  const LeftSideMenu({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final players = playersProvider.getPlayers();

    return Drawer(
      width: isMobileSize
          ? MediaQuery.of(context).size.width * 0.75
          : MediaQuery.of(context).size.width * 0.5, // Drawer 너비 설정
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: isMobileSize
                ? MediaQuery.of(context).size.height * 0.075
                : 150, // DrawerHeader 높이 조절
            child: const DrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue),
              child: Text('플레이어 목록'), // 헤더 텍스트 변경
            ),
          ),
          ...players
              .map(
                (player) => ListTile(
                  title: Text(player, style: const TextStyle(fontSize: 24)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return ConfirmationDialog(
                                message: '"$player" 님을 삭제하시겠습니까?',
                                onConfirm: () {
                                  playersProvider.removePlayer(player);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}