import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/court_card.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

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

  const CourtSectionsView({
    super.key,
    required this.onPlayerDrop,
    required this.onCourtPlayerDragStarted,
    required this.onCourtPlayerDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    final sectionData = playersProvider.assignedPlayers;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: sectionData.asMap().entries.map((entry) {
              int sectionIndex = entry.key;
              List<Player?> item = entry.value;
              final playerCount = item.where((p) => p != null).length;
              bool isGameStarted = (playerCount == 4);

              return CourtCard(
                sectionIndex: sectionIndex,
                players: item,
                sectionKind: 'assigned',
                onPlayerDrop: onPlayerDrop,
                onCourtPlayerDragStarted: onCourtPlayerDragStarted,
                onCourtPlayerDragEnded: onCourtPlayerDragEnded,
                onPlayerRemoved: (courtIndex, playerIndex) {
                  final removed = playersProvider.removeAssignedPlayer(
                    courtIndex,
                    playerIndex,
                  );
                  if (removed != null) {
                    playersProvider.addUnassignedPlayer(removed);
                  }
                },
                headerActions: [
                  // 새로고침 버튼
                  _buildGradientButton(
                    isTablet: isTablet,
                    width: isTablet ? 50.0 : 40.0,
                    height: isTablet ? 45.0 : 30.0,
                    colors: [courtColors.btnRemoveStart, courtColors.btnRemoveEnd],
                    onTap: () {
                      playersProvider.movePlayersFromCourtToUnassigned(
                        sectionIndex: sectionIndex,
                        targetCourtKind: PlayerSectionKind.assigned.value,
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
                    )
                  else
                    _buildGradientButton(
                      isTablet: isTablet,
                      width: isTablet ? 150.0 : 90.0,
                      height: isTablet ? 45.0 : 30.0,
                      colors: [courtColors.btnFinishStart, courtColors.btnFinishEnd],
                      onTap: () {
                        playersProvider
                            .incrementWaitedTimeForAllUnassignedPlayers();
                        playersProvider.movePlayersFromCourtToUnassigned(
                          sectionIndex: sectionIndex,
                          targetCourtKind: PlayerSectionKind.assigned.value,
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
                    constraints: const BoxConstraints(
                      minWidth: 80,
                    ),
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
                      return List.generate(sectionData.length, (index) {
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
                      child: _buildGradientButton(
                        isTablet: isTablet,
                        width: isTablet ? 50.0 : 40.0,
                        height: isTablet ? 45.0 : 30.0,
                        colors: [courtColors.btnSwapStart, courtColors.btnSwapEnd],
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
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required bool isTablet,
    required double width,
    required double height,
    required List<Color> colors,
    required VoidCallback onTap,
    required Widget child,
  }) {
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
            color: colors.last.withAlpha(100), // 그림자는 끝 색상에 기반해 부드럽게
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

class AutoMatchSplitButton extends StatefulWidget {
  final bool isTablet;
  final List<Player?> item;
  final int sectionIndex;

  const AutoMatchSplitButton({
    super.key,
    required this.isTablet,
    required this.item,
    required this.sectionIndex,
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
    final playersProvider = Provider.of<PlayersProvider>(context);
    final standbyCourts = playersProvider.standbyPlayers;
    final hasFullStandby =
        standbyCourts.any((court) => court.every((p) => p != null));
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
              playersProvider.popStandByPlayerByIndex(widget.sectionIndex, idx);
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
      }).toList(),
      builder: (context, controller, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [courtColors.btnAutoMatchStart, courtColors.btnAutoMatchEnd],
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
                      playersProvider
                          .assignNextPlayersToAssignedCourt(widget.sectionIndex);
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
