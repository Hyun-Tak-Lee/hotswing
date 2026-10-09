import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/providers/players_provider.dart';

/// 특정 선수의 경기 횟수, 대기 횟수, 총 경기 시간 및 함께 경기한 선수 통계를 표시하는 상세 다이얼로그.
class GamePlayedDialog extends StatelessWidget {
  /// 상세 정보를 조회할 대상 선수.
  final Player player;

  /// 함께 경기한 상대방들의 이름과 경기 수 매핑.
  final Map<String, int> gamesPlayedWithMap;

  /// 아직 한 번도 함께 경기하지 않은 선수들의 이름 목록.
  final List<String> notPlayedWithNames;

  /// [GamePlayedDialog] 생성자.
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
    final courtColors = context.courtColors;

    final playersProvider = context.watch<PlayersProvider>();
    final groupInfo = playersProvider.getGroupInfo(player.id);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isMobile = ResponsiveUtils.isMobile(context);

    final textTheme = Theme.of(context).textTheme;
    final double dialogWidth = isMobile ? screenWidth * 0.9 : 500.0;
    final double dialogHeight = isMobile ? screenHeight * 0.5 : 400.0;

    // 반응형 스타일 정의
    final isTablet = ResponsiveUtils.isTablet(context);
    final double titleFontSize = isTablet ? 21.0 : 17.0;
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

    // 상세 시간 포맷팅 (1시간 이상 시 시간 단위 추가)
    final int totalPlaySeconds = player.playTime;
    final String formattedPlayTime;
    if (totalPlaySeconds >= 3600) {
      final int hours = totalPlaySeconds ~/ 3600;
      final int minutes = (totalPlaySeconds % 3600) ~/ 60;
      final int seconds = totalPlaySeconds % 60;
      formattedPlayTime = '$hours시간 $minutes분 $seconds초';
    } else {
      formattedPlayTime =
          '${totalPlaySeconds ~/ 60}분 ${totalPlaySeconds % 60}초';
    }
    // 종합 대시보드 요약 카드 위젯 정의
    final playerSummaryCard = Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 10.0 : 12.0,
        horizontal: isTablet ? 12.0 : 16.0,
      ),
      decoration: BoxDecoration(
        color: dialogColors.dialogSummaryBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: dialogColors.dialogSummaryBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PlaySummaryItem(
              label: '경기 횟수',
              value:
                  '${player.played}${player.lated != 0 ? ' (+${player.lated})' : ''}회',
              labelColor: baseColors.textSecondary,
              valueColor: baseColors.primaryAccent,
            ),
          ),
          _PlaySummaryDivider(color: formColors.filterDivider),
          Expanded(
            child: _PlaySummaryItem(
              label: '대기 횟수',
              value: '${player.waited}회',
              labelColor: baseColors.textSecondary,
              valueColor: baseColors.textSecondary,
            ),
          ),
          _PlaySummaryDivider(color: formColors.filterDivider),
          Expanded(
            child: _PlaySummaryItem(
              label: '경기 시간',
              value: formattedPlayTime,
              labelColor: baseColors.textSecondary,
              valueColor: playerColors.genderTag,
            ),
          ),
        ],
      ),
    );

    return AlertDialog(
      backgroundColor: baseColors.cardBg,
      surfaceTintColor: Colors.transparent,
      contentPadding: isTablet
          ? const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 16.0)
          : const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              player.name,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: baseColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            '${player.gender}  ${player.grade} (${player.rate})',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: courtColors.playerItemGenderText,
            ),
          ),
          if (groupInfo != null) ...[
            const SizedBox(width: 8.0),
            Text(
              groupInfo.label,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: groupInfo.color,
              ),
            ),
          ],
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 상단 전적 요약 카드 고정 노출
            playerSummaryCard,
            SizedBox(height: isTablet ? 12.0 : 16.0),
            // 2. 기존 이력 리스트로 이어지는 서브 타이틀
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
              child: Text('경기 이력', style: listTitleStyle),
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

class _PlaySummaryItem extends StatelessWidget {
  const _PlaySummaryItem({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTablet ? 17.0 : 12.0,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4.0),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 23.0 : 15.0,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaySummaryDivider extends StatelessWidget {
  const _PlaySummaryDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    return Container(height: isTablet ? 28.0 : 24.0, width: 1.2, color: color);
  }
}
