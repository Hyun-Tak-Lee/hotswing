import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../../../../providers/players_provider.dart';
import '../../../../../common/widgets/dialogs/add_player/add_player_dialog.dart';
import '../../../../../common/widgets/dialogs/confirmation_dialog.dart';
import '../../../../../common/utils/ui/responsive_utils.dart';
import '../../../../../enums/player_feature.dart';
import 'package:hotswing/src/screens/main/widgets/menu/left_side/left_side_menu_header.dart';
import 'package:hotswing/src/screens/main/widgets/menu/left_side/player_list_item_tile.dart';

/// 메인 화면 좌측 서랍(Drawer) 메뉴 위젯으로, 현재 세션의 참여자 목록 관리 기능을 제공.
class LeftSideMenu extends StatefulWidget {
  /// [LeftSideMenu] 생성자.
  const LeftSideMenu({super.key, required this.isMobileSize});

  /// 모바일 화면 크기 여부.
  final bool isMobileSize;

  @override
  State<LeftSideMenu> createState() => _LeftSideMenuState();
}

class _LeftSideMenuState extends State<LeftSideMenu> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playersProvider = context.watch<PlayersProvider>();
    final players = playersProvider.getPlayers();

    final isMobile = widget.isMobileSize || ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final drawerWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.85
        : MediaQuery.of(context).size.width * 0.75;

    return Drawer(
      width: drawerWidth,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: players.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return LeftSideMenuHeader(
              playerCount: players.length,
              isMobile: isMobile,
              isTablet: isTablet,
              onClearAll: () =>
                  _showClearAllPlayersConfirmationDialog(playersProvider),
              onAddGuest: () => _showAddPlayerDialog(playersProvider, true),
              onAddRegular: () => _showAddPlayerDialog(playersProvider, false),
            );
          }

          final player = players[index - 1];
          final groupInfo = playersProvider.getGroupInfo(player.id);
          return PlayerListItemTile(
            player: player,
            groupInfo: groupInfo,
            isMobile: isMobile,
            isTablet: isTablet,
            roleLabel: _getRoleLabel(player.role),
            roleColor: _getRoleColor(context, player.role),
            genderLabel: _getGenderLabel(player.gender, isMobile: isMobile),
            onToggleActivate: () => playersProvider.toggleIsActivate(player),
            onEdit: () => _showAddPlayerDialog(
              playersProvider,
              false,
              existingPlayer: player,
            ),
            onDelete: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return ConfirmationDialog(
                    message: '"${player.name}" 님을 참여 명단에서 제외하시겠습니까?',
                    confirmText: '제외',
                    isDestructive: true,
                    onConfirm: () {
                      playersProvider.removePlayer(player.id);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getRoleLabel(String roleValue) {
    try {
      return PlayerRole.values.firstWhere((e) => e.value == roleValue).label;
    } catch (_) {
      return roleValue;
    }
  }

  String _getGenderLabel(String genderValue, {bool isMobile = false}) {
    if (isMobile) {
      if (genderValue.startsWith('남')) return '남';
      if (genderValue.startsWith('여')) return '여';
      return genderValue;
    }
    if (genderValue == '남') return '남성';
    if (genderValue == '여') return '여성';
    return genderValue;
  }

  Color _getRoleColor(BuildContext context, String roleValue) {
    if (roleValue == 'manager') return Colors.orange;
    if (roleValue == 'user') return Colors.green;
    if (roleValue == 'guest') return Colors.grey;
    return Theme.of(context).colorScheme.onSurface;
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
            newGrade: result['grade'] as String,
            newGender: result['gender'] as String,
            newRole: (result['role'] as String?) ?? 'user',
            newPlayed: (result['played'] as int?) ?? 0,
            newWaited: (result['waited'] as int?) ?? 0,
            newLated: (result['lated'] as int?) ?? 0,
            newGroups: (result['groups'] as List<ObjectId>?) ?? [],
          );
        } else {
          int latedValue = 0;
          if (playersProvider.players.isNotEmpty) {
            final playedList =
                playersProvider.players.values.map((p) => p.played).toList()
                  ..sort();
            latedValue = playedList[playedList.length ~/ 3];
          }

          if (result['loaded'] as bool) {
            playersProvider.loadPlayer(
              result['player'],
              result['groups'] as List<ObjectId>,
              latedValue,
            );
          } else {
            playersProvider.addPlayer(
              name: result['name'] as String,
              rate: result['rate'] as int,
              grade: result['grade'] as String,
              gender: result['gender'] as String,
              role: result['role'] as String,
              played: 0,
              waited: 0,
              lated: latedValue,
              groups: result['groups'] as List<ObjectId>,
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _showClearAllPlayersConfirmationDialog(
    PlayersProvider playersProvider,
  ) async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmationDialog(
          message: '모든 참여자를 명단에서 제외하시겠습니까?',
          confirmText: '전체 제외',
          isDestructive: true,
          onConfirm: () {
            playersProvider.clearPlayers();
          },
        );
      },
    );
  }
}

