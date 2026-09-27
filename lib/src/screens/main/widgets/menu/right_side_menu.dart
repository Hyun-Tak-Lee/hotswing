import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 메인 화면 우측 서랍(Drawer) 옵션 메뉴 위젯.
class RightSideMenu extends StatelessWidget {
  /// [RightSideMenu] 생성자.
  const RightSideMenu({super.key, required this.isMobileSize});

  /// 모바일 화면 크기 여부.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    final isMobile = isMobileSize || ResponsiveUtils.isMobile(context);
    final isTablet = ResponsiveUtils.isTablet(context);

    final drawerWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.75
        : MediaQuery.of(context).size.width * 0.55;

    return Drawer(
      width: drawerWidth,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 2, // 0: Header, 1: 플레이 횟수 초기화
        itemBuilder: (context, index) {
          if (index == 0) {
            return RightSideMenuHeader(isMobile: isMobile, isTablet: isTablet);
          }
          return ResetPlayerStatsTile(isMobile: isMobile, isTablet: isTablet);
        },
      ),
    );
  }
}

/// 우측 서랍 메뉴의 헤더 위젯.
class RightSideMenuHeader extends StatelessWidget {
  /// [RightSideMenuHeader] 생성자.
  const RightSideMenuHeader({
    super.key,
    required this.isMobile,
    required this.isTablet,
  });

  /// 모바일 화면 크기 여부.
  final bool isMobile;

  /// 태블릿 화면 크기 여부.
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final double headerHeight = isTablet ? 160.0 : 110.0;
    final double titleFontSize = isTablet ? 22.0 : 17.0;
    final double iconSize = isTablet ? 26.0 : 20.0;

    return SizedBox(
      height: headerHeight,
      child: DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColors.gradientStart, baseColors.gradientEnd],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.tune_rounded,
              size: iconSize,
              color: baseColors.textPrimary,
            ),
            const SizedBox(width: 8.0),
            Text(
              '옵션',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: baseColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 플레이어들의 경기 참여 기록(플레이 횟수)을 초기화할 수 있는 메뉴 타일 위젯.
class ResetPlayerStatsTile extends StatelessWidget {
  /// [ResetPlayerStatsTile] 생성자.
  const ResetPlayerStatsTile({
    super.key,
    required this.isMobile,
    required this.isTablet,
  });

  /// 모바일 화면 크기 여부.
  final bool isMobile;

  /// 태블릿 화면 크기 여부.
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final formColors = context.formColors;
    final playersProvider = context.read<PlayersProvider>();

    final double titleFontSize = isTablet ? 17.0 : 15.0;
    final double subtitleFontSize = isTablet ? 13.0 : 12.0;
    final double iconSize = isTablet ? 24.0 : 20.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : 16.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: baseColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: formColors.inputBorder.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showDialog(
              context: context,
              builder: (_) {
                return ConfirmationDialog(
                  title: '플레이 횟수 초기화',
                  message: '초기화된 경기 기록은 이전 상태로 되돌릴 수 없습니다.',
                  confirmText: '초기화',
                  cancelText: '취소',
                  isDestructive: true,
                  onConfirm: () {
                    playersProvider.resetPlayerStats();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('플레이 횟수가 성공적으로 초기화되었습니다'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
            );
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14.0 : 16.0,
              vertical: isMobile ? 12.0 : 14.0,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_edu_rounded,
                    size: iconSize,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '플레이 횟수 초기화',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: baseColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '참가 인원의 기록을 0으로 설정합니다',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: baseColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: baseColors.textSecondary.withValues(alpha: 0.5),
                  size: iconSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
