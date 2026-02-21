import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'dart:math';

import '../../../../providers/players_provider.dart';
import '../../../../common/utils/game/skill_utils.dart';
import '../../../../common/widgets/tags/player_info_tag.dart';
import '../../../../common/widgets/tags/player_skill_rate.dart';
import '../../../../common/widgets/dialogs/add_player_dialog.dart';
import '../../../../common/widgets/dialogs/confirmation_dialog.dart';
import '../../../../common/utils/ui/responsive_utils.dart';
import '../../../../enums/player_feature.dart';

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

  String _getRoleLabel(String roleValue) {
    try {
      return PlayerRole.values.firstWhere((e) => e.value == roleValue).label;
    } catch (_) {
      return roleValue;
    }
  }

  String _getGenderLabel(String genderValue) {
    if (genderValue == '남') return '남성';
    if (genderValue == '여') return '여성';
    return genderValue;
  }

  Color _getRoleColor(String roleValue) {
    if (roleValue == 'manager') return Colors.orange;
    if (roleValue == 'user') return Colors.green;
    if (roleValue == 'guest') return Colors.grey;
    return Colors.black;
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

    final isTablet = ResponsiveUtils.isTablet(context);
    final textScale = ResponsiveUtils.getTextScale(context);
    final iconAndFontSize = isTablet ? 32.0 : 24.0;
    final baseFontSize = (isTablet ? 18.0 : 14.0) * textScale;
    final titleFontSize = baseFontSize + 2;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: isTablet ? 180 : 120,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF3E5F5), // 라벤더 미스트 (연보라)
                    Color(0xFFE1F5FE), // 연하늘
                  ],
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
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: player.activate == false
                      ? [const Color(0x55333333), const Color(0x55333333)]
                      : [Colors.blue.shade50, Colors.purple.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player.name,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              PlayerInfoTag(
                                text: _getRoleLabel(player.role),
                                color: _getRoleColor(player.role),
                              ),
                              PlayerInfoTag(
                                text: _getGenderLabel(player.gender),
                                color: Colors.indigoAccent,
                              ),
                              PlayerSkillRateWidget(
                                skillLevel: rateToSkillLevel(player.rate),
                                rate: player.rate,
                              ),
                            ],
                          ),
                          if (player.groups.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                player.groups
                                    .map(
                                      (id) => playersProvider.players[id]?.name,
                                    )
                                    .where((name) => name != null)
                                    .join(' , '),
                                style: TextStyle(
                                  fontSize: baseFontSize * 0.8,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
