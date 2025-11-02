import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;

  const ConfirmationDialog({super.key, required this.message, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.fromLTRB(36.0, 36.0, 36.0, 36.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
        ),
        child: Text(message, style: const TextStyle(fontSize: 24)),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // 버튼 내부 세로 여백 추가
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('취소', style: const TextStyle(fontSize: 24)),
              ),
            ),
            SizedBox(
              height: kMinInteractiveDimension,
              // Material design minimum touch target size
              child: VerticalDivider(thickness: 1, color: Colors.grey.shade400),
            ),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // 버튼 내부 세로 여백 추가
                ),
                onPressed: () {
                  onConfirm();
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('확인', style: const TextStyle(fontSize: 24)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
