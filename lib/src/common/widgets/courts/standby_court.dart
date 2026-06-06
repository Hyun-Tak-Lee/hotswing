import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/court_card.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class StandbyCourtSectionsView extends StatelessWidget {
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

  const StandbyCourtSectionsView({
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
    final playersProvider = Provider.of<PlayersProvider>(context);
    final sectionData = playersProvider.standbyPlayers;
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

        final alignment = isLandscape
            ? Alignment.centerRight
            : Alignment.topCenter;

        return Align(
          alignment: alignment,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: SingleChildScrollView(
              scrollDirection: isLandscape ? Axis.horizontal : Axis.vertical,
              child: isLandscape
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...sectionData.asMap().entries.map((entry) {
                          int sectionIndex = entry.key;
                          List<Player?> item = entry.value;

                          return SizedBox(
                            width: courtWidth,
                            height: isLandscape ? maxHeight : null,
                            child: CourtCard(
                              sectionIndex: sectionIndex,
                              players: item,
                              sectionKind: 'standby',
                              onPlayerDrop: onPlayerDrop,
                              onCourtPlayerDragStarted:
                                  onCourtPlayerDragStarted,
                              onCourtPlayerDragEnded: onCourtPlayerDragEnded,
                              onPlayerRemoved: (courtIndex, playerIndex) {
                                final removed = playersProvider
                                    .removeStandbyPlayer(
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
                                  colors: [
                                    courtColors.btnRemoveStart,
                                    courtColors.btnRemoveEnd,
                                  ],
                                  onTap: () {
                                    playersProvider
                                        .movePlayersFromCourtToUnassigned(
                                          sectionIndex: sectionIndex,
                                          targetCourtKind:
                                              PlayerSectionKind.standby.value,
                                          played: 0,
                                        );
                                  },
                                  child: Icon(
                                    Icons.group_remove,
                                    size: isTablet ? 24.0 : 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                                // 자동 매칭 버튼
                                _buildGradientButton(
                                  isTablet: isTablet,
                                  width: isTablet ? 120.0 : 80.0,
                                  height: isTablet ? 45.0 : 30.0,
                                  colors: [
                                    courtColors.btnAutoMatchStart,
                                    courtColors.btnAutoMatchEnd,
                                  ],
                                  onTap: () {
                                    playersProvider
                                        .assignNextPlayersToStandbyCourt(
                                          sectionIndex,
                                          isClubMatch: isClubMatch,
                                        );
                                  },
                                  child: Text(
                                    '자동 매칭',
                                    style: TextStyle(
                                      fontSize: isTablet ? 20.0 : 12.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // 코트 삭제 버튼
                                _buildGradientButton(
                                  isTablet: isTablet,
                                  width: isTablet ? 50.0 : 40.0,
                                  height: isTablet ? 45.0 : 30.0,
                                  colors: [
                                    courtColors.btnRemoveCourtStart,
                                    courtColors.btnRemoveCourtEnd,
                                  ],
                                  onTap: () => playersProvider
                                      .removeStandByPlayers(sectionIndex),
                                  child: Icon(
                                    Icons.remove,
                                    size: isTablet ? 24.0 : 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                                PopupMenuButton<int>(
                                  tooltip: '코트 이동/교환',
                                  color: baseColors.cardBg,
                                  elevation: 6,
                                  offset: const Offset(0, 40),
                                  constraints: const BoxConstraints(
                                    minWidth: 80,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (int targetIndex) {
                                    playersProvider.swapStandbyCourts(
                                      sectionIndex,
                                      targetIndex,
                                    );
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return List.generate(
                                      sectionData.length,
                                      (index) {
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
                                                  fontSize: isTablet
                                                      ? 16.0
                                                      : 14.0,
                                                  color: baseColors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ).whereType<PopupMenuEntry<int>>().toList();
                                  },
                                  child: IgnorePointer(
                                    child: _buildGradientButton(
                                      isTablet: isTablet,
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
                        }),
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          width: isTablet ? 200.0 : 120.0,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                courtColors.standbyZoneBgStart,
                                courtColors.standbyZoneBgEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: courtColors.standbyZoneBorder,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.0),
                              onTap: playersProvider.addStandByPlayers,
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: isTablet ? 60.0 : 40.0,
                                  color: courtColors.standbyZoneIcon,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (sectionData.isNotEmpty)
                          SizedBox(width: isTablet ? 200.0 : 100.0),
                      ],
                    )
                  : Column(
                      children: [
                        ...sectionData.asMap().entries.map((entry) {
                          int sectionIndex = entry.key;
                          List<Player?> item = entry.value;

                          return SizedBox(
                            width: courtWidth,
                            height: courtHeight,
                            child: CourtCard(
                              sectionIndex: sectionIndex,
                              players: item,
                              sectionKind: 'standby',
                              onPlayerDrop: onPlayerDrop,
                              onCourtPlayerDragStarted:
                                  onCourtPlayerDragStarted,
                              onCourtPlayerDragEnded: onCourtPlayerDragEnded,
                              onPlayerRemoved: (courtIndex, playerIndex) {
                                final removed = playersProvider
                                    .removeStandbyPlayer(
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
                                  colors: [
                                    courtColors.btnRemoveStart,
                                    courtColors.btnRemoveEnd,
                                  ],
                                  onTap: () {
                                    playersProvider
                                        .movePlayersFromCourtToUnassigned(
                                          sectionIndex: sectionIndex,
                                          targetCourtKind:
                                              PlayerSectionKind.standby.value,
                                          played: 0,
                                        );
                                  },
                                  child: Icon(
                                    Icons.group_remove,
                                    size: isTablet ? 24.0 : 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                                // 자동 매칭 버튼
                                _buildGradientButton(
                                  isTablet: isTablet,
                                  width: isTablet ? 120.0 : 80.0,
                                  height: isTablet ? 45.0 : 30.0,
                                  colors: [
                                    courtColors.btnAutoMatchStart,
                                    courtColors.btnAutoMatchEnd,
                                  ],
                                  onTap: () {
                                    playersProvider
                                        .assignNextPlayersToStandbyCourt(
                                          sectionIndex,
                                          isClubMatch: isClubMatch,
                                        );
                                  },
                                  child: Text(
                                    '자동 매칭',
                                    style: TextStyle(
                                      fontSize: isTablet ? 20.0 : 12.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // 코트 삭제 버튼
                                _buildGradientButton(
                                  isTablet: isTablet,
                                  width: isTablet ? 50.0 : 40.0,
                                  height: isTablet ? 45.0 : 30.0,
                                  colors: [
                                    courtColors.btnRemoveCourtStart,
                                    courtColors.btnRemoveCourtEnd,
                                  ],
                                  onTap: () => playersProvider
                                      .removeStandByPlayers(sectionIndex),
                                  child: Icon(
                                    Icons.remove,
                                    size: isTablet ? 24.0 : 18.0,
                                    color: Colors.white,
                                  ),
                                ),
                                PopupMenuButton<int>(
                                  tooltip: '코트 이동/교환',
                                  color: baseColors.cardBg,
                                  elevation: 6,
                                  offset: const Offset(0, 40),
                                  constraints: const BoxConstraints(
                                    minWidth: 80,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (int targetIndex) {
                                    playersProvider.swapStandbyCourts(
                                      sectionIndex,
                                      targetIndex,
                                    );
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return List.generate(
                                      sectionData.length,
                                      (index) {
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
                                                  fontSize: isTablet
                                                      ? 16.0
                                                      : 14.0,
                                                  color: baseColors.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ).whereType<PopupMenuEntry<int>>().toList();
                                  },
                                  child: IgnorePointer(
                                    child: _buildGradientButton(
                                      isTablet: isTablet,
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
                        }),
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          height: isTablet ? 150.0 : 100.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                courtColors.standbyZoneBgStart,
                                courtColors.standbyZoneBgEnd,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: courtColors.standbyZoneBorder,
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.0),
                              onTap: playersProvider.addStandByPlayers,
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: isTablet ? 60.0 : 40.0,
                                  color: courtColors.standbyZoneIcon,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (sectionData.isNotEmpty)
                          SizedBox(height: isTablet ? 600.0 : 300.0),
                      ],
                    ),
            ),
          ),
        );
      },
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
            color: colors.last.withAlpha(80), // 그림자를 조금 더 연하게
            blurRadius: 8,
            offset: const Offset(0, 4),
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
