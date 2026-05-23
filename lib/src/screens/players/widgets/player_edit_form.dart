import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

class PlayerEditForm extends StatefulWidget {
  final Player player;
  final VoidCallback onCancel;

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

  void _updateRate(int newRate) {
    setState(() {
      _currentRate = newRate.clamp(0, 7500);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<PlayersViewModel>(context, listen: false);

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
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildGenderSegment(),
            const SizedBox(height: 24),
            _buildSkillChipList(),
            const SizedBox(height: 24),
            _buildRateStepper(),
            const SizedBox(height: 32),
            _buildFooterActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final formColors = context.formColors;

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _nameController,
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
        _buildManagerToggle(),
      ],
    );
  }

  Widget _buildManagerToggle() {
    final isGuest = widget.player.role == 'guest';
    final playerColors = context.playerColors;
    final formColors = context.formColors;

    return InkWell(
      onTap: isGuest ? null : () => setState(() => _isManager = !_isManager),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isManager
              ? playerColors.managerToggleActiveBg
              : playerColors.managerToggleInactiveBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isManager
                ? formColors.managerToggleActiveBorder
                : formColors.managerToggleInactiveBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _isManager ? Icons.verified_user : Icons.person_outline,
              color: _isManager
                  ? Colors.orange
                  : formColors.managerToggleInactiveText,
            ),
            Text(
              "운영진",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _isManager
                    ? Colors.orange
                    : formColors.managerToggleInactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSegment() {
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
            _buildSegmentButton("남", "MALE", Icons.male),
            const SizedBox(width: 12),
            _buildSegmentButton("여", "FEMALE", Icons.female),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentButton(String label, String value, IconData icon) {
    bool isSelected = _currentGender == label;
    final baseColors = context.baseColors;
    final formColors = context.formColors;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentGender = label),
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

  Widget _buildSkillChipList() {
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
              bool isSelected = _currentSkillLevel == level;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _currentSkillLevel = level;
                        if (skillLevelToRate.containsKey(level)) {
                          _updateRate(skillLevelToRate[level]!);
                        }
                      });
                    }
                  },
                  backgroundColor: playerColors.chipBg,
                  selectedColor: formColors.skillChipActiveBg,
                  checkmarkColor: formColors.skillChipCheckmark,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? formColors.skillChipActiveText
                        : baseColors.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRateStepper() {
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
                style: TextStyle(
                  fontSize: 12,
                  color: formColors.stepperLabelText,
                ),
              ),
              Text(
                _currentRate.toString(),
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
              _buildStepperButton(
                Icons.remove,
                () => _updateRate(_currentRate - 50),
              ),
              const SizedBox(width: 12),
              _buildStepperButton(
                Icons.add,
                () => _updateRate(_currentRate + 50),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton(IconData icon, VoidCallback onPressed) {
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

  Widget _buildFooterActions() {
    final formColors = context.formColors;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: widget.onCancel,
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
            onPressed: _submit,
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
