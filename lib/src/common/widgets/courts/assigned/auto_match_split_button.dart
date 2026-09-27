import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';

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
