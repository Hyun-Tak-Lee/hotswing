import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/group_info.dart';

/// 대기 패널 내에서 선수 정보를 표시하는 위젯 (그룹 -> 이름 -> 성별 급수 -> 플레이 정보).
class DetailedPlayerContent extends StatelessWidget {
  final Player player;
  final GroupInfo? groupInfo;
  final double nameFontSize;
  final double skillFontSize;
  final double detailFontSize;
  final double spacing;
  final double availHeight;
  final String timeDisplay;
  final bool hasRemoveButton;
  final double removeBtnSize;
  final bool isTablet;

  const DetailedPlayerContent({
    super.key,
    required this.player,
    required this.groupInfo,
    required this.nameFontSize,
    required this.skillFontSize,
    required this.detailFontSize,
    required this.spacing,
    required this.availHeight,
    required this.timeDisplay,
    required this.hasRemoveButton,
    required this.removeBtnSize,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final textColor = courtColors.playerItemTextPrimary;
    final detailTextColor = courtColors.playerItemTextSecondary;
    final skillLevelDisplay = player.grade;

    // 우측 삭제(X) 버튼 침범을 방지하면서도 텍스트 크기와 정중앙 정렬을 보호하기 위해 여백 제한
    final double horizontalPadding = hasRemoveButton
        ? (isTablet ? 14.0 : 10.0)
        : (isTablet ? 8.0 : 6.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 상단/중앙 메인 정보: 이름 1행 + 성별급수/그룹 2행 (유연한 텍스트 크기)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1행: 이름 (단독, 최대 크기 지정)
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: availHeight < 120.0 ? 0.0 : 1.0,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      player.name,
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: (spacing * 0.5).clamp(3.0, 7.0)),
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
                            text: '${player.gender}  $skillLevelDisplay',
                            style: TextStyle(
                              color: courtColors.playerItemGenderText,
                            ),
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
          ),
        ),
        // 4. 최하단 부가 정보: 플레이 정보 (공간 부족 시 2줄로 자동 변환)
        Padding(
          padding: const EdgeInsets.only(bottom: 2.0, left: 4.0, right: 4.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double iconSize = (detailFontSize - 1.0).clamp(
                8.0,
                isTablet ? 19.0 : 13.0,
              );
              final double itemGap = isTablet ? 12.0 : 8.0;
              final double iconTextGap = isTablet ? 3.5 : 2.5;
              final TextStyle textStyle = TextStyle(
                fontSize: detailFontSize,
                color: detailTextColor,
                fontWeight: FontWeight.w600,
              );

              final String playedText =
                  '${player.played}${player.lated != 0 ? ' (+${player.lated})' : ''}';
              final String waitedText = '${player.waited}';

              // 1줄 배치 시 필요한 대략적인 최소 가로 너비 추정
              final int totalChars =
                  playedText.length + waitedText.length + timeDisplay.length;
              final double estimatedCharWidth = detailFontSize * 0.62;
              final double neededWidth =
                  (iconSize * 3) +
                  (iconTextGap * 3) +
                  (itemGap * 2) +
                  (totalChars * estimatedCharWidth);

              final bool shouldUseTwoRows =
                  constraints.maxWidth.isFinite &&
                  constraints.maxWidth < neededWidth;

              final Widget gameItem = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline_rounded,
                    size: iconSize,
                    color: detailTextColor,
                  ),
                  SizedBox(width: iconTextGap),
                  Text(playedText, style: textStyle),
                ],
              );

              final Widget waitItem = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hourglass_empty_rounded,
                    size: iconSize,
                    color: detailTextColor,
                  ),
                  SizedBox(width: iconTextGap),
                  Text(waitedText, style: textStyle),
                ],
              );

              final Widget timeItem = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: iconSize,
                    color: detailTextColor,
                  ),
                  SizedBox(width: iconTextGap),
                  Text(timeDisplay, style: textStyle),
                ],
              );

              if (shouldUseTwoRows) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          gameItem,
                          SizedBox(width: itemGap),
                          waitItem,
                        ],
                      ),
                      const SizedBox(height: 1.5),
                      timeItem,
                    ],
                  ),
                );
              }

              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    gameItem,
                    SizedBox(width: itemGap),
                    waitItem,
                    SizedBox(width: itemGap),
                    timeItem,
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
