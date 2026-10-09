import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_input_decoration.dart';
import 'package:hotswing/src/models/players/player.dart';

class PlayerNameField extends StatelessWidget {
  const PlayerNameField({
    super.key,
    required this.baseColors,
    required this.playerColors,
    required this.formColors,
    required this.labelStyle,
    required this.isEditMode,
    required this.isManager,
    required this.name,
    required this.findPlayersByName,
    required this.onPlayerSelected,
    required this.onNameSaved,
  });

  final BaseColors baseColors;
  final PlayerColors playerColors;
  final FormColors formColors;
  final TextStyle? labelStyle;
  final bool isEditMode;
  final bool isManager;
  final String? name;
  final Iterable<Player> Function(TextEditingValue) findPlayersByName;
  final ValueChanged<Player> onPlayerSelected;
  final FormFieldSetter<String> onNameSaved;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<Player>(
                initialValue: TextEditingValue(text: name ?? ''),
                optionsBuilder: (TextEditingValue value) {
                  if (isEditMode) return const Iterable<Player>.empty();
                  return findPlayersByName(value);
                },
                onSelected: onPlayerSelected,
                displayStringForOption: (Player player) => player.name,
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4.0,
                      color: baseColors.cardBg,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        child: TapRegion(
                          groupId: const ValueKey('player_name_input'),
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              final skillLevel = option.grade;
                              final isTablet = ResponsiveUtils.isTablet(
                                context,
                              );
                              final descText = option.description.isNotEmpty
                                  ? ' ${option.description}'
                                  : '';
                              return ListTile(
                                dense: !isTablet,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 16.0 : 12.0,
                                  vertical: isTablet ? 6.0 : 0.0,
                                ),
                                title: Text(
                                  '${option.name}$descText ($skillLevel)',
                                  style: (labelStyle ?? const TextStyle())
                                      .copyWith(
                                        fontSize: isTablet ? 18.0 : 14.0,
                                        color: baseColors.textPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TapRegion(
                        groupId: const ValueKey('player_name_input'),
                        child: TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: playerInputDecoration(
                            context,
                            baseColors: baseColors,
                            playerColors: playerColors,
                            formColors: formColors,
                            labelText: '이름',
                            isManager: isManager,
                            isDisabled: false,
                            customVerticalPadding:
                                ResponsiveUtils.isTablet(context) ? 12.0 : 8.0,
                            suffixIcon: IconButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              icon: const Icon(Icons.check),
                            ),
                          ),
                          style: labelStyle,
                          maxLength: 10,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이름을 입력하세요';
                            }
                            if (value.length > 10) return '이름은 10자 이하로 입력해주세요';
                            return null;
                          },
                          onSaved: onNameSaved,
                          onFieldSubmitted: (_) => onFieldSubmitted(),
                        ),
                      );
                    },
              );
            },
          ),
        ),
      ],
    );
  }
}
