import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// Google Material 3 (M3) 기본 다이얼로그 표준 규격에 맞춘 공통 확인 다이얼로그
class ConfirmationDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final Color? messageColor;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    this.title,
    this.message,
    this.messageColor,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.isDestructive = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;

    final hasTitle = title != null && title!.isNotEmpty;
    final hasMessage = message != null && message!.isNotEmpty;

    // 파괴적 액션(삭제/초기화)일 때와 일반 액션일 때의 색상
    final Color actionConfirmColor = isDestructive
        ? Colors.redAccent
        : baseColors.primaryAccent;

    return AlertDialog(
      backgroundColor: baseColors.cardBg,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.0), // M3 표준 corner radius
      ),
      titlePadding: EdgeInsets.fromLTRB(
        24.0,
        24.0,
        24.0,
        hasMessage ? 16.0 : 24.0,
      ),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
      actionsPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      // M3 표준: 아이콘이 없는 경우 Start-aligned(좌측 정렬)
      title: hasTitle
          ? Text(
              title!,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: baseColors.textPrimary,
                letterSpacing: -0.2,
              ),
            )
          : null,
      content: hasMessage
          ? Text(
              message!,
              style: TextStyle(
                fontSize: 15.0,
                height: 1.5,
                color: messageColor ?? baseColors.textSecondary,
              ),
            )
          : null,
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            cancelText,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: baseColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 4.0),
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            backgroundColor: isDestructive
                ? actionConfirmColor.withValues(alpha: 0.1)
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: Text(
            confirmText,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: actionConfirmColor,
            ),
          ),
        ),
      ],
    );
  }
}
