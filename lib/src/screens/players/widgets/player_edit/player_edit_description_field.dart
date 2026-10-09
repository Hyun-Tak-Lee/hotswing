import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 플레이어 인라인 편집 폼의 Description 입력 필드 위젯.
class PlayerEditDescriptionField extends StatelessWidget {
  const PlayerEditDescriptionField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final formColors = context.formColors;

    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      scrollPadding: const EdgeInsets.only(bottom: 80),
      style: TextStyle(fontSize: 16, color: baseColors.textPrimary),
      decoration: InputDecoration(
        labelText: "Description",
        labelStyle: TextStyle(color: baseColors.textSecondary),
        floatingLabelStyle: TextStyle(
          color: baseColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(
          Icons.notes_outlined,
          size: 20,
          color: baseColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: formColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: formColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: formColors.inputFocusBorder, width: 2),
        ),
        filled: true,
        fillColor: playerColors.playerInputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      maxLength: 16,
      inputFormatters: [LengthLimitingTextInputFormatter(16)],
    );
  }
}
