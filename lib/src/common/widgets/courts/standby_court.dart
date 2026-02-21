import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/court_card.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/players/player.dart';

class StandbyCourtSectionsView extends StatelessWidget {
  final List<List<Player?>> sectionData;
  final Map<int, bool> courtGameStartedState;
  final Function(int) onRefreshCourt;
  final Function(int) onAutoMatch;
  final VoidCallback onAddStandByCourt;
  final Function(int) onRemoveStandByCourt;
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
  final String Function(List<Player?>, int, int) getGamesPlayedWith;

  const StandbyCourtSectionsView({
    super.key,
    required this.sectionData,
    required this.courtGameStartedState,
    required this.onRefreshCourt,
    required this.onAutoMatch,
    required this.onAddStandByCourt,
    required this.onRemoveStandByCourt,
    required this.onPlayerDrop,
    required this.onCourtPlayerDragStarted,
    required this.onCourtPlayerDragEnded,
    required this.getGamesPlayedWith,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final Color pastelBlue = Color(0x9987CEFA);

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              ...sectionData.asMap().entries.map((entry) {
                int sectionIndex = entry.key;
                List<Player?> item = entry.value;

                return CourtCard(
                  sectionIndex: sectionIndex,
                  players: item,
                  sectionKind: 'standby',
                  onPlayerDrop: onPlayerDrop,
                  onCourtPlayerDragStarted: onCourtPlayerDragStarted,
                  onCourtPlayerDragEnded: onCourtPlayerDragEnded,
                  getGamesPlayedWith: getGamesPlayedWith,
                  headerActions: [
                    // 새로고침 버튼
                    SizedBox(
                      width: isTablet ? 50.0 : 40.0,
                      height: isTablet ? 45.0 : 30.0,
                      child: FloatingActionButton(
                        elevation: 2.0,
                        onPressed: () => onRefreshCourt(sectionIndex),
                        heroTag: 'standby_refresh_fab_$sectionIndex',
                        child: Icon(
                          Icons.refresh,
                          size: isTablet ? 24.0 : 18.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // 자동 매칭 버튼
                    SizedBox(
                      width: isTablet ? 120.0 : 80.0,
                      height: isTablet ? 45.0 : 30.0,
                      child: FloatingActionButton(
                        elevation: 2.0,
                        onPressed: () => onAutoMatch(sectionIndex),
                        heroTag: 'standby_start_fab_$sectionIndex',
                        child: Text(
                          '자동 매칭',
                          style: TextStyle(fontSize: isTablet ? 20.0 : 12.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // 코트 삭제 버튼
                    SizedBox(
                      width: isTablet ? 50.0 : 40.0,
                      height: isTablet ? 45.0 : 30.0,
                      child: FloatingActionButton(
                        elevation: 2.0,
                        onPressed: () => onRemoveStandByCourt(sectionIndex),
                        heroTag: 'standby_remove_fab_$sectionIndex',
                        child: Icon(Icons.remove, size: isTablet ? 24.0 : 18.0),
                      ),
                    ),
                  ],
                );
              }),
              // 코트 추가 버튼
              Container(
                margin: const EdgeInsets.all(5.0),
                height: isTablet ? 150.0 : 100.0,
                decoration: BoxDecoration(
                  color: pastelBlue.withAlpha(125),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.0),
                    onTap: onAddStandByCourt,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: isTablet ? 60.0 : 40.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // 하단 여백
              SizedBox(height: isTablet ? 600.0 : 300.0),
            ],
          ),
        ),
      ),
    );
  }
}
