import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/enums/player_feature.dart';

class PlayerGenderField extends StatelessWidget {
  const PlayerGenderField({
    super.key,
    required this.formColors,
    required this.isLoaded,
    required this.selectedGender,
    required this.genders,
    required this.onChanged,
    required this.onSaved,
  });

  final FormColors formColors;
  final bool isLoaded;
  final PlayerGender? selectedGender;
  final List<PlayerGender> genders;
  final ValueChanged<PlayerGender?> onChanged;
  final FormFieldSetter<PlayerGender> onSaved;

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Opacity(
      opacity: isLoaded ? 0.5 : 1.0,
      child: FormField<PlayerGender>(
        initialValue: selectedGender,
        validator: (value) => selectedGender == null ? '성별을 선택하세요.' : null,
        onSaved: (value) => onSaved(selectedGender),
        builder: (FormFieldState<PlayerGender> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (int i = 0; i < genders.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: isLoaded
                            ? null
                            : () {
                                onChanged(genders[i]);
                                state.didChange(genders[i]);
                              },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 14 : 11,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedGender == genders[i]
                                ? formColors.genderActiveBg
                                : formColors.genderInactiveBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedGender == genders[i]
                                  ? formColors.genderActiveBorder
                                  : (state.hasError
                                        ? Theme.of(context).colorScheme.error
                                        : formColors.inputBorder),
                              width: selectedGender == genders[i] ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            genders[i].label,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: selectedGender == genders[i]
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: selectedGender == genders[i]
                                  ? formColors.genderActiveText
                                  : formColors.genderInactiveText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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
    );
  }
}
