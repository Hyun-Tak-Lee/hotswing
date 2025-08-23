import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/players_provider.dart';
import 'dialogs/add_player_dialog.dart';
import 'dialogs/confirmation_dialog.dart';

class LeftSideMenu extends StatefulWidget {
  const LeftSideMenu({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  State<LeftSideMenu> createState() => _LeftSideMenuState();
}

class _LeftSideMenuState extends State<LeftSideMenu> {
  Player? _editingPlayer;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // AddPlayerDialog를 보여주는 함수
  Future<void> _showAddPlayerDialog(PlayersProvider playersProvider) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return const AddPlayerDialog();
      },
    );

    if (result != null &&
        result['name'] != null &&
        result['rate'] != null &&
        result['gender'] != null &&
        result['manager'] != null) { // manager 추가
      playersProvider.addPlayer(
        name: result['name'] as String,
        rate: result['rate'] as int,
        gender: result['gender'] as String,
        manager: result['manager'] as bool, // manager 추가
        played: 0,
        waited: 0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final players = playersProvider.getPlayers();

    return Drawer(
      width: widget.isMobileSize
          ? MediaQuery.of(context).size.width * 0.75
          : MediaQuery.of(context).size.width * 0.5,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: widget.isMobileSize
                ? MediaQuery.of(context).size.height * 0.1
                : 150,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.lightBlue),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '참여자 (${players.length}명)',
                    style: const TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      _showAddPlayerDialog(playersProvider);
                    },
                  ),
                ],
              ),
            ),
          ),
          ...players
              .map(
                (player) => ListTile(
                  title: _editingPlayer == player
                      ? TextField(
                          controller: _textController,
                          autofocus: true,
                          onSubmitted: (newName) {
                            if (newName.isNotEmpty && newName != player.name) {
                              playersProvider.updatePlayerName(
                                player.name,
                                newName,
                              );
                            }
                            setState(() {
                              _editingPlayer = null;
                            });
                          },
                          onTapOutside: (PointerDownEvent event) {
                            if (_editingPlayer == player) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                        )
                      : Text(
                          // 운영진 여부 표시
                          '${player.name} (${player.gender})${player.manager ? " (운영진)" : ""}',
                          style: const TextStyle(fontSize: 24),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _editingPlayer == player ? Icons.check : Icons.edit,
                        ),
                        onPressed: () {
                          if (_editingPlayer == player) {
                            final newName = _textController.text;
                            if (newName.isNotEmpty && newName != player.name) {
                              playersProvider.updatePlayerName(
                                player.name,
                                newName,
                              );
                            }
                            setState(() {
                              _editingPlayer = null;
                            });
                          } else {
                            setState(() {
                              _editingPlayer = player;
                              _textController.text = player.name;
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          if (_editingPlayer == player) {
                            setState(() {
                              _editingPlayer = null;
                            });
                          }
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return ConfirmationDialog(
                                message: '"${player.name}" 님을 삭제하시겠습니까?',
                                onConfirm: () {
                                  playersProvider.removePlayer(player.name);
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
