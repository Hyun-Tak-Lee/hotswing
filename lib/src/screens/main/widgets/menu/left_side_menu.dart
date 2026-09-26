import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../../../providers/players_provider.dart';
import '../../../../common/widgets/tags/player_info_tag.dart';
import '../../../../common/widgets/tags/player_skill_rate.dart';
import '../../../../common/widgets/dialogs/add_player_dialog.dart';
import '../../../../common/widgets/dialogs/confirmation_dialog.dart';
import '../../../../common/utils/ui/responsive_utils.dart';
import '../../../../enums/player_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

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
            return _LeftSideMenuHeader(
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
          return _PlayerListItemTile(
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
            newRole: result['role'] as String,
            newPlayed: result['played'] as int,
            newWaited: result['waited'] as int,
            newGroups: result['groups'] as List<ObjectId>,
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

/// 좌측 서랍 헤더 위젯.
class _LeftSideMenuHeader extends StatelessWidget {
  const _LeftSideMenuHeader({
    required this.playerCount,
    required this.isMobile,
    required this.isTablet,
    required this.onClearAll,
    required this.onAddGuest,
    required this.onAddRegular,
  });

  final int playerCount;
  final bool isMobile;
  final bool isTablet;
  final VoidCallback onClearAll;
  final VoidCallback onAddGuest;
  final VoidCallback onAddRegular;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final double headerHeight = isTablet ? 160.0 : 110.0;
    final double titleFontSize = isTablet ? 22.0 : 17.0;
    final double iconSize = isTablet ? 26.0 : 20.0;
    final EdgeInsets buttonPadding = EdgeInsets.all(isMobile ? 5.0 : 8.0);

    return SizedBox(
      height: headerHeight,
      child: DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColors.gradientStart, baseColors.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '참여자 ($playerCount명)',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: baseColors.textPrimary,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: '전체 참여자 제외',
                  icon: const Icon(Icons.delete_sweep),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onClearAll,
                ),
                SizedBox(width: isMobile ? 4 : 8),
                IconButton(
                  tooltip: '게스트 추가',
                  icon: const Icon(Icons.person_pin),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onAddGuest,
                ),
                SizedBox(width: isMobile ? 4 : 8),
                IconButton(
                  tooltip: '일반 참여자 추가',
                  icon: const Icon(Icons.person_add),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onAddRegular,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 참여자 목록의 단일 항목 카드 위젯.
class _PlayerListItemTile extends StatelessWidget {
  const _PlayerListItemTile({
    required this.player,
    required this.groupInfo,
    required this.isMobile,
    required this.isTablet,
    required this.roleLabel,
    required this.roleColor,
    required this.genderLabel,
    required this.onToggleActivate,
    required this.onEdit,
    required this.onDelete,
  });

  final Player player;
  final dynamic groupInfo;
  final bool isMobile;
  final bool isTablet;
  final String roleLabel;
  final Color roleColor;
  final String genderLabel;
  final VoidCallback onToggleActivate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final double nameFontSize = isTablet ? 18.0 : 15.0;
    final double iconSize = isTablet ? 24.0 : 19.0;
    final EdgeInsets buttonPadding = EdgeInsets.all(isMobile ? 4.0 : 6.0);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 16.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: player.activate == false
              ? [
                  playerColors.playerItemInactive,
                  playerColors.playerItemInactive,
                ]
              : [
                  playerColors.playerItemActiveStart,
                  playerColors.playerItemActiveEnd,
                ],
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
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12.0 : 16.0,
          vertical: isMobile ? 10.0 : 12.0,
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
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                      color: baseColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PlayerInfoTag(text: roleLabel, color: roleColor),
                      PlayerInfoTag(
                        text: genderLabel,
                        color: Colors.indigoAccent,
                      ),
                      if (groupInfo != null)
                        PlayerInfoTag(
                          text: groupInfo.label,
                          color: groupInfo.color,
                        ),
                      if (isTablet)
                        PlayerSkillRateWidget(
                          skillLevel: player.grade,
                          rate: player.rate,
                        )
                      else
                        Text(
                          player.grade,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: playerColors.rateWidgetSkill,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: player.activate ? '비활성화' : '활성화',
                  icon: Icon(
                    player.activate ? Icons.block : Icons.check_circle_outline,
                  ),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onToggleActivate,
                ),
                IconButton(
                  tooltip: '수정',
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                ),
                IconButton(
                  tooltip: '제외',
                  icon: const Icon(Icons.delete_outline),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
