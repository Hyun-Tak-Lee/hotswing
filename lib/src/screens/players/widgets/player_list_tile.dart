import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/tags/player_skill_rate.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';

/// 플레이어 목록 화면에서 개별 플레이어의 상세 정보를 보여주는 리스트 타일 위젯.
class PlayerListTile extends StatelessWidget {
  /// 표시할 플레이어 객체.
  final Player player;

  /// 삭제 버튼 클릭 시 호출되는 콜백.
  final VoidCallback? onDelete;

  /// 수정 버튼 클릭 시 호출되는 콜백.
  final VoidCallback? onEdit;

  /// [PlayerListTile] 생성자.
  const PlayerListTile({
    super.key,
    required this.player,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final skillLevel = player.grade;
    final isTablet = ResponsiveUtils.isTablet(context);
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;

    final textScale = ResponsiveUtils.getTextScale(context);
    final baseFontSize = 14.0 * textScale;
    final skillRateFontSize = isTablet ? 21.0 : 17.5;

    final playersProvider = context.watch<PlayersProvider>();
    final groupInfo = playersProvider.getGroupInfo(player.id);

    final optionsProvider = context.watch<OptionsProvider>();
    final remainingDays = _calculateRemainingDays(
      player.recentMatchDate,
      optionsProvider.inactiveDaysThreshold,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 좌측: 1층 이름 [그룹] / 2층 role · 성별
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1층: 이름 (단독 배치로 긴 이름도 잘림 없이 가용 공간 최대 확보)
                Text(
                  player.name,
                  style: TextStyle(
                    fontSize: baseFontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: baseColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // 2층: 게스트(해당 시) · 성별 · 그룹 (가운뎃점 텍스트 방식)
                _PlayerMetadataText(
                  player: player,
                  groupInfo: groupInfo,
                  roleLabel: _getRoleLabel(player.role),
                  roleColor: _getRoleColor(playerColors, player.role),
                  genderLabel: _getGenderLabel(player.gender),
                  fontSize: isTablet
                      ? (baseFontSize - 1.0)
                      : (baseFontSize - 2.0),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 우측 (1,2층 통합 세로 중앙): [D-nn] + 등급(모바일은 등급만, 태블릿은 등급+Rate) + 편집/삭제 버튼
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RetentionBadge(remainingDays: remainingDays),
              const SizedBox(width: 8),
              PlayerSkillRateWidget(
                skillLevel: skillLevel,
                rate: player.rate,
                fontSize: skillRateFontSize,
                rateFontSize: skillRateFontSize,
              ),
              const SizedBox(width: 4),
              if (onEdit != null)
                IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  icon: Icon(
                    Icons.edit,
                    size: isTablet ? 20 : 18,
                    color: baseColors.textSecondary,
                  ),
                  onPressed: onEdit,
                ),
              if (onDelete != null)
                IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  icon: Icon(
                    Icons.delete,
                    size: isTablet ? 20 : 18,
                    color: baseColors.textSecondary,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
        ],
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

  int _calculateRemainingDays(DateTime? lastMatchDate, int thresholdDays) {
    if (lastMatchDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final matchDate = DateTime(
      lastMatchDate.year,
      lastMatchDate.month,
      lastMatchDate.day,
    );
    final elapsedDays = today.difference(matchDate).inDays;
    final remainingDays = thresholdDays - elapsedDays;
    return remainingDays < 0 ? 0 : remainingDays;
  }
}

/// 플레이어 메타데이터(게스트, 성별, 그룹)를 가운뎃점(·)으로 연결하는 텍스트 위젯.
class _PlayerMetadataText extends StatelessWidget {
  final Player player;
  final dynamic groupInfo;
  final String roleLabel;
  final Color roleColor;
  final String genderLabel;
  final double fontSize;

  const _PlayerMetadataText({
    required this.player,
    required this.groupInfo,
    required this.roleLabel,
    required this.roleColor,
    required this.genderLabel,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;
    final List<Widget> items = [];

    if (player.role == 'guest') {
      items.add(
        Text(
          roleLabel,
          style: TextStyle(
            fontSize: fontSize,
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
          fontSize: fontSize,
          color: courtColors.playerItemGenderText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (groupInfo != null) {
      items.add(
        Text(
          '그룹 ${groupInfo.label}',
          style: TextStyle(
            fontSize: fontSize,
            color: groupInfo.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: items,
    );
  }
}

class _RetentionBadge extends StatelessWidget {
  final int remainingDays;

  const _RetentionBadge({required this.remainingDays});

  @override
  Widget build(BuildContext context) {
    final displayDays = remainingDays < 0 ? 0 : remainingDays;
    final color = context.playerColors.genderTag;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Text(
        'D-$displayDays',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
