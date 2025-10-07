import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for TextInputFormatter
import 'package:hotswing/src/common/utils/skill_utils.dart';
import 'package:hotswing/src/providers/players_provider.dart';

class AddPlayerDialog extends StatefulWidget {
  final Player? player;
  final bool isGuest;

  const AddPlayerDialog({super.key, this.player, this.isGuest = false});

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  int? _rate;
  String? _selectedGender;
  final List<String> _genders = ['남', '여'];
  bool _isManager = false;
  String? _selectedSkillLevel;
  int? _playCount;
  int? _waitCount;

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      _name = widget.player!.name;
      _rate = widget.player!.rate;
      _selectedSkillLevel = rateToSkillLevel[widget.player!.rate];
      _selectedGender = widget.player!.gender;
      _isManager = widget.player!.role == "manager" ? true : false;
      _playCount = widget.player!.played;
      _waitCount = widget.player!.waited;
    }
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
        ? screenWidth * 0.8
        : screenWidth * 0.5;
    final double buttonFontSize = isMobileSize ? 16 : 28;

    return AlertDialog(
      title: Text(
        isEditMode ? '플레이어 수정' : '플레이어 추가',
        style: TextStyle(fontSize: titleFontSize),
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
                        child: TextFormField(
                          initialValue: _name,
                          decoration: InputDecoration(
                            labelText: '이름',
                            labelStyle: TextStyle(fontSize: labelFontSize),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '이름을 입력하세요.';
                            }
                            if (value.length > 7) {
                              return '이름은 7자 이하로 입력해주세요.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _name = value;
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
                                  onChanged: (bool value) {
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
                    onChanged: (String? newValue) {
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
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                    },
                    validator: (value) => value == null ? '성별을 선택하세요.' : null,
                    onSaved: (value) {
                      _selectedGender = value;
                    },
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
                'playCount': _playCount,
                'waitCount': _waitCount,
              });
            }
          },
        ),
      ],
    );
  }
}
