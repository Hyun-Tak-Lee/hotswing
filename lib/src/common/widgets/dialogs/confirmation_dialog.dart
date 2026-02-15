import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class ConfirmationDialog extends StatelessWidget {
  final String? title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    this.title,
    required this.message,
    this.confirmText = '확인',
    this.cancelText = '취소',
    this.isDestructive = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isMobile = ResponsiveUtils.isMobile(context);
    final double dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.8
        : 450.0;

    final titleStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
    final messageStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.bodyLarge,
    );
    final buttonStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.titleMedium,
    );
    final destructiveButtonStyle = buttonStyle?.copyWith(color: Colors.red);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      title: title != null
          ? Text(title!, style: titleStyle, textAlign: TextAlign.center)
          : null,
      content: Container(
        padding: const EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 12.0, // title이 있을 경우 간격 조정 필요하지만 단순화
          bottom: 24.0,
        ),
        width: dialogWidth,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
        ),
        child: Text(message, style: messageStyle, textAlign: TextAlign.center),
      ),
      actions: <Widget>[
        IntrinsicHeight(
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(cancelText, style: buttonStyle),
                ),
              ),
              SizedBox(
                height: kMinInteractiveDimension,
                child: VerticalDivider(
                  thickness: 1,
                  color: Colors.grey.shade400,
                  width: 1,
                ),
              ),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(28.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    onConfirm();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    confirmText,
                    style: isDestructive ? destructiveButtonStyle : buttonStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
