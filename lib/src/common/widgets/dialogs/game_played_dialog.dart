import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class GamePlayedDialog extends StatelessWidget {
  final Player player;
  final Map<String, int> gamesPlayedWithMap;
  final List<String> notPlayedWithNames;

  const GamePlayedDialog({
    super.key,
    required this.gamesPlayedWithMap,
    required this.player,
    required this.notPlayedWithNames,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final formColors = context.formColors;
    final dialogColors = context.dialogColors;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isMobile = ResponsiveUtils.isMobile(context);

    final textTheme = Theme.of(context).textTheme;
    final double dialogWidth = isMobile ? screenWidth * 0.9 : 500.0;
    final double dialogHeight = isMobile ? screenHeight * 0.5 : 400.0;

    // 반응형 스타일 정의
    final titleStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.headlineSmall,
    )?.copyWith(color: baseColors.textPrimary);
    final listTitleStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.titleMedium,
    )?.copyWith(fontWeight: FontWeight.bold, color: baseColors.textPrimary);
    final bodyStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.bodyLarge,
    )?.copyWith(color: baseColors.textPrimary);
    final subStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.bodyMedium,
    )?.copyWith(color: baseColors.textSecondary);
    final buttonStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.titleMedium,
    )?.copyWith(color: baseColors.textPrimary);

    final sortedNotPlayedWithNames = List<String>.from(notPlayedWithNames)
      ..sort();
    final bool hasNotPlayedWith = notPlayedWithNames.isNotEmpty;

    // 함께 플레이한 사람 정렬: 1순위 - 기록 낮은 순 (오름차순), 2순위 - 이름 가나다순
    final sortedEntries = gamesPlayedWithMap.entries.toList()
      ..sort((a, b) {
        final int countComparison = a.value.compareTo(b.value);
        if (countComparison != 0) return countComparison;
        return a.key.compareTo(b.key);
      });

    // 전적 항목 표현을 위한 소형 위젯 빌더
    Widget buildSummaryItem(String label, String value, Color valueColor) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: baseColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      );
    }

    // 요약 카드 내 수직 디바이더 빌더
    Widget buildSummaryDivider() {
      return Container(height: 24.0, width: 1.2, color: formColors.filterDivider);
    }

    // 상세 시간 포맷팅
    final String formattedPlayTime =
        '${player.playTime ~/ 60}분 ${player.playTime % 60}초';

    // 종합 대시보드 요약 카드 위젯 정의
    final playerSummaryCard = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: dialogColors.dialogSummaryBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: dialogColors.dialogSummaryBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildSummaryItem(
            '총 플레이',
            '${player.played}${player.lated != 0 ? ' (+${player.lated})' : ''}회',
            baseColors.primaryAccent,
          ),
          buildSummaryDivider(),
          buildSummaryItem(
            '누적 대기',
            '${player.waited}회',
            baseColors.textSecondary,
          ),
          buildSummaryDivider(),
          buildSummaryItem(
            '총 플레이 시간',
            formattedPlayTime,
            playerColors.genderTag,
          ),
        ],
      ),
    );

    return AlertDialog(
      backgroundColor: baseColors.cardBg,
      surfaceTintColor: Colors.transparent,
      title: Text('${player.name}님 상세 정보', style: titleStyle),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 상단 전적 요약 카드 고정 노출
            playerSummaryCard,
            const SizedBox(height: 16.0),
            // 2. 기존 이력 리스트로 이어지는 서브 타이틀
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
              child: Text('함께 플레이한 사람', style: listTitleStyle),
            ),
            // 3. 스크롤 가능한 히스토리 목록 리스트뷰
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  itemCount: sortedEntries.length + (hasNotPlayedWith ? 1 : 0),
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: formColors.filterDivider),
                  itemBuilder: (BuildContext context, int index) {
                    if (hasNotPlayedWith && index == 0) {
                      return ListTile(
                        dense: true,
                        title: Text('기록 없음', style: listTitleStyle),
                        subtitle: Text(
                          sortedNotPlayedWithNames.join(', '),
                          style: subStyle,
                        ),
                      );
                    } else {
                      final mapIndex = hasNotPlayedWith ? index - 1 : index;
                      final entry = sortedEntries[mapIndex];
                      return ListTile(
                        dense: true,
                        title: Text(entry.key, style: bodyStyle),
                        trailing: Text('${entry.value} 회', style: bodyStyle),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('닫기', style: buttonStyle),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
