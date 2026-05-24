import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/group_info.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/tags/player_info_tag.dart';
import 'package:hotswing/src/common/widgets/tags/player_skill_rate.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';

class PlayerListTile extends StatelessWidget {
  final Player player;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PlayerListTile({
    super.key,
    required this.player,
    this.onDelete,
    this.onEdit,
  });

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


  Color _getRoleColor(PlayerColors playerColors, String roleValue) {
    if (roleValue == 'manager') return playerColors.roleManager;
    if (roleValue == 'user') return playerColors.roleUser;
    if (roleValue == 'guest') return playerColors.roleGuest;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final skillLevel = player.grade;
    final isTablet = ResponsiveUtils.isTablet(context);
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;

    final textScale = ResponsiveUtils.getTextScale(context);
    final baseFontSize = 14.0 * textScale;

    final playersProvider = Provider.of<PlayersProvider>(context);
    final groupInfo = playersProvider.getGroupInfo(player.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [playerColors.playerItemActiveStart, playerColors.playerItemActiveEnd],
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
      child: ListTile(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                player.name,
                style: TextStyle(
                  fontSize: baseFontSize + 2,
                  fontWeight: FontWeight.bold,
                  color: baseColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (groupInfo != null)
              _GroupBadge(
                label: groupInfo.label,
                color: groupInfo.color,
                fontSize: baseFontSize - 3.0,
              ),
          ],
        ),
        subtitle: isTablet
            ? null
            : Text(
                '${_getRoleLabel(player.role)} | ${_getGenderLabel(player.gender)}',
                style: TextStyle(
                  fontSize: baseFontSize - 2,
                  color: baseColors.textSecondary,
                ),
              ),
        trailing: SizedBox(
          width: isTablet ? 400 : 120,
          child: isTablet
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PlayerInfoTag(
                      text: _getRoleLabel(player.role),
                      color: _getRoleColor(playerColors, player.role),
                    ),
                    const SizedBox(width: 8),
                    PlayerInfoTag(
                      text: _getGenderLabel(player.gender),
                      color: playerColors.genderTag,
                    ),
                    const SizedBox(width: 16),
                    PlayerSkillRateWidget(
                      skillLevel: skillLevel,
                      rate: player.rate,
                    ),
                    if (onEdit != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.edit, color: baseColors.textSecondary),
                        onPressed: onEdit,
                      ),
                    ],
                    if (onDelete != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete, color: baseColors.textSecondary),
                        onPressed: onDelete,
                      ),
                    ],
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: PlayerSkillRateWidget(
                            skillLevel: skillLevel,
                            rate: player.rate,
                          ),
                        ),
                      ],
                    ),
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: baseColors.textSecondary,
                        ),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20,
                          color: baseColors.textSecondary,
                        ),
                        onPressed: onDelete,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _GroupBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const _GroupBadge({
    required this.label,
    required this.color,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Text(
        '그룹 $label',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
