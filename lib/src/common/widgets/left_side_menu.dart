import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../providers/players_provider.dart';
import '../utils/skill_utils.dart';
import 'dialogs/add_player_dialog.dart';
import 'dialogs/confirmation_dialog.dart';

class LeftSideMenu extends StatefulWidget {
  const LeftSideMenu({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  State<LeftSideMenu> createState() => _LeftSideMenuState();
}

class _LeftSideMenuState extends State<LeftSideMenu> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showAddPlayerDialog(
    PlayersProvider playersProvider,
    bool isGuest, {
    Player? existingPlayer,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AddPlayerDialog(player: existingPlayer, isGuest: isGuest);
      },
    );

    if (result != null &&
        result['name'] != null &&
        result['rate'] != null &&
        result['gender'] != null &&
        result['role'] != null) {
      if (existingPlayer != null) {
        playersProvider.updatePlayer(
          playerId: existingPlayer.id,
          newName: result['name'] as String,
          newRate: result['rate'] as int,
          newGender: result['gender'] as String,
          newRole: result['role'] as String,
        );
      } else {
        int latedValue = 0;
        if (playersProvider.unassignedPlayers.isNotEmpty) {
          latedValue = playersProvider.unassignedPlayers
              .map((p) => p.played)
              .reduce(max);
        }
        playersProvider.addPlayer(
          name: result['name'] as String,
          rate: result['rate'] as int,
          gender: result['gender'] as String,
          role: result['role'] as String,
          played: 0,
          waited: 0,
          lated: latedValue,
        );
      }
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
            height: widget.isMobileSize ? 120 : 180,
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
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: '게스트 추가',
                        icon: const Icon(Icons.person_pin),
                        iconSize: iconAndFontSize,
                        onPressed: () {
                          _showAddPlayerDialog(playersProvider, true);
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: '일반 참여자 추가',
                        icon: const Icon(Icons.person_add),
                        iconSize: iconAndFontSize,
                        onPressed: () {
                          _showAddPlayerDialog(playersProvider, false);
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
                  tileColor: player.role == "manager"
                      ? const Color(0x55FFF700)
                      : player.role == "user"
                          ? const Color(0x3300BFFF)
                          : null,
                  title: Text(
                    '${player.name} / ${player.gender} / ${rateToSkillLevel[player.rate]}',
                    style: TextStyle(fontSize: iconAndFontSize),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        iconSize: iconAndFontSize,
                        onPressed: () {
                          _showAddPlayerDialog(
                            playersProvider,
                            false,
                            existingPlayer: player,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        iconSize: iconAndFontSize,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return ConfirmationDialog(
                                message: '"${player.name}" 님을 삭제하시겠습니까?',
                                onConfirm: () {
                                  playersProvider.removePlayer(player.id);
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
