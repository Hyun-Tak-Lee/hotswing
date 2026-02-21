import 'package:flutter/material.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/enums/player_feature.dart';

class PlayerListTile extends StatelessWidget {
  final Player player;
  final VoidCallback? onDelete;

  const PlayerListTile({super.key, required this.player, this.onDelete});

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

  String _getSkillLevel(int rate) {
    return rateToSkillLevel(rate);
  }

  Color _getRoleColor(String roleValue) {
    if (roleValue == 'manager') return Colors.orange;
    if (roleValue == 'user') return Colors.green;
    if (roleValue == 'guest') return Colors.grey;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final skillLevel = _getSkillLevel(player.rate);
    final isTablet = ResponsiveUtils.isTablet(context);

    final textScale = ResponsiveUtils.getTextScale(context);
    final baseFontSize = 14.0 * textScale;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
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
        title: Text(
          player.name,
          style: TextStyle(
            fontSize: baseFontSize + 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: isTablet
            ? null
            : Text(
                '${_getRoleLabel(player.role)} | ${_getGenderLabel(player.gender)}',
                style: TextStyle(fontSize: baseFontSize - 2),
              ),
        trailing: SizedBox(
          width: isTablet ? 400 : 120,
          child: isTablet
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildInfoTag(
                      _getRoleLabel(player.role),
                      _getRoleColor(player.role),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoTag(
                      _getGenderLabel(player.gender),
                      Colors.indigoAccent,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '급수: $skillLevel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: baseFontSize,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Rate: ${player.rate}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: baseFontSize,
                        color: Colors.black87,
                      ),
                    ),
                    if (onDelete != null) ...[
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
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
                        Text(
                          '급수: $skillLevel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: baseFontSize - 2,
                          ),
                        ),
                        Text(
                          'Rate: ${player.rate}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: baseFontSize - 4,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: onDelete,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
