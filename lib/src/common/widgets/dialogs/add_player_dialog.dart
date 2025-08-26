import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/skill_utils.dart'; // 공통 유틸리티 파일 import

class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

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
  // _skillLevelToRate 맵 정의 삭제

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;

    // Dynamic font sizes and padding
    final double titleFontSize = isMobileSize ? 24 : 40;
    final double labelFontSize = isMobileSize ? 20 : 32;
    final double switchLabelFontSize = isMobileSize ? 16 : 24;
    final double contentPadding = isMobileSize ? 8.0 : 24.0;
    final double fieldSpacing = isMobileSize ? 16.0 : 32.0;
    final double dialogWidth = isMobileSize ? screenWidth * 0.8 : screenWidth * 0.5;

    return AlertDialog(
      title: Text('플레이어 추가', style: TextStyle(fontSize: titleFontSize)),
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
                  ),
                  value: _selectedSkillLevel,
                  itemHeight: isMobileSize ? 48.0 : 80.0,
                  items: skillLevelToRate.keys.map((String level) { // 공통 skillLevelToRate 사용
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
                      _rate = skillLevelToRate[value]; // 공통 skillLevelToRate 사용
                    }
                  },
                ),
                SizedBox(height: fieldSpacing),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: '성별',
                    labelStyle: TextStyle(fontSize: labelFontSize),
                  ),
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
          child: const Text('취소'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('추가'),
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
