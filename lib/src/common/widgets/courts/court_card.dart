import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/draggable/draggable_player.dart';
import 'package:hotswing/src/models/players/player.dart';

/// 단일 코트를 렌더링하는 공통 위젯.
/// [CourtSectionsView]와 [StandbyCourtSectionsView]에서 공유합니다.
class CourtCard extends StatelessWidget {
  final int sectionIndex;
  final List<Player?> players;
  final String sectionKind;
  final List<Widget> headerActions;
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

  const CourtCard({
    super.key,
    required this.sectionIndex,
    required this.players,
    required this.sectionKind,
    required this.headerActions,
    required this.onPlayerDrop,
    required this.onCourtPlayerDragStarted,
    required this.onCourtPlayerDragEnded,
  });

  String _getGamesPlayedWith(List<Player?> list, int index1, int index2) {
    final maxIndex = index1 > index2 ? index1 : index2;
    if (list.length <= maxIndex) return '0';

    final player1 = list[index1];
    final player2 = list[index2];
    if (player1 == null || player2 == null) return '0';

    final gamesCount = player1.gamesPlayedWith[player2.id.hexString];
    return gamesCount?.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final Color playedWithColor = Color(0xFF89A7DA);
    final Color playedWithTextColor = Color(0xFFFFEB3B);

    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF3E5F5), // 라벤더 미스트 (연보라)
            Color(0xFFE1F5FE), // 연하늘
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: [
          // 헤더: 코트 이름 + 액션 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${sectionIndex + 1} 코트',
                style: TextStyle(
                  fontSize: isTablet ? 32.0 : 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: isTablet ? 32.0 : 16.0),
              ...headerActions,
            ],
          ),
          const SizedBox(height: 4.0),
          // 코트 내부: 4개의 PlayerDropZone + 6개의 indicator
          SizedBox(
            height: isTablet ? 510.0 : 310.0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // PlayerDropZone 4개
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDropZone(context, 0)),
                        Expanded(child: _buildDropZone(context, 1)),
                      ],
                    ),
                    SizedBox(height: isTablet ? 10.0 : 10.0),
                    SizedBox(height: isTablet ? 10.0 : 10.0),
                    Row(
                      children: [
                        Expanded(child: _buildDropZone(context, 2)),
                        Expanded(child: _buildDropZone(context, 3)),
                      ],
                    ),
                  ],
                ),
                // Indicator: 1-2 (상단 중앙)
                _buildIndicator(
                  isTablet: isTablet,
                  alignment: FractionalOffset(0.5, 0.20),
                  text: _getGamesPlayedWith(players, 0, 1),
                  color: playedWithColor,
                  textColor: playedWithTextColor,
                ),
                // Indicator: 3-4 (하단 중앙)
                _buildIndicator(
                  isTablet: isTablet,
                  alignment: FractionalOffset(0.5, 0.80),
                  text: _getGamesPlayedWith(players, 2, 3),
                  color: playedWithColor,
                  textColor: playedWithTextColor,
                ),
                // Indicator: 1-3 (좌측)
                _buildIndicator(
                  isTablet: isTablet,
                  alignment: FractionalOffset(0.05, 0.5),
                  text: _getGamesPlayedWith(players, 0, 2),
                  color: playedWithColor,
                  textColor: playedWithTextColor,
                ),
                // Indicator: 2-4 (우측)
                _buildIndicator(
                  isTablet: isTablet,
                  alignment: FractionalOffset(0.95, 0.5),
                  text: _getGamesPlayedWith(players, 1, 3),
                  color: playedWithColor,
                  textColor: playedWithTextColor,
                ),
                // Indicator: 1⇄4 (좌측 중앙)
                _buildIndicator(
                  isTablet: isTablet,
                  alignment: FractionalOffset(isTablet ? 0.35 : 0.25, 0.5),
                  text: '1⇄4 ${_getGamesPlayedWith(players, 0, 3)}',
                  color: playedWithColor,
                  textColor: playedWithTextColor,
                  useStack: true,
                ),
                // Indicator: 2⇄3 (우측 중앙)
                _buildIndicator(
                  isTablet: isTablet,
                  alignment: FractionalOffset(isTablet ? 0.65 : 0.75, 0.5),
                  text: '2⇄3 ${_getGamesPlayedWith(players, 1, 2)}',
                  color: playedWithColor,
                  textColor: playedWithTextColor,
                  useStack: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone(BuildContext context, int subIndex) {
    return PlayerDropZone(
      sectionId: '${sectionIndex}_$subIndex',
      player: players.asMap().containsKey(subIndex) ? players[subIndex] : null,
      sectionKind: sectionKind,
      sectionIndex: sectionIndex,
      subIndex: subIndex,
      onPlayerDropped:
          (
            data,
            droppedOnPlayer,
            targetId,
            targetSectionKind,
            targetSectionIdx,
            targetSubIdx,
          ) => onPlayerDrop(
            context,
            data,
            droppedOnPlayer,
            targetId,
            targetSectionKind,
            targetSectionIdx,
            targetSubIdx,
          ),
      onDragStartedFromZone: onCourtPlayerDragStarted,
      onDragEndedFromZone: onCourtPlayerDragEnded,
    );
  }

  Widget _buildIndicator({
    required bool isTablet,
    required AlignmentGeometry alignment,
    required String text,
    required Color color,
    required Color textColor,
    bool useStack = false,
  }) {
    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 15.0 : 5.0,
        vertical: isTablet ? 5.0 : 3.0,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: isTablet ? 28.0 : 16.0, color: textColor),
      ),
    );

    return Align(
      alignment: alignment,
      child: useStack
          ? Stack(alignment: Alignment.center, children: [content])
          : content,
    );
  }
}
