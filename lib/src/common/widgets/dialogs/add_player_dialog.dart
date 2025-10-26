import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotswing/src/common/forms/multi_select_form.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart';
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
  String? _selectedGender;
  final List<String> _genders = ['남', '여'];
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
      _selectedGender = widget.player!.gender;
      _isManager = widget.player!.role == "manager" ? true : false;
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
    List<Player> searchPlayers = widget.playersProvider.findPlayersByPrefix(
      textEditingValue.text,
      10,
    );

    return searchPlayers;
  }

  void _loadPlayerAllForms(Player player) {
    setState(() {
      isLoaded = true;
      _player = player;
      _name = player.name;
      _selectedSkillLevel = rateToSkillLevel[player.rate];
      _selectedGender = player.gender;
      _isManager = player.role == "manager" ? true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;
    final bool isEditMode = widget.player != null;
    final bool isGuestMode = widget.isGuest || (widget.player?.role == 'guest');

    final double titleFontSize = isMobileSize ? 24 : 40;
    final double labelFontSize = isMobileSize ? 20 : 32;
    final double switchLabelFontSize = isMobileSize ? 16 : 24;
    final double contentPadding = isMobileSize ? 8.0 : 24.0;
    final double fieldSpacing = isMobileSize ? 16.0 : 32.0;
    final double dialogWidth = isMobileSize
        ? screenWidth * 0.9
        : screenWidth * 0.7;
    final double buttonFontSize = isMobileSize ? 16 : 28;

    final List<Player> allPlayers =
        widget.playersProvider.players.values.toList() ?? [];
    final List<ObjectId> allPlayerIds = allPlayers
        .map((player) => player.id)
        .toList();
    final List<String> allPlayerNames = allPlayers
        .map((player) => player.name)
        .toList();
    final List<ObjectId> allGroupedIds = allPlayers
        .where((player) => player.groups.isNotEmpty)
        .map((player) => player.id)
        .toList();

    return AlertDialog(
      title: Container(
        padding: EdgeInsets.only(left: isMobileSize ? 8 : 16),
        decoration: BoxDecoration(
          color: Color(0x99A0E9FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${isGuestMode ? '게스트' : '회원'} ${isEditMode ? '수정' : '추가'}',
          style: TextStyle(fontSize: titleFontSize),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(contentPadding),
            child: SizedBox(
              width: dialogWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: isMobileSize ? 1 : 2,
                        child: Autocomplete<Player>(
                          initialValue: TextEditingValue(text: _name ?? ''),
                          optionsBuilder: (TextEditingValue value) {
                            if (isEditMode) {
                              return const Iterable<Player>.empty();
                            }
                            return _findPlayersByName(value);
                          },
                          onSelected: _loadPlayerAllForms,
                          displayStringForOption: (Player player) =>
                              player.name,
                          fieldViewBuilder:
                              (
                                BuildContext context,
                                TextEditingController
                                fieldTextEditingController,
                                FocusNode fieldFocusNode,
                                VoidCallback onFieldSubmitted,
                              ) {
                                return TextFormField(
                                  controller: fieldTextEditingController,
                                  focusNode: fieldFocusNode,
                                  decoration: InputDecoration(
                                    labelText: '이름',
                                    labelStyle: TextStyle(
                                      fontSize: labelFontSize,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '이름을 입력하세요';
                                    }
                                    if (value.length > 7) {
                                      return '이름은 7자 이하로 입력해주세요';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    _name = value;
                                  },
                                  onFieldSubmitted: (_) => onFieldSubmitted(),
                                );
                              },
                        ),
                      ),
                      if (!isGuestMode)
                        Flexible(
                          flex: isMobileSize ? 1 : 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '운영진',
                                style: TextStyle(fontSize: switchLabelFontSize),
                              ),
                              SizedBox(width: isMobileSize ? 4 : 20),
                              Transform.scale(
                                scale: isMobileSize ? 1.0 : 1.5,
                                child: Switch(
                                  value: _isManager,
                                  onChanged: isLoaded
                                      ? null
                                      : (bool value) {
                                          setState(() {
                                            _isManager = value;
                                          });
                                        },
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: fieldSpacing),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '급수',
                      labelStyle: TextStyle(fontSize: labelFontSize),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    isDense: false,
                    value: _selectedSkillLevel,
                    itemHeight: isMobileSize ? 48.0 : 80.0,
                    items: skillLevelToRate.keys.map((String level) {
                      return DropdownMenuItem<String>(
                        value: level,
                        child: Text(
                          level,
                          style: TextStyle(fontSize: labelFontSize),
                        ),
                      );
                    }).toList(),
                    onChanged: isLoaded
                        ? null
                        : (String? newValue) {
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
                  ),
                  SizedBox(height: fieldSpacing),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: '성별',
                      labelStyle: TextStyle(fontSize: labelFontSize),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    isDense: false,
                    value: _selectedGender,
                    itemHeight: isMobileSize ? 48.0 : 80.0,
                    items: _genders.map((String gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(
                          gender,
                          style: TextStyle(fontSize: labelFontSize),
                        ),
                      );
                    }).toList(),
                    onChanged: isLoaded
                        ? null
                        : (String? newValue) {
                            setState(() {
                              _selectedGender = newValue;
                            });
                          },
                    validator: (value) => value == null ? '성별을 선택하세요.' : null,
                    onSaved: (value) {
                      _selectedGender = value;
                    },
                  ),
                  SizedBox(height: fieldSpacing),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 60.0),
                    child: MultiSelectForm(
                      title: '그룹 플레이어',
                      options: allPlayerNames,
                      optionsId: allPlayerIds,
                      groupsOptionId: allGroupedIds,
                      initialValue: _groups,
                      currentId: _id,
                      onSelectionChanged: (selectedOptions) {
                        setState(() {
                          _groups = selectedOptions;
                        });
                      },
                    ),
                  ),
                  if (isEditMode) ...[
                    SizedBox(height: fieldSpacing),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            initialValue: _playCount?.toString(),
                            decoration: InputDecoration(
                              labelText: '플레이 횟수',
                              labelStyle: TextStyle(fontSize: labelFontSize),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '플레이 횟수를 입력하세요.';
                              }
                              if (int.tryParse(value) == null) {
                                return '숫자만 입력해주세요.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _playCount = int.tryParse(value ?? '0');
                            },
                          ),
                        ),
                        SizedBox(width: fieldSpacing), // Horizontal spacing
                        Flexible(
                          flex: 1,
                          child: TextFormField(
                            initialValue: _waitCount?.toString(),
                            decoration: InputDecoration(
                              labelText: '대기 횟수',
                              labelStyle: TextStyle(fontSize: labelFontSize),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '대기 횟수를 입력하세요.';
                              }
                              if (int.tryParse(value) == null) {
                                return '숫자만 입력해주세요.';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _waitCount = int.tryParse(value ?? '0');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('취소', style: TextStyle(fontSize: buttonFontSize)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            isEditMode ? '수정' : '추가',
            style: TextStyle(fontSize: buttonFontSize),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop({
                'name': _name,
                'rate': _rate,
                'gender': _selectedGender,
                'role': isGuestMode
                    ? 'guest'
                    : (_isManager ? "manager" : "user"),
                'played': _playCount,
                'waited': _waitCount,
                'groups': _groups,
                'loaded': isLoaded,
                'player': _player,
              });
            }
          },
        ),
      ],
    );
  }
}
