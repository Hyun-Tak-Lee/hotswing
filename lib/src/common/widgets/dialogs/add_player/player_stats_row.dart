import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_input_decoration.dart';

class PlayerStatsRow extends StatelessWidget {
  const PlayerStatsRow({
    super.key,
    required this.baseColors,
    required this.playerColors,
    required this.formColors,
    required this.labelStyle,
    required this.isManager,
    required this.playCount,
    required this.waitCount,
    required this.lateCount,
    required this.onPlayCountSaved,
    required this.onWaitCountSaved,
    required this.onLateCountSaved,
  });

  final BaseColors baseColors;
  final PlayerColors playerColors;
  final FormColors formColors;
  final TextStyle? labelStyle;
  final bool isManager;
  final int? playCount;
  final int? waitCount;
  final int? lateCount;
  final ValueChanged<int?> onPlayCountSaved;
  final ValueChanged<int?> onWaitCountSaved;
  final ValueChanged<int?> onLateCountSaved;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final double spacing = isTablet ? 12 : 8;
    final double horizontalPadding = isTablet ? 16 : 8;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: playCount?.toString(),
            decoration: playerInputDecoration(
              context,
              baseColors: baseColors,
              playerColors: playerColors,
              formColors: formColors,
              labelText: '플레이 횟수',
              isManager: isManager,
              isDisabled: false,
              customHorizontalPadding: horizontalPadding,
            ),
            style: labelStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              const _LeadingZeroInputFormatter(),
              LengthLimitingTextInputFormatter(2),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return '입력 필요';
              return null;
            },
            onSaved: (value) =>
                onPlayCountSaved(int.tryParse(value ?? '0') ?? 0),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: TextFormField(
            initialValue: waitCount?.toString(),
            decoration: playerInputDecoration(
              context,
              baseColors: baseColors,
              playerColors: playerColors,
              formColors: formColors,
              labelText: '대기 횟수',
              isManager: isManager,
              isDisabled: false,
              customHorizontalPadding: horizontalPadding,
            ),
            style: labelStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              const _LeadingZeroInputFormatter(),
              LengthLimitingTextInputFormatter(2),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return '입력 필요';
              return null;
            },
            onSaved: (value) =>
                onWaitCountSaved(int.tryParse(value ?? '0') ?? 0),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: TextFormField(
            initialValue: lateCount?.toString(),
            decoration: playerInputDecoration(
              context,
              baseColors: baseColors,
              playerColors: playerColors,
              formColors: formColors,
              labelText: '지각 횟수',
              isManager: isManager,
              isDisabled: false,
              customHorizontalPadding: horizontalPadding,
            ),
            style: labelStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              const _LeadingZeroInputFormatter(),
              LengthLimitingTextInputFormatter(2),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return '입력 필요';
              return null;
            },
            onSaved: (value) =>
                onLateCountSaved(int.tryParse(value ?? '0') ?? 0),
          ),
        ),
      ],
    );
  }
}

/// 숫자 입력 시 선행 '0'을 자동으로 제거하여 (예: '0' 상태에서 '9' 입력 시 '09'가 아닌 '9'가 됨)
/// 원활한 두 자리 숫자 입력을 돕는 포맷터입니다.
class _LeadingZeroInputFormatter extends TextInputFormatter {
  const _LeadingZeroInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // '0'으로 시작하고 길이가 2자 이상인 경우 선행 '0' 제거
    if (text.length > 1 && text.startsWith('0')) {
      final stripped = text.replaceFirst(RegExp(r'^0+'), '');
      final result = stripped.isEmpty ? '0' : stripped;
      return TextEditingValue(
        text: result,
        selection: TextSelection.collapsed(offset: result.length),
      );
    }
    return newValue;
  }
}
