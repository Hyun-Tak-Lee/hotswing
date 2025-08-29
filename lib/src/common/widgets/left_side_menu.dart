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
        result['manager'] != null) {
      playersProvider.addPlayer(
        name: result['name'] as String,
        rate: result['rate'] as int,
        gender: result['gender'] as String,
        manager: result['manager'] as bool,
        played: 0,
        waited: 0,
      );
    }
  }

  // 모든 플레이어를 삭제하기 전에 확인 대화 상자를 표시하는 함수
  Future<void> _showClearAllPlayersConfirmationDialog(
    PlayersProvider playersProvider,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmationDialog(
          message: '모든 참여자를 삭제하시겠습니까?',
          onConfirm: () {
            playersProvider.clearPlayers();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(context);
    final players = playersProvider.getPlayers();
    final iconAndFontSize = widget.isMobileSize ? 24.0 : 48.0;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: widget.isMobileSize
                ? MediaQuery.of(context).size.height * 0.1
                : 180,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFA0E9FF), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '참여자 (${players.length}명)',
                    style: TextStyle(fontSize: iconAndFontSize),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        iconSize: iconAndFontSize,
                        onPressed: () {
                          _showClearAllPlayersConfirmationDialog(
                            playersProvider,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        iconSize: iconAndFontSize,
                        onPressed: () {
                          _showAddPlayerDialog(playersProvider);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ...players
              .map(
                (player) => ListTile(
                  tileColor: player.manager ? const Color(0x55FFF700) : null,
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
                          '${player.name} (${player.gender})',
                          style: TextStyle(fontSize: iconAndFontSize),
                        ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _editingPlayer == player ? Icons.check : Icons.edit,
                        ),
                        iconSize: iconAndFontSize,
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
                        iconSize: iconAndFontSize,
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
