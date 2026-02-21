import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/court_card.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';

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
    final isTablet = ResponsiveUtils.isTablet(context);
    final playersProvider = Provider.of<PlayersProvider>(context);
    final optionsProvider = Provider.of<OptionsProvider>(context);
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
                headerActions: [
                  // 새로고침 버튼
                  SizedBox(
                    width: isTablet ? 50.0 : 40.0,
                    height: isTablet ? 45.0 : 30.0,
                    child: FloatingActionButton(
                      elevation: 2.0,
                      onPressed: () {
                        playersProvider.movePlayersFromCourtToUnassigned(
                          sectionIndex: sectionIndex,
                          targetCourtKind: PlayerSectionKind.assigned.value,
                          played: 0,
                        );
                      },
                      heroTag: 'refresh_fab_$sectionIndex',
                      child: Icon(Icons.refresh, size: isTablet ? 24.0 : 18.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // 자동 매칭 / 경기 종료 버튼
                  if (!isGameStarted)
                    SizedBox(
                      width: isTablet ? 120.0 : 80.0,
                      height: isTablet ? 45.0 : 30.0,
                      child: FloatingActionButton(
                        elevation: 2.0,
                        onPressed: () {
                          playersProvider.assignPlayersToCourt(
                            sectionIndex,
                            skillWeight: optionsProvider.skillWeight,
                            genderWeight: optionsProvider.genderWeight,
                            waitedWeight: optionsProvider.waitedWeight,
                            playedWeight: optionsProvider.playedWeight,
                            playedWithWeight: optionsProvider.playedWithWeight,
                            targetCourtKind: PlayerSectionKind.assigned.value,
                          );
                        },
                        heroTag: 'start_fab_$sectionIndex',
                        child: Text(
                          '자동 매칭',
                          style: TextStyle(fontSize: isTablet ? 20.0 : 12.0),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: isTablet ? 150.0 : 90.0,
                      height: isTablet ? 45.0 : 30.0,
                      child: FloatingActionButton(
                        elevation: 2.0,
                        onPressed: () {
                          playersProvider
                              .incrementWaitedTimeForAllUnassignedPlayers();
                          playersProvider.movePlayersFromCourtToUnassigned(
                            sectionIndex: sectionIndex,
                            targetCourtKind: PlayerSectionKind.assigned.value,
                          );
                        },
                        heroTag: 'stop_fab_$sectionIndex',
                        child: Text(
                          '경기 종료',
                          style: TextStyle(fontSize: isTablet ? 20.0 : 12.0),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8.0),
                  // 대기 코트 Pop 버튼
                  SizedBox(
                    width: isTablet ? 50.0 : 40.0,
                    height: isTablet ? 45.0 : 30.0,
                    child: FloatingActionButton(
                      elevation: 2.0,
                      onPressed: () =>
                          playersProvider.popStandByPlayers(sectionIndex),
                      heroTag: 'pop_standby_fab_$sectionIndex',
                      child: Icon(Icons.add, size: isTablet ? 24.0 : 18.0),
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
}
