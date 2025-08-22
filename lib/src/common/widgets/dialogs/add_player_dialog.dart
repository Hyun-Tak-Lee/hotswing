import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double tabletThreshold = 600.0;
    final isMobileSize = screenWidth < tabletThreshold;
    
    return AlertDialog(
      title: const Text('플레이어 추가', style: TextStyle(fontSize: 24)),
      content: Form(
        key: _formKey,
        child: Padding(  // Added Padding widget here
          padding: const EdgeInsets.all(8.0), // Added padding
          child: SizedBox(
            width: isMobileSize ? screenWidth * 0.7 : screenWidth * 0.25,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: '이름',
                          labelStyle: TextStyle(fontSize: 24),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '이름을 입력하세요.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 8), 
                    const Text('운영진', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _isManager,
                      onChanged: (bool value) {
                        setState(() {
                          _isManager = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Added spacing
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Rate (숫자)',
                    labelStyle: TextStyle(fontSize: 24),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '수치를 입력하세요.';
                    }
                    if (int.tryParse(value) == null) {
                      return '숫자만 입력하세요.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _rate = int.tryParse(value!);
                  },
                ),
                const SizedBox(height: 16), // Added spacing
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '성별',
                    labelStyle: TextStyle(fontSize: 24),
                  ),
                  value: _selectedGender,
                  items: _genders.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
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
