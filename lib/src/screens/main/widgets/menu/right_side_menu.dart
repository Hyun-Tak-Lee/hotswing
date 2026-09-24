import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/widgets/dialogs/confirmation_dialog.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 메인 화면 우측 서랍(Drawer) 옵션 메뉴 위젯.
class RightSideMenu extends StatelessWidget {
  /// [RightSideMenu] 생성자.
  const RightSideMenu({super.key, required this.isMobileSize});

  /// 모바일 화면 크기 여부.
  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    final iconAndFontSize = isMobileSize ? 24.0 : 32.0;

    return Drawer(
      width: isMobileSize
          ? MediaQuery.of(context).size.width * 0.75
          : MediaQuery.of(context).size.width * 0.60,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: 2, // 0: Header, 1: 플레이 횟수 초기화 (향후 옵션 확장 용이)
        itemBuilder: (context, index) {
          if (index == 0) {
            return RightSideMenuHeader(
              isMobileSize: isMobileSize,
              iconAndFontSize: iconAndFontSize,
            );
          }
          return ResetPlayerStatsTile(iconAndFontSize: iconAndFontSize);
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
    required this.isMobileSize,
    required this.iconAndFontSize,
  });

  /// 모바일 화면 크기 여부.
  final bool isMobileSize;

  /// 아이콘 및 폰트 크기.
  final double iconAndFontSize;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;

    return SizedBox(
      height: isMobileSize ? 120 : 180,
      child: DrawerHeader(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [baseColors.gradientStart, baseColors.gradientEnd],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '옵션',
              style: TextStyle(
                fontSize: iconAndFontSize,
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
  const ResetPlayerStatsTile({super.key, required this.iconAndFontSize});

  /// 아이콘 및 폰트 크기.
  final double iconAndFontSize;

  @override
  Widget build(BuildContext context) {
    final playersProvider = context.read<PlayersProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history_edu_rounded,
                    size: iconAndFontSize,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '플레이 횟수 초기화',
                        style: TextStyle(
                          fontSize: iconAndFontSize * 0.75,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '참가 인원의 기록을 0으로 설정합니다',
                        style: TextStyle(
                          fontSize: iconAndFontSize * 0.5,
                          color: Colors.orange.shade700.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.orange.withValues(alpha: 0.5),
                  size: iconAndFontSize * 0.8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
