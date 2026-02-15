import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isMobile = ResponsiveUtils.isMobile(context);
    final double dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.8
        : 450.0;

    final messageStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.titleLarge,
    );
    final buttonStyle = ResponsiveUtils.getResponsiveStyle(
      context,
      textTheme.titleMedium,
    );

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.all(24.0),
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
                  child: Text('취소', style: buttonStyle),
                ),
              ),
              SizedBox(
                height: kMinInteractiveDimension,
                // 머티리얼 디자인 최소 터치 타겟 크기
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
                  child: Text('확인', style: buttonStyle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
