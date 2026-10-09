import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:hotswing/src/screens/players/widgets/provider/players_view_model.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/common/forms/advanced_settings_section.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_group_field.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_edit_description_field.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_edit_footer.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_edit_header.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_gender_segment.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_rate_stepper.dart';
import 'package:hotswing/src/screens/players/widgets/player_edit/player_skill_chip_list.dart';

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
  late String _currentDescription;
  late int _currentRate;
  late String _currentSkillLevel;
  late String _currentGender;
  late bool _isManager;
  List<ObjectId> _groups = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _currentDescription = widget.player.description;
    _currentRate = widget.player.rate;
    _currentSkillLevel = widget.player.grade;
    _currentGender = widget.player.gender;
    _isManager = widget.player.role == "manager";
    _groups = List<ObjectId>.from(widget.player.groups);
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
            PlayerEditHeader(
              controller: _nameController,
              isManager: _isManager,
              isGuest: widget.player.role == 'guest',
              onToggleManager: () => setState(() => _isManager = !_isManager),
            ),
            Divider(
              height: 18,
              thickness: 0.6,
              color: formColors.filterDivider,
            ),
            PlayerGenderSegment(
              currentGender: _currentGender,
              onSelected: (label) => setState(() => _currentGender = label),
            ),
            Divider(
              height: 18,
              thickness: 0.6,
              color: formColors.filterDivider,
            ),
            PlayerSkillChipList(
              currentSkillLevel: _currentSkillLevel,
              onSelected: _selectSkill,
            ),
            Divider(
              height: 18,
              thickness: 0.6,
              color: formColors.filterDivider,
            ),
            PlayerRateStepper(
              currentRate: _currentRate,
              onDecrease: () => _updateRate(_currentRate - 50),
              onIncrease: () => _updateRate(_currentRate + 50),
            ),
            Divider(
              height: 18,
              thickness: 0.6,
              color: formColors.filterDivider,
            ),
            AdvancedSettingsSection(
              children: [
                PlayerGroupField(
                  players: context
                      .watch<PlayersProvider>()
                      .players
                      .values
                      .toList(),
                  currentGroups: widget.player.groups,
                  groups: _groups,
                  currentId: widget.player.id,
                  onSelectionChanged: (selectedOptions) {
                    setState(() {
                      _groups = selectedOptions;
                    });
                  },
                ),
                Divider(
                  height: 18,
                  thickness: 0.6,
                  color: formColors.filterDivider,
                ),
                PlayerEditDescriptionField(
                  initialValue: _currentDescription,
                  onChanged: (value) => _currentDescription = value,
                ),
              ],
            ),
            const SizedBox(height: 24),
            PlayerEditFooter(onCancel: widget.onCancel, onSubmit: _submit),
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
        groups: _groups,
        description: _currentDescription.trim(),
      );

      viewModel.toggleEditMode(null);
    }
  }
}
