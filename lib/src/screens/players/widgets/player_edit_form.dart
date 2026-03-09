import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';

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
    _currentSkillLevel = rateToSkillLevel(_currentRate);
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
      _currentSkillLevel = rateToSkillLevel(_currentRate);
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
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
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _nameController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: "이름",
              prefixIcon: const Icon(Icons.edit_note, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
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
    return InkWell(
      onTap: isGuest ? null : () => setState(() => _isManager = !_isManager),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isManager ? Colors.orange.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isManager
                ? Colors.orange.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              _isManager ? Icons.verified_user : Icons.person_outline,
              color: _isManager ? Colors.orange : Colors.grey,
            ),
            const Text(
              "운영진",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
        const Text(
          "성별 선택",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSegmentButton("남", "MALE", Icons.male, Colors.blue),
            const SizedBox(width: 12),
            _buildSegmentButton("여", "FEMALE", Icons.female, Colors.blue),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentButton(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    bool isSelected = _currentGender == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentGender = label),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (color is MaterialColor ? color.shade900 : color)
                      : Colors.grey,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "급수",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
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
                      _updateRate(skillLevelToRate[level]!);
                    }
                  },
                  selectedColor: Colors.blue.shade100,
                  checkmarkColor: Colors.blue.shade900,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue.shade900 : Colors.black87,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "레이팅 점수",
                style: TextStyle(fontSize: 12, color: Colors.blueGrey),
              ),
              Text(
                _currentRate.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.blue,
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
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: IconButton(
        icon: Icon(icon, color: Colors.blue),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFooterActions() {
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
            child: const Text(
              "닫기",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shadowColor: Colors.blue.withValues(alpha: 0.4),
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
