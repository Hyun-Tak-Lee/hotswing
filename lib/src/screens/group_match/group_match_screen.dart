import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/courts/assigned/court_sections_view.dart';
import 'package:hotswing/src/common/widgets/courts/court_fullscreen_control_bar.dart';
import 'package:hotswing/src/common/widgets/courts/standby/standby_court_sections_view.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';
import 'package:hotswing/src/enums/widget_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/screens/solo_match/widgets/court_view_selector.dart';
import 'package:hotswing/src/screens/group_match/widgets/group_waiting/group_waiting_players_panel.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 클럽/교류전 매칭 및 코트 배정, 그룹 대기열 패널을 표시하는 화면 위젯.
class GroupMatchScreen extends StatefulWidget {
  /// 전체화면 모드 활성화 여부.
  final bool isFullScreen;

  /// 전체화면 모드 종료(축소) 콜백.
  final VoidCallback? onExitFullScreen;

  /// [GroupMatchScreen] 생성자.
  const GroupMatchScreen({
    super.key,
    this.isFullScreen = false,
    this.onExitFullScreen,
  });

  @override
  State<GroupMatchScreen> createState() => _GroupMatchScreenState();
}

class _GroupMatchScreenState extends State<GroupMatchScreen> {
  final ValueNotifier<bool> _showCourtHighlight = ValueNotifier<bool>(false);

  CourtViewSection selectedView = CourtViewSection.assignedView;

  @override
  void dispose() {
    _showCourtHighlight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courtColors = context.courtColors;
    final isTablet = ResponsiveUtils.isTablet(context);
    final isMobileSize = !isTablet;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final currentCourtView = switch (selectedView) {
      CourtViewSection.assignedView => CourtSectionsView(
        onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
        onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
        onPlayerDrop: _handlePlayerDrop,
        isClubMatch: true,
        isFullScreen: widget.isFullScreen,
        onExitFullScreen: widget.onExitFullScreen,
      ),
      CourtViewSection.standbyView => StandbyCourtSectionsView(
        onCourtPlayerDragStarted: _onCourtPlayerDragStarted,
        onCourtPlayerDragEnded: _onCourtPlayerDragEnded,
        onPlayerDrop: _handlePlayerDrop,
        isClubMatch: true,
        isFullScreen: widget.isFullScreen,
        onExitFullScreen: widget.onExitFullScreen,
      ),
    };

    final courtViewSelector = CourtViewSelector(
      selectedView: selectedView,
      onSelectionChanged: (value) {
        setState(() {
          selectedView = value;
        });
      },
      isLandscape: isLandscape,
      // 모바일 세로 전체화면: 선택기 옆에 종료 버튼 표시 (가로 모드는 코트 목록 맨 앞 컨트롤 바 사용)
      onExitFullScreen: isMobileSize && widget.isFullScreen
          ? widget.onExitFullScreen
          : null,
    );

    final courtSectionWidget = isLandscape
        ? Stack(
            children: [
              Positioned.fill(child: currentCourtView),
              Positioned(
                top: 0,
                bottom: 0,
                right: 8.0,
                child: Center(child: courtViewSelector),
              ),
            ],
          )
        : Column(
            children: [
              courtViewSelector,
              Expanded(child: currentCourtView),
            ],
          );

    final waitingPlayersPanelWidget = ValueListenableBuilder<bool>(
      valueListenable: _showCourtHighlight,
      builder: (context, showHighlight, _) {
        return GroupWaitingPlayersPanel(
          showDeleteOverlay: showHighlight,
          onPlayerDrop: _handlePlayerDrop,
        );
      },
    );

    return Container(
      padding: EdgeInsets.only(
        top: isMobileSize ? 4.0 : 8.0,
        left: 0,
        right: 0,
      ),
      child: isMobileSize
          ? RepaintBoundary(child: courtSectionWidget)
          : isLandscape
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: RepaintBoundary(child: courtSectionWidget),
                ),
                Divider(height: 1.0, color: courtColors.homeDivider),
                Expanded(
                  flex: 1,
                  child: RepaintBoundary(child: waitingPlayersPanelWidget),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: RepaintBoundary(child: courtSectionWidget),
                ),
                VerticalDivider(width: 1.0, color: courtColors.homeDivider),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // 태블릿 세로 전체화면: 대기 패널 위에 종료 컨트롤 바 표시
                      if (widget.isFullScreen &&
                          widget.onExitFullScreen != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5.0,
                          ),
                          child: CourtFullscreenControlBar(
                            isLandscape: false,
                            isTablet: isTablet,
                            onExitFullScreen: widget.onExitFullScreen!,
                          ),
                        ),
                      Expanded(
                        child: RepaintBoundary(
                          child: waitingPlayersPanelWidget,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _handlePlayerDrop(
    BuildContext context,
    PlayerDragData data,
    Player? targetPlayer,
    dynamic targetSectionId,
    String targetSectionKind,
    int targetSectionIndex,
    int targetSubIndex,
  ) {
    HapticFeedback.selectionClick();
    context.read<PlayersProvider>().moveOrSwapPlayer(
      data: data,
      targetSectionKind: targetSectionKind,
      targetSectionIndex: targetSectionIndex,
      targetSubIndex: targetSubIndex,
    );
  }

  void _onCourtPlayerDragStarted() {
    _showCourtHighlight.value = true;
  }

  void _onCourtPlayerDragEnded() {
    if (!mounted) return;
    _showCourtHighlight.value = false;
  }
}
