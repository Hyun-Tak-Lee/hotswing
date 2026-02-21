import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/court_card.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/options_provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/enums/player_feature.dart';

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

  const StandbyCourtSectionsView({
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
    final sectionData = playersProvider.standbyPlayers;

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
                  headerActions: [
                    // 새로고침 버튼
                    _buildGradientButton(
                      isTablet: isTablet,
                      width: isTablet ? 50.0 : 40.0,
                      height: isTablet ? 45.0 : 30.0,
                      colors: [
                        const Color(0xFFEF9A9A),
                        const Color(0xFFE57373),
                      ],
                      onTap: () {
                        playersProvider.movePlayersFromCourtToUnassigned(
                          sectionIndex: sectionIndex,
                          targetCourtKind: PlayerSectionKind.standby.value,
                          played: 0,
                        );
                      },
                      child: Icon(
                        Icons.group_remove,
                        size: isTablet ? 24.0 : 18.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // 자동 매칭 버튼
                    _buildGradientButton(
                      isTablet: isTablet,
                      width: isTablet ? 120.0 : 80.0,
                      height: isTablet ? 45.0 : 30.0,
                      colors: [
                        const Color(0xFFA5D6A7),
                        const Color(0xFF81C784),
                      ],
                      onTap: () {
                        playersProvider.assignPlayersToCourt(
                          sectionIndex,
                          skillWeight: optionsProvider.skillWeight,
                          genderWeight: optionsProvider.genderWeight,
                          waitedWeight: optionsProvider.waitedWeight,
                          playedWeight: optionsProvider.playedWeight,
                          playedWithWeight: optionsProvider.playedWithWeight,
                          targetCourtKind: PlayerSectionKind.standby.value,
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
                    const SizedBox(width: 8.0),
                    // 코트 삭제 버튼
                    _buildGradientButton(
                      isTablet: isTablet,
                      width: isTablet ? 50.0 : 40.0,
                      height: isTablet ? 45.0 : 30.0,
                      colors: [
                        const Color(0xFFFFB74D),
                        const Color(0xFFE57373),
                      ],
                      onTap: () =>
                          playersProvider.removeStandByPlayers(sectionIndex),
                      child: Icon(
                        Icons.remove,
                        size: isTablet ? 24.0 : 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
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
                      const Color(0xFFF3E5F5).withAlpha(150), // 라벤더 미스트 (연보라)
                      const Color(0xFFE1F5FE).withAlpha(150), // 연하늘
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.white, width: 2.0),
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
