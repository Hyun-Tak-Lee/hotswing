import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotswing/src/common/forms/multi_select_form.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:realm/realm.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 새로운 플레이어를 추가하거나 기존 플레이어의 정보를 수정할 때 사용하는 다이얼로그 위젯입니다.
///
/// 게스트 모드([isGuest]) 여부와 기존 플레이어 정보([player])를 받아
/// 그에 맞는 UI와 로직을 제공합니다.
class AddPlayerDialog extends StatefulWidget {
  final PlayersProvider playersProvider;
  final Player? player;
  final bool isGuest;

  const AddPlayerDialog({
    super.key,
    required this.playersProvider,
    this.player,
    this.isGuest = false,
  });

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  static const int _maxRate = 7500;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _rateController;

  bool _isLoaded = false;
  bool _isManager = false;

  Player? _player;
  ObjectId? _id;
  String? _name;
  int? _rate;
  PlayerGender? _selectedGender;
  String? _selectedSkillLevel;
  int? _playCount;
  int? _waitCount;
  List<ObjectId> _groups = [];

  final List<PlayerGender> _genders = PlayerGender.values;

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      _id = widget.player!.id;
      _name = widget.player!.name;
      _rate = widget.player!.rate;
      _selectedSkillLevel = widget.player!.grade;
      _selectedGender = PlayerGender.values.cast<PlayerGender?>().firstWhere(
        (element) => element?.value == widget.player!.gender,
        orElse: () => null,
      );
      _isManager = widget.player!.role == "manager";
      _playCount = widget.player!.played;
      _waitCount = widget.player!.waited;
      _groups = widget.player!.groups;
    }
    _rateController = TextEditingController(text: _rate?.toString() ?? '');
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  /// 이름 입력 시 자동완성을 위해 플레이어를 검색합니다.
  ///
  /// [textEditingValue]의 텍스트를 접두사로 사용하여 일치하는 플레이어 목록을 반환합니다.
  Iterable<Player> _findPlayersByName(TextEditingValue textEditingValue) {
    setState(() {
      _isLoaded = false;
    });
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Player>.empty();
    }
    return widget.playersProvider.findPlayersByPrefix(
      textEditingValue.text,
      10,
    );
  }

  /// 자동완성에서 선택된 플레이어의 정보를 폼의 각 필드에 로드합니다.
  void _loadPlayerAllForms(Player player) {
    setState(() {
      _isLoaded = true;
      _player = player;
      _name = player.name;
      _rate = player.rate;
      _rateController.text = player.rate.toString();
      _selectedSkillLevel = player.grade;
      _selectedGender = PlayerGender.values.cast<PlayerGender?>().firstWhere(
        (element) => element?.value == player.gender,
        orElse: () => null,
      );
      _isManager = player.role == "manager";
    });
  }

  /// 입력된 폼 데이터를 검증하고, 유효한 경우 이전 화면으로 데이터를 반환하며 다이얼로그를 닫습니다.
  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String role = "user";
      if (widget.isGuest || (widget.player?.role == 'guest')) {
        role = 'guest';
      } else if (_isManager) {
        role = "manager";
      }

      Navigator.of(context).pop({
        'name': _name,
        'rate': _rate,
        'grade': _selectedSkillLevel,
        'gender': _selectedGender?.value,
        'role': role,
        'played': _playCount,
        'waited': _waitCount,
        'groups': _groups,
        'loaded': _isLoaded,
        'player': _player,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final formColors = context.formColors;
    final dialogColors = context.dialogColors;

    final bool isEditMode = widget.player != null;
    final bool isGuestMode = widget.isGuest || (widget.player?.role == 'guest');

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaWidth = MediaQuery.of(context).size.width;
        final bool isTablet = ResponsiveUtils.isTablet(context);

        final textTheme = Theme.of(context).textTheme;
        final double dialogWidth = isTablet ? 500.0 : mediaWidth * 0.9;
        final double fieldSpacing = isTablet ? 24.0 : 16.0;

        // 반응형 스타일 정의
        final titleStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          textTheme.headlineSmall,
        )?.copyWith(fontWeight: FontWeight.bold);
        final buttonStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          textTheme.titleMedium,
        );

        final labelStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          Theme.of(context).textTheme.bodyLarge,
        )?.copyWith(color: baseColors.textPrimary, fontWeight: FontWeight.w500);

        return AlertDialog(
          backgroundColor: baseColors.cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isManager
                    ? [
                        dialogColors.dialogTitleManagerBgStart,
                        dialogColors.dialogTitleManagerBgEnd,
                      ]
                    : [
                        dialogColors.dialogTitleBgStart,
                        dialogColors.dialogTitleBgEnd,
                      ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${isGuestMode ? '게스트' : '회원'} ${isEditMode ? '수정' : '추가'}',
                  style: titleStyle,
                ),
                if (!isGuestMode)
                  Opacity(
                    opacity: _isLoaded ? 0.5 : 1.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '운영진',
                          style: ResponsiveUtils.getResponsiveStyle(
                            context,
                            textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: _isManager,
                          activeThumbColor: Theme.of(context).primaryColor,
                          onChanged: _isLoaded
                              ? null
                              : (value) {
                                  setState(() {
                                    _isManager = value;
                                  });
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  _updateRate(_rate ?? 0); // Re-clamping on role switch
                                },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: dialogWidth,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildNameAndManagerSection(baseColors, playerColors, formColors, labelStyle, isEditMode, isGuestMode),
                    SizedBox(height: fieldSpacing),
                    _buildSkillLevelField(baseColors, playerColors, formColors, labelStyle),
                    SizedBox(height: fieldSpacing),
                    _buildGenderField(baseColors, playerColors, formColors, labelStyle),
                    SizedBox(height: fieldSpacing),
                    _buildGroupPlayerField(),
                    if (isEditMode) ...[
                      SizedBox(height: fieldSpacing),
                      _buildStatsRow(baseColors, playerColors, formColors, labelStyle),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: dialogColors.dialogButtonCancelText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소', style: buttonStyle),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isManager
                    ? dialogColors.dialogTitleManagerBgEnd
                    : dialogColors.dialogButtonConfirmBg,
                foregroundColor: _isManager
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? playerColors.roleManager
                          : Colors.brown[900])
                    : dialogColors.dialogButtonConfirmText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: _submit,
              child: Text(isEditMode ? '수정' : '추가', style: buttonStyle),
            ),
          ],
        );
      },
    );
  }

  /// 이름 입력 필드와 운영진 토글 스위치 섹션을 빌드합니다.
  ///
  /// [isEditMode]인 경우 자동완성이 비활성화되며, [isGuestMode]인 경우 운영진 토글이 숨겨집니다.
  Widget _buildNameAndManagerSection(
    BaseColors baseColors,
    PlayerColors playerColors,
    FormColors formColors,
    TextStyle? labelStyle,
    bool isEditMode,
    bool isGuestMode,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Autocomplete<Player>(
                initialValue: TextEditingValue(text: _name ?? ''),
                optionsBuilder: (TextEditingValue value) {
                  if (isEditMode) return const Iterable<Player>.empty();
                  return _findPlayersByName(value);
                },
                onSelected: _loadPlayerAllForms,
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
                              return ListTile(
                                title: Text(
                                  '${option.name} ($skillLevel)',
                                  style: TextStyle(color: baseColors.textPrimary),
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
                          decoration: _getCommonInputDecoration(
                            baseColors,
                            playerColors,
                            formColors,
                            '이름',
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
                          onSaved: (value) => _name = value,
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

  /// 레이팅을 주어진 [newRate]로 업데이트합니다.
  /// 값은 0에서 [_maxRate] 사이로 제한됩니다.
  void _updateRate(int newRate) {
    final clampedRate = newRate.clamp(0, _maxRate);
    setState(() {
      _rate = clampedRate;
      _rateController.text = clampedRate.toString();
    });
  }

  /// 급수 선택 드롭다운과 레이팅 입력 필드를 포함한 행을 빌드합니다.
  Widget _buildSkillLevelField(
    BaseColors baseColors,
    PlayerColors playerColors,
    FormColors formColors,
    TextStyle? labelStyle,
  ) {
    return Opacity(
      opacity: _isLoaded ? 0.5 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              decoration: _getCommonInputDecoration(
                baseColors,
                playerColors,
                formColors,
                '급수',
                isDisabled: _isLoaded,
                customVerticalPadding: ResponsiveUtils.isTablet(context)
                    ? 6.0
                    : 2.0,
              ),
              isExpanded: true,
              isDense: false,
              key: ValueKey('skill_$_selectedSkillLevel'),
              initialValue: _selectedSkillLevel,
              items: skillLevelToRate.keys.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level, style: labelStyle),
                );
              }).toList(),
              onChanged: _isLoaded
                  ? null
                  : (newValue) {
                      setState(() {
                        _selectedSkillLevel = newValue;
                        if (newValue != null &&
                            skillLevelToRate.containsKey(newValue)) {
                          _updateRate(skillLevelToRate[newValue]!);
                        }
                      });
                    },
              validator: (value) => value == null ? '급수를 선택하세요.' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(flex: 3, child: _buildRateField(baseColors, playerColors, formColors, labelStyle)),
        ],
      ),
    );
  }

  /// 레이팅 증가/감소 버튼과 직접 입력 가능한 레이팅 필드를 빌드합니다.
  Widget _buildRateField(
    BaseColors baseColors,
    PlayerColors playerColors,
    FormColors formColors,
    TextStyle? labelStyle,
  ) {
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
          onPressed: _isLoaded
              ? null
              : () {
                  int currentRate =
                      int.tryParse(_rateController.text) ?? (_rate ?? 0);
                  int newRate = ((currentRate - 1) ~/ 50) * 50;
                  if (newRate < 0) newRate = 0;
                  _updateRate(newRate);
                },
        ),
        Expanded(
          child: TextFormField(
            controller: _rateController,
            decoration: _getCommonInputDecoration(
              baseColors,
              playerColors,
              formColors,
              'Rate',
              isDisabled: _isLoaded,
              customVerticalPadding: isTablet ? 6.0 : 2.0,
            ),
            style: labelStyle?.copyWith(fontSize: isTablet ? null : 14.0),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !_isLoaded,
            onChanged: (value) {
              int? parsed = int.tryParse(value);
              if (parsed != null) {
                if (parsed > _maxRate) {
                  parsed = _maxRate;
                  _rateController.text = _maxRate.toString();
                  _rateController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _rateController.text.length),
                  );
                } else if (parsed < 0) {
                  parsed = 0;
                  _rateController.text = '0';
                  _rateController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _rateController.text.length),
                  );
                }
                setState(() {
                  _rate = parsed;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) return '입력 필요';
              return null;
            },
            onSaved: (value) {
              int parsed = int.tryParse(value ?? '') ?? (_rate ?? 0);
              _rate = parsed.clamp(0, _maxRate);
            },
          ),
        ),
        IconButton(
          padding: padding,
          constraints: constraints,
          iconSize: iconSize,
          icon: const Icon(Icons.add),
          onPressed: _isLoaded
              ? null
              : () {
                  int currentRate =
                      int.tryParse(_rateController.text) ?? (_rate ?? 0);
                  int newRate = (currentRate ~/ 50) * 50 + 50;
                  if (newRate > _maxRate) newRate = _maxRate;
                  _updateRate(newRate);
                },
        ),
      ],
    );
  }

  /// 성별 선택 드롭다운 필드를 빌드합니다.
  Widget _buildGenderField(
    BaseColors baseColors,
    PlayerColors playerColors,
    FormColors formColors,
    TextStyle? labelStyle,
  ) {
    return Opacity(
      opacity: _isLoaded ? 0.5 : 1.0,
      child: DropdownButtonFormField<PlayerGender>(
        key: ValueKey('gender_$_selectedGender'),
        isExpanded: true,
        isDense: false,
        decoration: _getCommonInputDecoration(
          baseColors,
          playerColors,
          formColors,
          '성별',
          isDisabled: _isLoaded,
          customVerticalPadding: ResponsiveUtils.isTablet(context) ? 6.0 : 2.0,
        ),
        initialValue: _selectedGender,
        items: _genders.map((PlayerGender gender) {
          return DropdownMenuItem<PlayerGender>(
            value: gender,
            child: Text(gender.label, style: labelStyle),
          );
        }).toList(),
        onChanged: _isLoaded
            ? null
            : (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
        validator: (value) => value == null ? '성별을 선택하세요.' : null,
        onSaved: (value) => _selectedGender = value,
      ),
    );
  }

  /// 그룹 플레이어 다중 선택 필드를 빌드합니다.
  Widget _buildGroupPlayerField() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60.0),
      child: MultiSelectForm(
        title: '그룹 플레이어',
        options: widget.playersProvider.players.values
            .map((p) => p.name)
            .toList(),
        optionsId: widget.playersProvider.players.values
            .map((p) => p.id)
            .toList(),
        groupsOptionId: widget.playersProvider.players.values
            .where((p) => p.groups.isNotEmpty && !(widget.player?.groups.contains(p.id) ?? false))
            .map((p) => p.id)
            .toList(),
        initialValue: _groups,
        currentId: _id,
        onSelectionChanged: (selectedOptions) {
          setState(() {
            _groups = selectedOptions;
          });
        },
      ),
    );
  }

  /// (수정 모드에만 표시되는) 플레이 횟수와 대기 횟수 입력 필드를 빌드합니다.
  Widget _buildStatsRow(
    BaseColors baseColors,
    PlayerColors playerColors,
    FormColors formColors,
    TextStyle? labelStyle,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _playCount?.toString(),
            decoration: _getCommonInputDecoration(baseColors, playerColors, formColors, '플레이 횟수', isDisabled: false),
            style: labelStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return '입력 필요';
              return null;
            },
            onSaved: (value) => _playCount = int.tryParse(value ?? '0'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: _waitCount?.toString(),
            decoration: _getCommonInputDecoration(baseColors, playerColors, formColors, '대기 횟수', isDisabled: false),
            style: labelStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return '입력 필요';
              return null;
            },
            onSaved: (value) => _waitCount = int.tryParse(value ?? '0'),
          ),
        ),
      ],
    );
  }

  InputDecoration _getCommonInputDecoration(
    BaseColors baseColors,
    PlayerColors playerColors,
    FormColors formColors,
    String labelText, {
    double? customVerticalPadding,
    Widget? suffixIcon,
    bool isDisabled = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: isDisabled ? baseColors.textSecondary.withValues(alpha: 0.5) : baseColors.textSecondary,
      ),
      floatingLabelStyle: TextStyle(
        color: isDisabled ? baseColors.textSecondary.withValues(alpha: 0.5) : baseColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      filled: true,
      fillColor: isDisabled
          ? playerColors.chipBg
          : playerColors.playerInputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDisabled
              ? Colors.transparent
              : formColors.inputBorder,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDisabled
              ? Colors.transparent
              : formColors.inputBorder,
          width: 1,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent, width: 0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: _isManager
              ? playerColors.roleManager
              : formColors.inputFocusBorder,
          width: 2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical:
            customVerticalPadding ??
            (ResponsiveUtils.isTablet(context) ? 16.0 : 12.0),
      ),
      suffixIcon: suffixIcon,
    );
  }
}
