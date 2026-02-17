import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotswing/src/common/forms/multi_select_form.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:realm/realm.dart';

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
  final _formKey = GlobalKey<FormState>();
  ObjectId? _id;
  String? _name;
  int? _rate;
  PlayerGender? _selectedGender;
  final List<PlayerGender> _genders = PlayerGender.values;
  bool _isManager = false;
  String? _selectedSkillLevel;
  int? _playCount;
  int? _waitCount;
  List<ObjectId> _groups = [];
  Player? _player;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      _id = widget.player!.id;
      _name = widget.player!.name;
      _rate = widget.player!.rate;
      _selectedSkillLevel = rateToSkillLevel[widget.player!.rate];
      _selectedGender = PlayerGender.values.cast<PlayerGender?>().firstWhere(
        (element) => element?.value == widget.player!.gender,
        orElse: () => null,
      );
      _isManager = widget.player!.role == "manager";
      _playCount = widget.player!.played;
      _waitCount = widget.player!.waited;
      _groups = widget.player!.groups;
    }
  }

  Iterable<Player> _findPlayersByName(TextEditingValue textEditingValue) {
    setState(() {
      isLoaded = false;
    });
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Player>.empty();
    }
    return widget.playersProvider.findPlayersByPrefix(
      textEditingValue.text,
      10,
    );
  }

  void _loadPlayerAllForms(Player player) {
    setState(() {
      isLoaded = true;
      _player = player;
      _name = player.name;
      _selectedSkillLevel = rateToSkillLevel[player.rate];
      _selectedGender = PlayerGender.values.cast<PlayerGender?>().firstWhere(
        (element) => element?.value == player.gender,
        orElse: () => null,
      );
      _isManager = player.role == "manager";
    });
  }

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
        'gender': _selectedGender?.value,
        'role': role,
        'played': _playCount,
        'waited': _waitCount,
        'groups': _groups,
        'loaded': isLoaded,
        'player': _player,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.player != null;
    final bool isGuestMode = widget.isGuest || (widget.player?.role == 'guest');

    return LayoutBuilder(
      builder: (context, constraints) {
        // 기존 constraints를 사용하여 "모바일" 크기인지 확인합니다.
        // 하지만 이것은 Dialog 내부이므로 constraints가 더 느슨할 수 있습니다.
        // 전체 디바이스 유형을 확인하려면 context의 MediaQuery를 확인하는 것이 더 안전합니다.
        final mediaWidth = MediaQuery.of(context).size.width;
        final bool isMobile = ResponsiveUtils.isMobile(context);

        final textTheme = Theme.of(context).textTheme;
        final double dialogWidth = isMobile ? mediaWidth * 0.9 : 500.0;
        final double fieldSpacing = isMobile ? 16.0 : 24.0;

        // 반응형 스타일 정의
        final titleStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          textTheme.headlineSmall,
        )?.copyWith(fontWeight: FontWeight.bold);
        final labelStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          textTheme.bodyLarge,
        );
        final buttonStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          textTheme.titleMedium,
        );

        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0x99A0E9FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '${isGuestMode ? '게스트' : '회원'} ${isEditMode ? '수정' : '추가'}',
              style: titleStyle,
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
                    _buildNameAndManagerSection(
                      isMobile,
                      isEditMode,
                      isGuestMode,
                      labelStyle,
                    ),
                    SizedBox(height: fieldSpacing),
                    _buildSkillLevelField(isMobile, labelStyle),
                    SizedBox(height: fieldSpacing),
                    _buildGenderField(isMobile, labelStyle),
                    SizedBox(height: fieldSpacing),
                    _buildGroupPlayerField(isMobile, textTheme),
                    if (isEditMode) ...[
                      SizedBox(height: fieldSpacing),
                      _buildStatsRow(isMobile, labelStyle),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소', style: buttonStyle),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isEditMode ? '수정' : '추가', style: buttonStyle),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNameAndManagerSection(
    bool isMobile,
    bool isEditMode,
    bool isGuestMode,
    TextStyle? labelStyle,
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
                              final skillLevel =
                                  rateToSkillLevel[option.rate] ??
                                  '${option.rate}';
                              return ListTile(
                                title: Text('${option.name} ($skillLevel)'),
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
                          decoration: InputDecoration(
                            labelText: '이름',
                            labelStyle: labelStyle,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
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
        if (!isGuestMode) ...[
          const SizedBox(width: 16),
          Text('운영진', style: labelStyle),
          Switch(
            value: _isManager,
            onChanged: isLoaded
                ? null
                : (value) {
                    setState(() {
                      _isManager = value;
                    });
                  },
          ),
        ],
      ],
    );
  }

  Widget _buildSkillLevelField(bool isMobile, TextStyle? labelStyle) {
    return DropdownButtonFormField<String>(
      key: ValueKey('skill_$_selectedSkillLevel'),
      decoration: InputDecoration(
        labelText: '급수',
        labelStyle: labelStyle,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      initialValue: _selectedSkillLevel,
      items: skillLevelToRate.keys.map((String level) {
        return DropdownMenuItem<String>(
          value: level,
          child: Text(level, style: labelStyle),
        );
      }).toList(),
      onChanged: isLoaded
          ? null
          : (newValue) {
              setState(() {
                _selectedSkillLevel = newValue;
              });
            },
      validator: (value) => value == null ? '급수를 선택하세요.' : null,
      onSaved: (value) {
        if (value != null) {
          _rate = skillLevelToRate[value];
        }
      },
    );
  }

  Widget _buildGenderField(bool isMobile, TextStyle? labelStyle) {
    return DropdownButtonFormField<PlayerGender>(
      key: ValueKey('gender_$_selectedGender'),
      decoration: InputDecoration(
        labelText: '성별',
        labelStyle: labelStyle,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      initialValue: _selectedGender,
      items: _genders.map((PlayerGender gender) {
        return DropdownMenuItem<PlayerGender>(
          value: gender,
          child: Text(gender.label, style: labelStyle),
        );
      }).toList(),
      onChanged: isLoaded
          ? null
          : (newValue) {
              setState(() {
                _selectedGender = newValue;
              });
            },
      validator: (value) => value == null ? '성별을 선택하세요.' : null,
      onSaved: (value) => _selectedGender = value,
    );
  }

  Widget _buildGroupPlayerField(bool isMobile, TextTheme textTheme) {
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
            .where((p) => p.groups.isNotEmpty)
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

  Widget _buildStatsRow(bool isMobile, TextStyle? labelStyle) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _playCount?.toString(),
            decoration: InputDecoration(
              labelText: '플레이 횟수',
              labelStyle: labelStyle,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
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
            decoration: InputDecoration(
              labelText: '대기 횟수',
              labelStyle: labelStyle,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
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
}
