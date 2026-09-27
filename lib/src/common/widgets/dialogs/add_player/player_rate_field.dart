import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_input_decoration.dart';

class PlayerRateField extends StatelessWidget {
  const PlayerRateField({
    super.key,
    required this.baseColors,
    required this.playerColors,
    required this.formColors,
    required this.labelStyle,
    required this.isLoaded,
    required this.isManager,
    required this.controller,
    required this.rate,
    required this.maxRate,
    required this.onRateUpdated,
    required this.onRateEdited,
    required this.onRateSaved,
  });

  final BaseColors baseColors;
  final PlayerColors playerColors;
  final FormColors formColors;
  final TextStyle? labelStyle;
  final bool isLoaded;
  final bool isManager;
  final TextEditingController controller;
  final int? rate;
  final int maxRate;
  final ValueChanged<int> onRateUpdated;
  final ValueChanged<int> onRateEdited;
  final ValueChanged<int> onRateSaved;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = ResponsiveUtils.isTablet(context);
    final double iconSize = isTablet ? 24.0 : 20.0;
    final EdgeInsets padding = isTablet
        ? const EdgeInsets.all(8.0)
        : const EdgeInsets.all(4.0);
    final BoxConstraints constraints = isTablet
        ? const BoxConstraints(minWidth: 40.0, minHeight: 40.0)
        : const BoxConstraints(minWidth: 32.0, minHeight: 40.0);

    return Row(
      children: [
        IconButton(
          padding: padding,
          constraints: constraints,
          iconSize: iconSize,
          icon: const Icon(Icons.remove),
          onPressed: isLoaded
              ? null
              : () {
                  final int currentRate =
                      int.tryParse(controller.text) ?? (rate ?? 0);
                  int newRate = ((currentRate - 1) ~/ 50) * 50;
                  if (newRate < 0) newRate = 0;
                  onRateUpdated(newRate);
                },
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: playerInputDecoration(
              context,
              baseColors: baseColors,
              playerColors: playerColors,
              formColors: formColors,
              labelText: 'Rate',
              isManager: isManager,
              isDisabled: isLoaded,
              customVerticalPadding: isTablet ? 6.0 : 2.0,
            ),
            style: labelStyle?.copyWith(fontSize: isTablet ? null : 14.0),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !isLoaded,
            onChanged: (value) {
              int? parsed = int.tryParse(value);
              if (parsed != null) {
                if (parsed > maxRate) {
                  parsed = maxRate;
                  controller.text = maxRate.toString();
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                } else if (parsed < 0) {
                  parsed = 0;
                  controller.text = '0';
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
                onRateEdited(parsed);
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) return '입력 필요';
              return null;
            },
            onSaved: (value) {
              final int parsed = int.tryParse(value ?? '') ?? (rate ?? 0);
              onRateSaved(parsed.clamp(0, maxRate));
            },
          ),
        ),
        IconButton(
          padding: padding,
          constraints: constraints,
          iconSize: iconSize,
          icon: const Icon(Icons.add),
          onPressed: isLoaded
              ? null
              : () {
                  final int currentRate =
                      int.tryParse(controller.text) ?? (rate ?? 0);
                  int newRate = (currentRate ~/ 50) * 50 + 50;
                  if (newRate > maxRate) newRate = maxRate;
                  onRateUpdated(newRate);
                },
        ),
      ],
    );
  }
}
