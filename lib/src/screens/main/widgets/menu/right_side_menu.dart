import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/common/widgets/dialogs/confirmation_dialog.dart';

class RightSideMenu extends StatelessWidget {
  const RightSideMenu({super.key, required this.isMobileSize});

  final bool isMobileSize;

  @override
  Widget build(BuildContext context) {
    final playersProvider = Provider.of<PlayersProvider>(
      context,
      listen: false,
    );
    final iconAndFontSize = isMobileSize ? 24.0 : 32.0;

    return Drawer(
      width: isMobileSize
          ? MediaQuery.of(context).size.width * 0.75
          : MediaQuery.of(context).size.width * 0.60,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: isMobileSize ? 120 : 180,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF3E5F5), // 라벤더 미스트 (연보라)
                    Color(0xFFE1F5FE), // 연하늘
                  ],
                  // left_side_menu의 방향과 반대로 설정
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('옵션', style: TextStyle(fontSize: iconAndFontSize)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return ConfirmationDialog(
                        message: '참가 인원의 플레이 횟수들을 초기화 하시겠습니까?',
                        onConfirm: () {
                          playersProvider.resetPlayerStats();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('플레이 횟수가 초기화되었습니다'),
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
                                color: Colors.orange.shade700.withValues(
                                  alpha: 0.8,
                                ),
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
          ),
          // 추후 사용할 내용을 위해 프레임은 비워둡니다
        ],
      ),
    );
  }
}
