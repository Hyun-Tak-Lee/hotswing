import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 플레이어 정보를 수정할 수 있는 인라인 폼 위젯.
class PlayerEditForm extends StatefulWidget {
  /// 수정할 대상 플레이어 객체.
  final Player player;

  /// 수정 취소 시 호출되는 콜백.
  final VoidCallback onCancel;

  /// [PlayerEditForm] 생성자.
  const PlayerEditForm({
    super.key,
    required this.player,
    required this.onCancel,
  });

  @override
  State<PlayerEditForm> createState() => _PlayerEditFormState();
}

class _PlayerEditFormState extends State<PlayerEditForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late int _currentRate;
  late String _currentSkillLevel;
  late String _currentGender;
  late bool _isManager;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _currentRate = widget.player.rate;
    _currentSkillLevel = widget.player.grade;
    _currentGender = widget.player.gender;
    _isManager = widget.player.role == "manager";
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: formColors.editFormBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: formColors.editFormBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: formColors.editFormShadow,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlayerEditHeader(
              controller: _nameController,
              isManager: _isManager,
              isGuest: widget.player.role == 'guest',
              onToggleManager: () => setState(() => _isManager = !_isManager),
            ),
            const SizedBox(height: 24),
            _PlayerGenderSegment(
              currentGender: _currentGender,
              onSelected: (label) => setState(() => _currentGender = label),
            ),
            const SizedBox(height: 24),
            _PlayerSkillChipList(
              currentSkillLevel: _currentSkillLevel,
              onSelected: _selectSkill,
            ),
            const SizedBox(height: 24),
            _PlayerRateStepper(
              currentRate: _currentRate,
              onDecrease: () => _updateRate(_currentRate - 50),
              onIncrease: () => _updateRate(_currentRate + 50),
            ),
            const SizedBox(height: 32),
            _PlayerEditFooter(onCancel: widget.onCancel, onSubmit: _submit),
          ],
        ),
      ),
    );
  }

  void _updateRate(int newRate) {
    setState(() {
      _currentRate = newRate.clamp(0, 7500);
    });
  }

  void _selectSkill(String level) {
    setState(() {
      _currentSkillLevel = level;
      if (skillLevelToRate.containsKey(level)) {
        _updateRate(skillLevelToRate[level]!);
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<PlayersViewModel>();

      String role = widget.player.role == 'guest'
          ? 'guest'
          : (_isManager ? 'manager' : 'user');

      viewModel.updatePlayer(
        player: widget.player,
        name: _nameController.text,
        role: role,
        rate: _currentRate,
        grade: _currentSkillLevel,
        gender: _currentGender,
        played: widget.player.played,
        waited: widget.player.waited,
        groups: widget.player.groups,
      );

      viewModel.toggleEditMode(null);
    }
  }
}

class _PlayerEditHeader extends StatelessWidget {
  const _PlayerEditHeader({
    required this.controller,
    required this.isManager,
    required this.isGuest,
    required this.onToggleManager,
  });

  final TextEditingController controller;
  final bool isManager;
  final bool isGuest;
  final VoidCallback onToggleManager;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final formColors = context.formColors;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: baseColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: "이름",
              labelStyle: TextStyle(color: baseColors.textSecondary),
              prefixIcon: Icon(
                Icons.edit_note,
                size: 20,
                color: baseColors.textSecondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: formColors.inputBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: formColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: formColors.inputFocusBorder,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: playerColors.playerInputFill,
            ),
            validator: (val) => (val == null || val.isEmpty) ? "필수" : null,
          ),
        ),
        const SizedBox(width: 16),
        _PlayerManagerToggle(
          isManager: isManager,
          isGuest: isGuest,
          onToggle: onToggleManager,
        ),
      ],
    );
  }
}

class _PlayerManagerToggle extends StatelessWidget {
  const _PlayerManagerToggle({
    required this.isManager,
    required this.isGuest,
    required this.onToggle,
  });

  final bool isManager;
  final bool isGuest;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final playerColors = context.playerColors;
    final formColors = context.formColors;

    return InkWell(
      onTap: isGuest ? null : onToggle,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isManager
              ? playerColors.managerToggleActiveBg
              : playerColors.managerToggleInactiveBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isManager
                ? formColors.managerToggleActiveBorder
                : formColors.managerToggleInactiveBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isManager ? Icons.verified_user : Icons.person_outline,
              color: isManager
                  ? Colors.orange
                  : formColors.managerToggleInactiveText,
            ),
            Text(
              "운영진",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isManager
                    ? Colors.orange
                    : formColors.managerToggleInactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerGenderSegment extends StatelessWidget {
  const _PlayerGenderSegment({
    required this.currentGender,
    required this.onSelected,
  });

  final String currentGender;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "성별 선택",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: context.formColors.stepperLabelText,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _PlayerGenderButton(
              label: "남",
              icon: Icons.male,
              isSelected: currentGender == "남",
              onSelected: onSelected,
            ),
            const SizedBox(width: 12),
            _PlayerGenderButton(
              label: "여",
              icon: Icons.female,
              isSelected: currentGender == "여",
              onSelected: onSelected,
            ),
          ],
        ),
      ],
    );
  }
}

class _PlayerGenderButton extends StatelessWidget {
  const _PlayerGenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final formColors = context.formColors;

    return Expanded(
      child: InkWell(
        onTap: () => onSelected(label),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? formColors.genderActiveBg
                : formColors.genderInactiveBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? formColors.genderActiveBorder
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? baseColors.primaryAccent
                    : formColors.genderInactiveText,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? formColors.genderActiveText
                      : formColors.genderInactiveText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerSkillChipList extends StatelessWidget {
  const _PlayerSkillChipList({
    required this.currentSkillLevel,
    required this.onSelected,
  });

  final String currentSkillLevel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final formColors = context.formColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "급수",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: formColors.stepperLabelText,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: skillLevelToRate.keys.map((level) {
              final bool isSelected = currentSkillLevel == level;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) onSelected(level);
                  },
                  backgroundColor: playerColors.chipBg,
                  selectedColor: formColors.skillChipActiveBg,
                  checkmarkColor: formColors.skillChipCheckmark,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? formColors.skillChipActiveText
                        : baseColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PlayerRateStepper extends StatelessWidget {
  const _PlayerRateStepper({
    required this.currentRate,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int currentRate;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: formColors.stepperBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "레이팅 점수",
                style: TextStyle(fontSize: 12, color: formColors.stepperLabelText),
              ),
              Text(
                currentRate.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: formColors.stepperValueText,
                ),
              ),
            ],
          ),
          Row(
            children: [
              _PlayerStepperButton(icon: Icons.remove, onPressed: onDecrease),
              const SizedBox(width: 12),
              _PlayerStepperButton(icon: Icons.add, onPressed: onIncrease),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerStepperButton extends StatelessWidget {
  const _PlayerStepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Material(
      color: formColors.stepperBtnBg,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        icon: Icon(icon, color: formColors.stepperBtnIcon),
        onPressed: onPressed,
      ),
    );
  }
}

class _PlayerEditFooter extends StatelessWidget {
  const _PlayerEditFooter({required this.onCancel, required this.onSubmit});

  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final formColors = context.formColors;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "닫기",
              style: TextStyle(
                color: formColors.footerCancelText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: formColors.footerSubmitBg,
              foregroundColor: formColors.footerSubmitText,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: formColors.footerSubmitShadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 20),
                SizedBox(width: 8),
                Text(
                  "설정 적용",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
