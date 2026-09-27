import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/widgets/tags/player_info_tag.dart';
import 'package:hotswing/src/common/widgets/tags/player_skill_rate.dart';
import 'package:hotswing/src/models/players/player.dart';

/// 참여자 목록의 단일 항목 카드 위젯.
class PlayerListItemTile extends StatelessWidget {
  const PlayerListItemTile({
    super.key,
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
    final double nameFontSize = isTablet ? 21.0 : 17.5;
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
