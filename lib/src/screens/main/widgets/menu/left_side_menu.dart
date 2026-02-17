import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'dart:math';

import '../../../../providers/players_provider.dart';
import '../../../../common/utils/game/skill_utils.dart';
import '../../../../common/widgets/dialogs/add_player_dialog.dart';
import '../../../../common/widgets/dialogs/confirmation_dialog.dart';

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
        return AddPlayerDialog(
          playersProvider: playersProvider,
          player: existingPlayer,
          isGuest: isGuest,
        );
      },
    );
    try {
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
            newPlayed: result['played'] as int,
            newWaited: result['waited'] as int,
            newGroups: result['groups'] as List<ObjectId>,
          );
        } else if (result['loaded'] as bool) {
          playersProvider.loadPlayer(
            result['player'],
            result['groups'] as List<ObjectId>,
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
            groups: result['groups'] as List<ObjectId>,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
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
    final iconAndFontSize = widget.isMobileSize ? 24.0 : 40.0;

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
          ...players.map(
            (player) => Container(
              // 1. ListTile의 'tileColor' 역할을 합니다.
              color: player.activate == false
                  ? const Color(0x55333333)
                  : player.role == "manager"
                  ? const Color(0x55FFF700)
                  : player.role == "user"
                  ? const Color(0x3300BFFF)
                  : null,
              // 2. ListTile의 기본 여백과 유사하게 Padding을 줍니다.
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // 아이콘과 텍스트를 세로 중앙 정렬
                  children: [
                    // 3. 텍스트 영역 (남은 공간을 모두 차지)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${player.name} / ${player.gender} / ${rateToSkillLevel[player.rate]}',
                            style: TextStyle(fontSize: iconAndFontSize),
                          ),
                          if (player.groups.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                player.groups
                                    .map(
                                      (id) => playersProvider.players[id]?.name,
                                    )
                                    .where((name) => name != null)
                                    .join(' , '),
                                style: TextStyle(
                                  fontSize: iconAndFontSize * 0.6,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 4. 아이콘 영역 (ListTile의 'trailing' 역할)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.block),
                          iconSize: iconAndFontSize,
                          onPressed: () {
                            playersProvider.toggleIsActivate(player);
                          },
                        ),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
