import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 현대적이고 세련된 모바일 카드 스타일의 공통 확인/삭제 다이얼로그.
class ConfirmationDialog extends StatelessWidget {
  /// 다이얼로그 제목 (선택).
  final String? title;

  /// 다이얼로그 메시지 본문 (선택).
  final String? message;

  /// 메시지 텍스트 색상 (선택).
  final Color? messageColor;

  /// 확인 버튼 텍스트.
  final String confirmText;

  /// 취소 버튼 텍스트.
  final String cancelText;

  /// 위험/삭제 작업 여부 (확인 버튼 강조 색상 및 아이콘 변경).
  final bool isDestructive;

  /// 상단 아이콘 (선택, 미지정 시 isDestructive에 따라 자동 결정).
  final IconData? icon;

  /// 확인 버튼 클릭 시 실행될 콜백.
  final VoidCallback onConfirm;

  /// [ConfirmationDialog] 생성자.
  const ConfirmationDialog({
    super.key,
    this.title,
    this.message,
    this.messageColor,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.isDestructive = false,
    this.icon,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final hasTitle = title != null && title!.isNotEmpty;
    final hasMessage = message != null && message!.isNotEmpty;

    final IconData headerIcon = icon ??
        (isDestructive
            ? Icons.delete_outline_rounded
            : Icons.help_outline_rounded);

    final Color accentColor =
        isDestructive ? const Color(0xFFEF4444) : baseColors.primaryAccent;

    return Dialog(
      backgroundColor: baseColors.cardBg,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 280,
          maxWidth: 320,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // 상단 모던 아이콘 뱃지
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                headerIcon,
                color: accentColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),

            // 타이틀 (있을 경우)
            if (hasTitle) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: baseColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 메시지 본문
            if (hasMessage)
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: hasTitle ? 14.5 : 15.5,
                  fontWeight: hasTitle ? FontWeight.normal : FontWeight.w600,
                  height: 1.45,
                  color: messageColor ??
                      (hasTitle
                          ? baseColors.textSecondary
                          : baseColors.textPrimary),
                ),
              ),

            const SizedBox(height: 22),

            // 하단 듀얼 액션 버튼 (취소 / 확인)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: baseColors.contentBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        cancelText,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: baseColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      onPressed: () {
                        onConfirm();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }
}
