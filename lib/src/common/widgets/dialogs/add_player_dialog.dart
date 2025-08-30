import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart';
import 'package:hotswing/src/providers/players_provider.dart';

class AddPlayerDialog extends StatefulWidget {
  final Player? player;

  const AddPlayerDialog({super.key, this.player});

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

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      // 수정 모드: 기존 플레이어 정보로 상태 변수 초기화
      _name = widget.player!.name;
      _rate = widget.player!.rate;
      // rate (int)를 _selectedSkillLevel (String)으로 변환 (skill_utils.dart의 getter 사용)
      _selectedSkillLevel = rateToSkillLevel[widget.player!.rate];
      _selectedGender = widget.player!.gender;
      _isManager = widget.player!.manager;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;
    final bool isEditMode = widget.player != null; // 수정 모드 여부

    final double titleFontSize = isMobileSize ? 24 : 40;
    final double labelFontSize = isMobileSize ? 20 : 32;
    final double switchLabelFontSize = isMobileSize ? 16 : 24;
    final double contentPadding = isMobileSize ? 8.0 : 24.0;
    final double fieldSpacing = isMobileSize ? 16.0 : 32.0;
    final double dialogWidth = isMobileSize ? screenWidth * 0.8 : screenWidth * 0.5;
    final double buttonFontSize = isMobileSize ? 16 : 22;

    return AlertDialog(
      title: Text(isEditMode ? '플레이어 수정' : '플레이어 추가', // 제목 동적 변경
          style: TextStyle(fontSize: titleFontSize)),
      content: Form(
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
                      flex: isMobileSize ? 3 : 2,
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
                    Flexible(
                      flex: isMobileSize ? 2 : 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('운영진', style: TextStyle(fontSize: switchLabelFontSize)),
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
                      child: Text(level, style: TextStyle(fontSize: labelFontSize)),
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
                      child: Text(gender, style: TextStyle(fontSize: labelFontSize)),
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
              ],
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
          child: Text(isEditMode ? '수정' : '추가',
              style: TextStyle(fontSize: buttonFontSize)),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(
                context,
              ).pop({'name': _name, 'rate': _rate, 'gender': _selectedGender, 'manager': _isManager});
            }
          },
        ),
      ],
    );
  }
}
