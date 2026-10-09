import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/court_card.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/widgets/courts/assigned/assigned_gradient_button.dart';
import 'package:hotswing/src/common/widgets/courts/assigned/auto_match_split_button.dart';
import 'package:hotswing/src/common/widgets/waiting/waiting_players_bottom_sheet.dart';

/// 배정된 진행 코트들의 목록을 반응형(가로/세로)으로 배치하여 렌더링하는 위젯.
class CourtSectionsView extends StatelessWidget {
  final Function(
    BuildContext,
    PlayerDragData,
    Player?,
    dynamic,
    String,
    int,
    int,
  )
  onPlayerDrop;
  final VoidCallback onCourtPlayerDragStarted;
  final VoidCallback onCourtPlayerDragEnded;
  final bool isClubMatch;

  const CourtSectionsView({
    super.key,
    required this.onPlayerDrop,
    required this.onCourtPlayerDragStarted,
    required this.onCourtPlayerDragEnded,
    this.isClubMatch = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);
    final playersProvider = context.watch<PlayersProvider>();
    final sectionData = playersProvider.assignedPlayers;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeight = constraints.maxHeight;
        final double courtWidth = isLandscape
            ? (isTablet
                  ? ((maxHeight - 66.0) * 1.15 + 20.0).clamp(380.0, 520.0)
                  : ((maxHeight - 54.0) * 1.05 + 20.0).clamp(260.0, 360.0))
            : (constraints.maxWidth - 20.0);

        final double courtHeight = isLandscape
            ? maxHeight
            : (isTablet
                  ? (courtWidth * 0.95).clamp(320.0, 500.0)
                  : (courtWidth * 0.95).clamp(260.0, 380.0));

        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              scrollDirection: isLandscape ? Axis.horizontal : Axis.vertical,
              child: isLandscape
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: sectionData.asMap().entries.map((entry) {
                        int sectionIndex = entry.key;
                        List<Player?> item = entry.value;
                        final playerCount = item.where((p) => p != null).length;
                        bool isGameStarted = (playerCount == 4);
                        final isFinishing = playersProvider.isCourtFinishing(
                          sectionIndex,
                        );

                        return SizedBox(
                          width: courtWidth,
                          height: isLandscape ? maxHeight : null,
                          child: CourtCard(
                            sectionIndex: sectionIndex,
                            players: item,
                            sectionKind: 'assigned',
                            onPlayerDrop: onPlayerDrop,
                            onCourtPlayerDragStarted: onCourtPlayerDragStarted,
                            onCourtPlayerDragEnded: onCourtPlayerDragEnded,
                            onPlayerRemoved: (courtIndex, playerIndex) {
                              final removed = playersProvider
                                  .removeAssignedPlayer(
                                    courtIndex,
                                    playerIndex,
                                  );
                              if (removed != null) {
                                playersProvider.addUnassignedPlayer(removed);
                              }
                            },
                            onEmptySlotTap: (courtIndex, slotIndex) =>
                                _handleEmptySlotTap(
                                  context: context,
                                  courtIndex: courtIndex,
                                  slotIndex: slotIndex,
                                ),
                            headerActions: [
                              // 새로고침 버튼
                              AssignedGradientButton(
                                width: isTablet ? 50.0 : 40.0,
                                height: isTablet ? 45.0 : 30.0,
                                colors: [
                                  courtColors.btnRemoveStart,
                                  courtColors.btnRemoveEnd,
                                ],
                                onTap: () {
                                  playersProvider
                                      .movePlayersFromCourtToUnassigned(
                                        sectionIndex: sectionIndex,
                                        targetCourtKind:
                                            PlayerSectionKind.assigned.value,
                                        played: 0,
                                      );
                                },
                                child: Icon(
                                  Icons.group_remove,
                                  size: isTablet ? 24.0 : 18.0,
                                  color: Colors.white,
                                ),
                              ),
                              // 자동 매칭 / 경기 종료 버튼
                              if (!isGameStarted)
                                AutoMatchSplitButton(
                                  isTablet: isTablet,
                                  item: item,
                                  sectionIndex: sectionIndex,
                                  isClubMatch: isClubMatch,
                                )
                              else
                                AssignedGradientButton(
                                  width: isTablet ? 150.0 : 90.0,
                                  height: isTablet ? 45.0 : 30.0,
                                  colors: [
                                    courtColors.btnFinishStart,
                                    courtColors.btnFinishEnd,
                                  ],
                                  isLoading: isFinishing,
                                  onTap: () => context
                                      .read<PlayersProvider>()
                                      .finishCourtMatch(
                                        sectionIndex: sectionIndex,
                                      ),
                                  child: Text(
                                    '경기 종료',
                                    style: TextStyle(
                                      fontSize: isTablet ? 20.0 : 12.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              PopupMenuButton<int>(
                                tooltip: '코트 이동/교환',
                                color: baseColors.cardBg,
                                elevation: 6,
                                position: PopupMenuPosition.under,
                                offset: const Offset(0, 4),
                                constraints: const BoxConstraints(minWidth: 80),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (int targetIndex) {
                                  playersProvider.swapAssignedCourts(
                                    sectionIndex,
                                    targetIndex,
                                  );
                                },
                                itemBuilder: (BuildContext context) {
                                  return List.generate(sectionData.length, (
                                    index,
                                  ) {
                                    if (index == sectionIndex) return null;
                                    return PopupMenuItem<int>(
                                      value: index,
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.swap_horiz_rounded,
                                            color: baseColors.primaryAccent,
                                            size: isTablet ? 24 : 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${index + 1}번 코트와 교환',
                                            style: TextStyle(
                                              fontSize: isTablet ? 16.0 : 14.0,
                                              color: baseColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).whereType<PopupMenuEntry<int>>().toList();
                                },
                                child: IgnorePointer(
                                  child: AssignedGradientButton(
                                    width: isTablet ? 50.0 : 40.0,
                                    height: isTablet ? 45.0 : 30.0,
                                    colors: [
                                      courtColors.btnSwapStart,
                                      courtColors.btnSwapEnd,
                                    ],
                                    onTap: () {},
                                    child: Icon(
                                      Icons.swap_horiz,
                                      size: isTablet ? 24.0 : 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                  : Column(
                      children: sectionData.asMap().entries.map((entry) {
                        int sectionIndex = entry.key;
                        List<Player?> item = entry.value;
                        final playerCount = item.where((p) => p != null).length;
                        bool isGameStarted = (playerCount == 4);
                        final isFinishing = playersProvider.isCourtFinishing(
                          sectionIndex,
                        );

                        return SizedBox(
                          width: courtWidth,
                          height: courtHeight,
                          child: CourtCard(
                            sectionIndex: sectionIndex,
                            players: item,
                            sectionKind: 'assigned',
                            onPlayerDrop: onPlayerDrop,
                            onCourtPlayerDragStarted: onCourtPlayerDragStarted,
                            onCourtPlayerDragEnded: onCourtPlayerDragEnded,
                            onPlayerRemoved: (courtIndex, playerIndex) {
                              final removed = playersProvider
                                  .removeAssignedPlayer(
                                    courtIndex,
                                    playerIndex,
                                  );
                              if (removed != null) {
                                playersProvider.addUnassignedPlayer(removed);
                              }
                            },
                            onEmptySlotTap: (courtIndex, slotIndex) =>
                                _handleEmptySlotTap(
                                  context: context,
                                  courtIndex: courtIndex,
                                  slotIndex: slotIndex,
                                ),
                            headerActions: [
                              // 새로고침 버튼
                              AssignedGradientButton(
                                width: isTablet ? 50.0 : 40.0,
                                height: isTablet ? 45.0 : 30.0,
                                colors: [
                                  courtColors.btnRemoveStart,
                                  courtColors.btnRemoveEnd,
                                ],
                                onTap: () {
                                  playersProvider
                                      .movePlayersFromCourtToUnassigned(
                                        sectionIndex: sectionIndex,
                                        targetCourtKind:
                                            PlayerSectionKind.assigned.value,
                                        played: 0,
                                      );
                                },
                                child: Icon(
                                  Icons.group_remove,
                                  size: isTablet ? 24.0 : 18.0,
                                  color: Colors.white,
                                ),
                              ),
                              // 자동 매칭 / 경기 종료 버튼
                              if (!isGameStarted)
                                AutoMatchSplitButton(
                                  isTablet: isTablet,
                                  item: item,
                                  sectionIndex: sectionIndex,
                                  isClubMatch: isClubMatch,
                                )
                              else
                                AssignedGradientButton(
                                  width: isTablet ? 150.0 : 90.0,
                                  height: isTablet ? 45.0 : 30.0,
                                  colors: [
                                    courtColors.btnFinishStart,
                                    courtColors.btnFinishEnd,
                                  ],
                                  isLoading: isFinishing,
                                  onTap: () => context
                                      .read<PlayersProvider>()
                                      .finishCourtMatch(
                                        sectionIndex: sectionIndex,
                                      ),
                                  child: Text(
                                    '경기 종료',
                                    style: TextStyle(
                                      fontSize: isTablet ? 20.0 : 12.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              PopupMenuButton<int>(
                                tooltip: '코트 이동/교환',
                                color: baseColors.cardBg,
                                elevation: 6,
                                position: PopupMenuPosition.under,
                                offset: const Offset(0, 4),
                                constraints: const BoxConstraints(minWidth: 80),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (int targetIndex) {
                                  playersProvider.swapAssignedCourts(
                                    sectionIndex,
                                    targetIndex,
                                  );
                                },
                                itemBuilder: (BuildContext context) {
                                  return List.generate(sectionData.length, (
                                    index,
                                  ) {
                                    if (index == sectionIndex) return null;
                                    return PopupMenuItem<int>(
                                      value: index,
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.swap_horiz_rounded,
                                            color: baseColors.primaryAccent,
                                            size: isTablet ? 24 : 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${index + 1}번 코트와 교환',
                                            style: TextStyle(
                                              fontSize: isTablet ? 16.0 : 14.0,
                                              color: baseColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).whereType<PopupMenuEntry<int>>().toList();
                                },
                                child: IgnorePointer(
                                  child: AssignedGradientButton(
                                    width: isTablet ? 50.0 : 40.0,
                                    height: isTablet ? 45.0 : 30.0,
                                    colors: [
                                      courtColors.btnSwapStart,
                                      courtColors.btnSwapEnd,
                                    ],
                                    onTap: () {},
                                    child: Icon(
                                      Icons.swap_horiz,
                                      size: isTablet ? 24.0 : 18.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // Private Helper Methods
  // ==========================================

  Future<void> _handleEmptySlotTap({
    required BuildContext context,
    required int courtIndex,
    required int slotIndex,
  }) async {
    final selectedPlayer = await WaitingPlayersBottomSheet.show(
      context: context,
      title: '${courtIndex + 1} 코트 선수 추가',
    );
    if (selectedPlayer == null || !context.mounted) return;
    context.read<PlayersProvider>().assignUnassignedPlayer(
      player: selectedPlayer,
      targetSectionKind: PlayerSectionKind.assigned.value,
      targetSectionIndex: courtIndex,
      targetSubIndex: slotIndex,
    );
  }
}
