import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/assigned_court.dart';
import 'package:hotswing/src/common/widgets/courts/standby_court.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/screens/solo_match/widgets/court_view_selector.dart';
import 'package:hotswing/src/screens/group_match/widgets/group_waiting_players_panel.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class GroupMatchScreen extends StatefulWidget {
  const GroupMatchScreen({super.key});

  @override
  State<GroupMatchScreen> createState() => _GroupMatchScreenState();
}

class _GroupMatchScreenState extends State<GroupMatchScreen> {
  bool _showCourtHighlight = false;

  CourtViewSection selectedView = CourtViewSection.assignedView;

  void _handlePlayerDrop(
    BuildContext context,
    PlayerDragData data,
    Player? targetPlayer,
    dynamic targetSectionId,
    String targetSectionKind,
    int targetSectionIndex,
    int targetSubIndex,
  ) {
    final playersProvider = Provider.of<PlayersProvider>(
      context,
      listen: false,
    );
    final String sourceSectionKind = data.sectionKind;
    final int sourceSectionIndex = data.sectionIndex;
    final int sourceSubIndex = data.subIndex;

    // [1] 소스 처리 (Extraction)
    Player? draggedPlayer;
    if (sourceSectionKind == PlayerSectionKind.unassigned.value) {
      draggedPlayer = data.player;
      playersProvider.removeUnassignedPlayer(draggedPlayer);
    } else if (sourceSectionKind == PlayerSectionKind.assigned.value) {
      draggedPlayer = playersProvider.removeAssignedPlayer(
        sourceSectionIndex,
        sourceSubIndex,
      );
    } else if (sourceSectionKind == PlayerSectionKind.standby.value) {
      draggedPlayer = playersProvider.removeStandbyPlayer(
        sourceSectionIndex,
        sourceSubIndex,
      );
    }

    if (draggedPlayer == null) return;

    // [2] 타겟 처리 (Move Only)
    if (targetSectionKind == PlayerSectionKind.unassigned.value ||
        targetSectionKind == PlayerSectionKind.drop.value) {
      playersProvider.addUnassignedPlayer(draggedPlayer);
      return;
    }

    // [3] 타겟 처리 (Exchange)
    Player? existingTargetPlayer;
    if (targetSectionKind == PlayerSectionKind.assigned.value) {
      existingTargetPlayer = playersProvider.removeAssignedPlayer(
        targetSectionIndex,
        targetSubIndex,
      );
      playersProvider.addAssignedPlayer(
        draggedPlayer,
        targetSectionIndex,
        targetSubIndex,
      );
    } else if (targetSectionKind == PlayerSectionKind.standby.value) {
      existingTargetPlayer = playersProvider.removeStandbyPlayer(
        targetSectionIndex,
        targetSubIndex,
      );
      playersProvider.addStandbyPlayer(
        draggedPlayer,
        targetSectionIndex,
        targetSubIndex,
      );
    }

    // [4] 소스 복구 (Swap)
    if (sourceSectionKind == PlayerSectionKind.unassigned.value) {
      playersProvider.addUnassignedPlayer(existingTargetPlayer);
    } else if (sourceSectionKind == PlayerSectionKind.assigned.value) {
      playersProvider.addAssignedPlayer(
        existingTargetPlayer,
        sourceSectionIndex,
        sourceSubIndex,
      );
    } else if (sourceSectionKind == PlayerSectionKind.standby.value) {
      playersProvider.addStandbyPlayer(
        existingTargetPlayer,
        sourceSectionIndex,
        sourceSubIndex,
      );
    }
  }

  void _onCourtPlayerDragStarted() {
    setState(() {
      _showCourtHighlight = true;
    });
  }

  void _onCourtPlayerDragEnded() {
    setState(() {
      _showCourtHighlight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);
    final isMobileSize = !isTablet;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final courtSectionWidget = isLandscape
        ? Row(
            children: [
              Expanded(
                child: switch (selectedView) {
                  CourtViewSection.assignedView => CourtSectionsView(
                    onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
                    onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
                    onPlayerDrop: _handlePlayerDrop,
                  ),
                  CourtViewSection.standbyView => StandbyCourtSectionsView(
                    onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
                    onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
                    onPlayerDrop: _handlePlayerDrop,
                  ),
                },
              ),
              CourtViewSelector(
                selectedView: selectedView,
                onSelectionChanged: (value) {
                  setState(() {
                    selectedView = value;
                  });
                },
                isLandscape: isLandscape,
              ),
            ],
          )
        : Column(
            children: [
              CourtViewSelector(
                selectedView: selectedView,
                onSelectionChanged: (value) {
                  setState(() {
                    selectedView = value;
                  });
                },
                isLandscape: isLandscape,
              ),
              Expanded(
                child: switch (selectedView) {
                  CourtViewSection.assignedView => CourtSectionsView(
                    onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
                    onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
                    onPlayerDrop: _handlePlayerDrop,
                  ),
                  CourtViewSection.standbyView => StandbyCourtSectionsView(
                    onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
                    onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
                    onPlayerDrop: _handlePlayerDrop,
                  ),
                },
              ),
            ],
          );

    final waitingPlayersPanelWidget = GroupWaitingPlayersPanel(
      showDeleteOverlay: _showCourtHighlight,
      onPlayerDrop: _handlePlayerDrop,
    );

    return Container(
      padding: EdgeInsets.only(
        top: isMobileSize ? 4.0 : 8.0,
        left: 0,
        right: 0,
      ),
      child: isLandscape
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: courtSectionWidget,
                ),
                Divider(height: 1.0, color: courtColors.homeDivider),
                Expanded(
                  flex: 1,
                  child: waitingPlayersPanelWidget,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: courtSectionWidget,
                ),
                VerticalDivider(width: 1.0, color: courtColors.homeDivider),
                Expanded(
                  flex: 1,
                  child: waitingPlayersPanelWidget,
                ),
              ],
            ),
    );
  }
}
