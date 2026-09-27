import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/dialog_skill_chip_button.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_rate_field.dart';

class PlayerSkillLevelField extends StatelessWidget {
  const PlayerSkillLevelField({
    super.key,
    required this.baseColors,
    required this.playerColors,
    required this.formColors,
    required this.labelStyle,
    required this.isLoaded,
    required this.isManager,
    required this.selectedSkillLevel,
    required this.rateController,
    required this.rate,
    required this.maxRate,
    required this.onChanged,
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
  final String? selectedSkillLevel;
  final TextEditingController rateController;
  final int? rate;
  final int maxRate;
  final ValueChanged<String?> onChanged;
  final ValueChanged<int> onRateUpdated;
  final ValueChanged<int> onRateEdited;
  final ValueChanged<int> onRateSaved;

  @override
  Widget build(BuildContext context) {
    final levels = skillLevelToRate.keys.toList();
    final isTablet = ResponsiveUtils.isTablet(context);

    return Opacity(
      opacity: isLoaded ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormField<String>(
            initialValue: selectedSkillLevel,
            validator: (value) =>
                selectedSkillLevel == null ? '급수를 선택하세요.' : null,
            builder: (FormFieldState<String> state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (int i = 0; i < levels.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          DialogSkillChipButton(
                            level: levels[i],
                            isSelected: selectedSkillLevel == levels[i],
                            hasError: state.hasError,
                            isDisabled: isLoaded,
                            onSelected: (selected) {
                              onChanged(selected);
                              state.didChange(selected);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (state.hasError) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          Divider(
            height: isTablet ? 16 : 12,
            thickness: 0.6,
            color: formColors.filterDivider,
          ),
          PlayerRateField(
            baseColors: baseColors,
            playerColors: playerColors,
            formColors: formColors,
            labelStyle: labelStyle,
            isLoaded: isLoaded,
            isManager: isManager,
            controller: rateController,
            rate: rate,
            maxRate: maxRate,
            onRateUpdated: onRateUpdated,
            onRateEdited: onRateEdited,
            onRateSaved: onRateSaved,
          ),
        ],
      ),
    );
  }
}
