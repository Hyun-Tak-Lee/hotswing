import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_input_decoration.dart';

/// 플레이어 추가/수정 다이얼로그의 Description 입력 필드.
class PlayerDescriptionField extends StatelessWidget {
  const PlayerDescriptionField({
    super.key,
    required this.baseColors,
    required this.playerColors,
    required this.formColors,
    required this.labelStyle,
    required this.isManager,
    required this.initialValue,
    required this.onDescriptionSaved,
  });

  final BaseColors baseColors;
  final PlayerColors playerColors;
  final FormColors formColors;
  final TextStyle? labelStyle;
  final bool isManager;
  final String initialValue;
  final FormFieldSetter<String> onDescriptionSaved;

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return TapRegion(
      groupId: const ValueKey('player_description_input'),
      child: TextFormField(
        initialValue: initialValue,
        scrollPadding: const EdgeInsets.only(bottom: 80),
        decoration: playerInputDecoration(
          context,
          baseColors: baseColors,
          playerColors: playerColors,
          formColors: formColors,
          labelText: 'Description',
          isManager: isManager,
          isDisabled: false,
          customVerticalPadding: isTablet ? 12.0 : 8.0,
        ),
        style: labelStyle,
        maxLength: 16,
        inputFormatters: [LengthLimitingTextInputFormatter(16)],
        onSaved: onDescriptionSaved,
      ),
    );
  }
}
