import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
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
    final double iconSize = isTablet ? 28.0 : 21.0;
    final EdgeInsets buttonPadding = EdgeInsets.all(isTablet ? 10.0 : 7.0);
    final double minTouchTargetSize = isTablet ? 48.0 : 36.0;
    final double iconSpacing = isTablet ? 8.0 : 2.0;

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
        border: Border.all(
          color: player.role == 'manager'
              ? playerColors.roleManager.withValues(alpha: 0.75)
              : Colors.transparent,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: player.role == 'manager'
                ? playerColors.roleManager.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
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
                  _PlayerMetadataRow(
                    player: player,
                    groupInfo: groupInfo,
                    roleLabel: roleLabel,
                    roleColor: roleColor,
                    genderLabel: genderLabel,
                    isTablet: isTablet,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 2),
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
                  constraints: BoxConstraints(
                    minWidth: minTouchTargetSize,
                    minHeight: minTouchTargetSize,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: onToggleActivate,
                ),
                SizedBox(width: iconSpacing),
                IconButton(
                  tooltip: '수정',
                  icon: const Icon(Icons.edit_outlined),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: BoxConstraints(
                    minWidth: minTouchTargetSize,
                    minHeight: minTouchTargetSize,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: onEdit,
                ),
                SizedBox(width: iconSpacing),
                IconButton(
                  tooltip: '제외',
                  icon: const Icon(Icons.delete_outline),
                  iconSize: iconSize,
                  padding: buttonPadding,
                  constraints: BoxConstraints(
                    minWidth: minTouchTargetSize,
                    minHeight: minTouchTargetSize,
                  ),
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

/// 플레이어 메타데이터(게스트, 성별, 그룹, 등급/승률)를 가운뎃점(·)으로 연결하는 텍스트 위젯.
class _PlayerMetadataRow extends StatelessWidget {
  const _PlayerMetadataRow({
    required this.player,
    required this.groupInfo,
    required this.roleLabel,
    required this.roleColor,
    required this.genderLabel,
    required this.isTablet,
  });

  final Player player;
  final dynamic groupInfo;
  final String roleLabel;
  final Color roleColor;
  final String genderLabel;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final playerColors = context.playerColors;
    final courtColors = context.courtColors;
    final double subTextFontSize = isTablet ? 17.0 : 13.0;

    final List<Widget> items = [];

    if (player.role == 'guest') {
      items.add(
        Text(
          roleLabel,
          style: TextStyle(
            fontSize: subTextFontSize,
            color: roleColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    items.add(
      Text(
        genderLabel,
        style: TextStyle(
          fontSize: subTextFontSize,
          color: courtColors.playerItemGenderText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (groupInfo != null) {
      items.add(
        Text(
          groupInfo.label,
          style: TextStyle(
            fontSize: subTextFontSize,
            color: groupInfo.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    items.add(
      Text(
        player.grade,
        style: TextStyle(
          fontSize: subTextFontSize,
          color: playerColors.rateWidgetSkill,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (isTablet) {
      final double rateFontSize = (subTextFontSize * 0.82).clamp(9.0, 16.0);
      items.add(
        Text(
          player.rate.toString(),
          style: TextStyle(
            fontSize: rateFontSize,
            color: playerColors.rateWidgetValue,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final List<Widget> rowChildren = [];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) {
        final double spacing = (isTablet && i == items.length - 1) ? 3.5 : 8.0;
        rowChildren.add(SizedBox(width: spacing));
      }
      rowChildren.add(items[i]);
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: rowChildren,
      ),
    );
  }
}
