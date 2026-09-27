import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/group_info.dart';

/// 코트 패널 내에서 선수 정보를 간소화(이름, 그룹, 급수, 성별)하여 표시하는 위젯.
class SimplifiedPlayerContent extends StatelessWidget {
  final Player player;
  final GroupInfo? groupInfo;
  final double nameFontSize;
  final double skillFontSize;
  final double spacing;
  final double availHeight;
  final bool hasRemoveButton;
  final double removeBtnSize;
  final bool isTablet;

  const SimplifiedPlayerContent({
    super.key,
    required this.player,
    required this.groupInfo,
    required this.nameFontSize,
    required this.skillFontSize,
    required this.spacing,
    required this.availHeight,
    required this.hasRemoveButton,
    required this.removeBtnSize,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;

    // 우측 삭제(X) 버튼 침범을 방지하면서도 텍스트 크기와 정중앙 정렬을 보호하기 위해 여백 제한
    final double horizontalPadding = hasRemoveButton
        ? (isTablet ? 14.0 : 10.0)
        : (isTablet ? 8.0 : 6.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        // 1행: 이름
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: availHeight < 100.0 ? 0.0 : 1.0,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                player.name,
                style: TextStyle(
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.bold,
                  color: courtColors.playerItemTextPrimary,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        SizedBox(height: (spacing * 0.6).clamp(3.0, 8.0)),
        // 2행: 성별 급수 + 그룹 (급수 뒤에 그룹 배치)
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: skillFontSize,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(
                      text: '${player.gender}  ${player.grade}',
                      style: TextStyle(color: courtColors.playerItemGenderText),
                    ),
                    if (groupInfo != null) ...[
                      const TextSpan(text: '   '),
                      TextSpan(
                        text: groupInfo!.label,
                        style: TextStyle(color: groupInfo!.color),
                      ),
                    ],
                  ],
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
