import 'package:flutter/material.dart';
import 'package:hotswing/src/common/constants/player_constants.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/widgets/waiting/waiting_sort_menu.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/group_info.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

/// 모바일 환경에서 코트 빈 슬롯에 대기 선수를 배정하기 위한 바텀시트 위젯.
class WaitingPlayersBottomSheet extends StatefulWidget {
  /// 바텀시트 상단 타이틀 (예: '1 코트 선수 추가').
  final String title;

  const WaitingPlayersBottomSheet({super.key, required this.title});

  /// 바텀시트를 표시하고 선택된 [Player]를 반환하는 정적 메서드.
  static Future<Player?> show({
    required BuildContext context,
    required String title,
  }) {
    return showModalBottomSheet<Player>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => WaitingPlayersBottomSheet(title: title),
    );
  }

  @override
  State<WaitingPlayersBottomSheet> createState() =>
      _WaitingPlayersBottomSheetState();
}

class _WaitingPlayersBottomSheetState extends State<WaitingPlayersBottomSheet> {
  SortCriterion _sortCriterion = SortCriterion.played;

  @override
  void initState() {
    super.initState();
    // 태블릿 대기 패널과 동일한 키값으로 정렬 순서를 불러와 공유
    SharedProvider().getString(PlayerConstants.waitingSortCriterionKey).then((
      val,
    ) {
      if (mounted && val != null) {
        setState(() {
          _sortCriterion = val == 'name'
              ? SortCriterion.name
              : SortCriterion.played;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final playersProvider = context.watch<PlayersProvider>();
    final playerList = playersProvider.getSortedUnassignedPlayers(
      criterion: _sortCriterion,
      ascending: true,
    );
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.52;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 16.0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
        children: [
          const _BottomSheetDragHandle(),
          _BottomSheetHeader(
            title: widget.title,
            count: playerList.length,
            sortCriterion: _sortCriterion,
            onSortChanged: _handleSortChanged,
          ),
          Divider(height: 1.0, color: courtColors.homeDivider),
          Expanded(
            child: playerList.isEmpty
                ? const _EmptyWaitingPlayerView()
                : ListView.builder(
                    padding: EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0 + bottomInset,
                    ),
                    itemCount: playerList.length,
                    itemBuilder: (context, index) {
                      final player = playerList[index];
                      final groupInfo = playersProvider.getGroupInfo(player.id);
                      return _WaitingPlayerCard(
                        player: player,
                        groupInfo: groupInfo,
                        onTap: () => Navigator.of(context).pop(player),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Private Helper Methods
  // ==========================================

  void _handleSortChanged(SortCriterion criterion) {
    if (_sortCriterion != criterion) {
      setState(() {
        _sortCriterion = criterion;
      });
    }
    // 태블릿 대기 패널과 동일한 키값으로 저장하여 재접속 및 화면 간 동기화 유지
    SharedProvider().saveString(
      PlayerConstants.waitingSortCriterionKey,
      criterion.name,
    );
  }
}

class _BottomSheetDragHandle extends StatelessWidget {
  const _BottomSheetDragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.0,
      height: 4.0,
      margin: const EdgeInsets.only(top: 10.0, bottom: 6.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(80),
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }
}

class _BottomSheetHeader extends StatelessWidget {
  final String title;
  final int count;
  final SortCriterion sortCriterion;
  final ValueChanged<SortCriterion> onSortChanged;

  const _BottomSheetHeader({
    required this.title,
    required this.count,
    required this.sortCriterion,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 3.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              '$count명',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const Spacer(),
          WaitingSortMenu(
            isTablet: false,
            sortCriterion: sortCriterion,
            onSortSelected: onSortChanged,
            borderRadius: 12.0,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withAlpha(150),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 20.0,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    sortCriterion == SortCriterion.name ? '이름순' : '경기순',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 24.0),
            onPressed: () => Navigator.of(context).pop(),
            constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
            padding: const EdgeInsets.all(10.0),
            tooltip: '닫기',
          ),
        ],
      ),
    );
  }
}

class _EmptyWaitingPlayerView extends StatelessWidget {
  const _EmptyWaitingPlayerView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 40.0,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8.0),
          Text(
            '대기 중인 선수가 없습니다.',
            style: TextStyle(
              fontSize: 14.0,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// 참여자 목록 및 회원 목록 카드 스타일을 적용한 대기 선수 항목 카드 위젯.
class _WaitingPlayerCard extends StatelessWidget {
  final Player player;
  final GroupInfo? groupInfo;
  final VoidCallback onTap;

  const _WaitingPlayerCard({
    required this.player,
    required this.groupInfo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final courtColors = context.courtColors;
    final isManager = player.role == 'manager';

    final String genderLabel = player.gender == 'M' ? '남' : '여';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
          color: isManager
              ? playerColors.roleManager.withValues(alpha: 0.75)
              : Colors.transparent,
          width: 1.6,
        ),
        boxShadow: [
          BoxShadow(
            color: isManager
                ? playerColors.roleManager.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1층: 이름 + 그룹(텍스트) + 게스트(텍스트) - 바닥선(Baseline) 기준 정렬
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              player.name,
                              style: TextStyle(
                                fontSize: 20.5,
                                fontWeight: FontWeight.bold,
                                color: baseColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (groupInfo != null &&
                              groupInfo!.label.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              groupInfo!.label,
                              style: TextStyle(
                                fontSize: 14.5,
                                color: groupInfo!.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (player.role == 'guest') ...[
                            const SizedBox(width: 8),
                            Text(
                              '게스트',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: playerColors.roleGuest,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 2층: 성별, 급수, 경기(+lated), 대기 (Rate 제거 및 시원한 크기 적용)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              genderLabel,
                              style: TextStyle(
                                fontSize: 15.5,
                                color: courtColors.playerItemGenderText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${player.grade}급',
                              style: TextStyle(
                                fontSize: 15.5,
                                color: playerColors.rateWidgetSkill,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${player.played}${player.lated != 0 ? ' (+${player.lated})' : ''}경기',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: baseColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${player.waited}대기',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: baseColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 우측 추가 버튼
                Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 20.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
