import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/court_card.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

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
                            headerActions: [
                              // 새로고침 버튼
                              _AssignedGradientButton(
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
                                _AssignedGradientButton(
                                  width: isTablet ? 150.0 : 90.0,
                                  height: isTablet ? 45.0 : 30.0,
                                  colors: [
                                    courtColors.btnFinishStart,
                                    courtColors.btnFinishEnd,
                                  ],
                                  onTap: () {
                                    playersProvider
                                        .incrementWaitedTimeForAllUnassignedPlayers();
                                    playersProvider
                                        .movePlayersFromCourtToUnassigned(
                                          sectionIndex: sectionIndex,
                                          targetCourtKind:
                                              PlayerSectionKind.assigned.value,
                                        );
                                  },
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
                                  child: _AssignedGradientButton(
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
                            headerActions: [
                              // 새로고침 버튼
                              _AssignedGradientButton(
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
                                _AssignedGradientButton(
                                  width: isTablet ? 150.0 : 90.0,
                                  height: isTablet ? 45.0 : 30.0,
                                  colors: [
                                    courtColors.btnFinishStart,
                                    courtColors.btnFinishEnd,
                                  ],
                                  onTap: () {
                                    playersProvider
                                        .incrementWaitedTimeForAllUnassignedPlayers();
                                    playersProvider
                                        .movePlayersFromCourtToUnassigned(
                                          sectionIndex: sectionIndex,
                                          targetCourtKind:
                                              PlayerSectionKind.assigned.value,
                                        );
                                  },
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
                                  child: _AssignedGradientButton(
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
}

/// 자동 추천 매칭 실행 또는 대기 코트 팀 승격을 선택할 수 있는 스플릿 드롭다운 버튼 위젯.
class AutoMatchSplitButton extends StatefulWidget {
  final bool isTablet;
  final List<Player?> item;
  final int sectionIndex;
  final bool isClubMatch;

  const AutoMatchSplitButton({
    super.key,
    required this.isTablet,
    required this.item,
    required this.sectionIndex,
    this.isClubMatch = false,
  });

  @override
  State<AutoMatchSplitButton> createState() => _AutoMatchSplitButtonState();
}

class _AutoMatchSplitButtonState extends State<AutoMatchSplitButton> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;
    final playersProvider = context.watch<PlayersProvider>();
    final standbyCourts = playersProvider.standbyPlayers;
    final hasFullStandby = standbyCourts.any(
      (court) => court.every((p) => p != null),
    );
    final isCourtEmpty = widget.item.every((p) => p == null);

    final width = widget.isTablet ? 160.0 : 110.0;
    final height = widget.isTablet ? 45.0 : 30.0;

    return MenuAnchor(
      controller: _menuController,
      style: MenuStyle(
        minimumSize: WidgetStatePropertyAll(Size(width, 0)),
        maximumSize: WidgetStatePropertyAll(Size(width, double.infinity)),
        backgroundColor: WidgetStatePropertyAll(baseColors.cardBg),
        elevation: const WidgetStatePropertyAll(8),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
      menuChildren: standbyCourts
          .asMap()
          .entries
          .where((e) => e.value.every((p) => p != null))
          .map((entry) {
            int idx = entry.key;
            return SizedBox(
              width: width,
              child: MenuItemButton(
                style: MenuItemButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: Size(width, 48),
                ),
                onPressed: () {
                  playersProvider.popStandByPlayerByIndex(
                    widget.sectionIndex,
                    idx,
                  );
                },
                leadingIcon: Icon(
                  Icons.login,
                  color: Colors.green.shade400,
                  size: widget.isTablet ? 24 : 18,
                ),
                child: Text(
                  '대기 ${idx + 1}번팀',
                  style: TextStyle(
                    fontSize: widget.isTablet ? 16 : 13,
                    fontWeight: FontWeight.w600,
                    color: baseColors.textPrimary,
                  ),
                ),
              ),
            );
          })
          .toList(),
      builder: (context, controller, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                courtColors.btnAutoMatchStart,
                courtColors.btnAutoMatchEnd,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: courtColors.btnAutoMatchEnd.withAlpha(100),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: Row(
              children: [
                // 왼쪽: 자동 매칭 액션 영역
                Expanded(
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    ),
                    onTap: () {
                      playersProvider.assignNextPlayersToAssignedCourt(
                        widget.sectionIndex,
                        isClubMatch: widget.isClubMatch,
                      );
                    },
                    child: Center(
                      child: Text(
                        '자동 매칭',
                        style: TextStyle(
                          fontSize: widget.isTablet ? 18.0 : 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // 구분선
                VerticalDivider(
                  color: Colors.white.withAlpha(100),
                  width: 1,
                  thickness: 1,
                  indent: 8,
                  endIndent: 8,
                ),
                // 오른쪽: 드롭다운 화살표 영역
                InkWell(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                  onTap: (hasFullStandby && isCourtEmpty)
                      ? () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: widget.isTablet ? 40.0 : 30.0,
                    height: double.infinity,
                    child: Center(
                      child: Icon(
                        controller.isOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: (hasFullStandby && isCourtEmpty)
                            ? Colors.white
                            : Colors.white.withAlpha(100),
                        size: widget.isTablet ? 28 : 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AssignedGradientButton extends StatelessWidget {
  const _AssignedGradientButton({
    required this.width,
    required this.height,
    required this.colors,
    required this.onTap,
    required this.child,
  });

  final double width;
  final double height;
  final List<Color> colors;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withAlpha(100),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15.0),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}
