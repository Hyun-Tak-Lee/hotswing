import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_gender_field.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_group_field.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_name_field.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_skill_level_field.dart';
import 'package:hotswing/src/common/widgets/dialogs/add_player/player_stats_row.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:realm/realm.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';

/// 새로운 플레이어를 추가하거나 기존 플레이어의 정보를 수정할 때 사용하는 다이얼로그 위젯입니다.
///
/// 게스트 모드([isGuest]) 여부와 기존 플레이어 정보([player])를 받아
/// 그에 맞는 UI와 로직을 제공합니다.
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
  static const int _maxRate = 7500;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _rateController;

  bool _isLoaded = false;
  bool _isManager = false;

  Player? _player;
  ObjectId? _id;
  String? _name;
  int? _rate;
  PlayerGender? _selectedGender;
  String? _selectedSkillLevel;
  int? _playCount;
  int? _waitCount;
  int? _lateCount;
  List<ObjectId> _groups = [];

  final List<PlayerGender> _genders = PlayerGender.values;

  @override
  void initState() {
    super.initState();
    if (widget.player != null) {
      _id = widget.player!.id;
      _name = widget.player!.name;
      _rate = widget.player!.rate;
      _selectedSkillLevel = widget.player!.grade;
      _selectedGender = PlayerGender.values.cast<PlayerGender?>().firstWhere(
        (element) => element?.value == widget.player!.gender,
        orElse: () => null,
      );
      _isManager = widget.player!.role == "manager";
      _playCount = widget.player!.played;
      _waitCount = widget.player!.waited;
      _lateCount = widget.player!.lated;
      _groups = List<ObjectId>.from(widget.player!.groups);
    }
    _rateController = TextEditingController(text: _rate?.toString() ?? '');
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final formColors = context.formColors;
    final dialogColors = context.dialogColors;

    final bool isEditMode = widget.player != null;
    final bool isGuestMode = widget.isGuest || (widget.player?.role == 'guest');

    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaWidth = MediaQuery.of(context).size.width;
        final bool isTablet = ResponsiveUtils.isTablet(context);

        final textTheme = Theme.of(context).textTheme;
        final double dialogWidth = isTablet ? 500.0 : mediaWidth * 0.9;

        // 반응형 스타일 정의
        final titleStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          textTheme.headlineSmall,
        )?.copyWith(fontWeight: FontWeight.bold);
        final buttonStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          textTheme.titleMedium,
        );

        final labelStyle = ResponsiveUtils.getResponsiveStyle(
          context,
          Theme.of(context).textTheme.bodyLarge,
        )?.copyWith(color: baseColors.textPrimary, fontWeight: FontWeight.w500);

        return AlertDialog(
          backgroundColor: baseColors.cardBg,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isManager
                    ? [
                        dialogColors.dialogTitleManagerBgStart,
                        dialogColors.dialogTitleManagerBgEnd,
                      ]
                    : [
                        dialogColors.dialogTitleBgStart,
                        dialogColors.dialogTitleBgEnd,
                      ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${isGuestMode ? '게스트' : '회원'} ${isEditMode ? '수정' : '추가'}',
                  style: titleStyle,
                ),
                if (!isGuestMode)
                  Opacity(
                    opacity: _isLoaded ? 0.5 : 1.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '운영진',
                          style: ResponsiveUtils.getResponsiveStyle(
                            context,
                            textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: _isManager,
                          activeThumbColor: Theme.of(context).primaryColor,
                          onChanged: _isLoaded
                              ? null
                              : (value) {
                                  setState(() {
                                    _isManager = value;
                                  });
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  _updateRate(
                                    _rate ?? 0,
                                  ); // Re-clamping on role switch
                                },
                        ),
                      ],
                    ),
                  ),
              ],
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
                    PlayerNameField(
                      baseColors: baseColors,
                      playerColors: playerColors,
                      formColors: formColors,
                      labelStyle: labelStyle,
                      isEditMode: isEditMode,
                      isManager: _isManager,
                      name: _name,
                      findPlayersByName: _findPlayersByName,
                      onPlayerSelected: _loadPlayerAllForms,
                      onNameSaved: (value) => _name = value,
                    ),
                    Divider(
                      height: isTablet ? 18 : 14,
                      thickness: 0.6,
                      color: formColors.filterDivider,
                    ),
                    PlayerSkillLevelField(
                      baseColors: baseColors,
                      playerColors: playerColors,
                      formColors: formColors,
                      labelStyle: labelStyle,
                      isLoaded: _isLoaded,
                      isManager: _isManager,
                      selectedSkillLevel: _selectedSkillLevel,
                      rateController: _rateController,
                      rate: _rate,
                      maxRate: _maxRate,
                      onChanged: _onSkillChanged,
                      onRateUpdated: _updateRate,
                      onRateEdited: (parsed) {
                        setState(() {
                          _rate = parsed;
                        });
                      },
                      onRateSaved: (value) => _rate = value,
                    ),
                    Divider(
                      height: isTablet ? 18 : 14,
                      thickness: 0.6,
                      color: formColors.filterDivider,
                    ),
                    PlayerGenderField(
                      baseColors: baseColors,
                      playerColors: playerColors,
                      formColors: formColors,
                      labelStyle: labelStyle,
                      isLoaded: _isLoaded,
                      isManager: _isManager,
                      selectedGender: _selectedGender,
                      genders: _genders,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      onSaved: (value) => _selectedGender = value,
                    ),
                    Divider(
                      height: isTablet ? 18 : 14,
                      thickness: 0.6,
                      color: formColors.filterDivider,
                    ),
                    PlayerGroupField(
                      players: widget.playersProvider.players.values.toList(),
                      currentGroups: widget.player?.groups ?? const [],
                      groups: _groups,
                      currentId: _id,
                      onSelectionChanged: (selectedOptions) {
                        setState(() {
                          _groups = selectedOptions;
                        });
                      },
                    ),
                    if (isEditMode) ...[
                      Divider(
                        height: isTablet ? 18 : 14,
                        thickness: 0.6,
                        color: formColors.filterDivider,
                      ),
                      PlayerStatsRow(
                        baseColors: baseColors,
                        playerColors: playerColors,
                        formColors: formColors,
                        labelStyle: labelStyle,
                        isManager: _isManager,
                        playCount: _playCount,
                        waitCount: _waitCount,
                        lateCount: _lateCount,
                        onPlayCountSaved: (value) => _playCount = value,
                        onWaitCountSaved: (value) => _waitCount = value,
                        onLateCountSaved: (value) => _lateCount = value,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: dialogColors.dialogButtonCancelText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소', style: buttonStyle),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isManager
                    ? dialogColors.dialogTitleManagerBgEnd
                    : dialogColors.dialogButtonConfirmBg,
                foregroundColor: _isManager
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? playerColors.roleManager
                          : Colors.brown[900])
                    : dialogColors.dialogButtonConfirmText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: _submit,
              child: Text(isEditMode ? '수정' : '추가', style: buttonStyle),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // Private Helper Methods
  // ==========================================

  /// 이름 입력 시 자동완성을 위해 플레이어를 검색합니다.
  ///
  /// [textEditingValue]의 텍스트를 접두사로 사용하여 일치하는 플레이어 목록을 반환합니다.
  Iterable<Player> _findPlayersByName(TextEditingValue textEditingValue) {
    if (_isLoaded) {
      setState(() {
        _isLoaded = false;
      });
    }
    if (textEditingValue.text.isEmpty) {
      return const Iterable<Player>.empty();
    }
    return widget.playersProvider.findPlayersByPrefix(
      textEditingValue.text,
      10,
    );
  }

  /// 자동완성에서 선택된 플레이어의 정보를 폼의 각 필드에 로드합니다.
  void _loadPlayerAllForms(Player player) {
    setState(() {
      _isLoaded = true;
      _player = player;
      _name = player.name;
      _rate = player.rate;
      _rateController.text = player.rate.toString();
      _selectedSkillLevel = player.grade;
      _selectedGender = PlayerGender.values.cast<PlayerGender?>().firstWhere(
        (element) => element?.value == player.gender,
        orElse: () => null,
      );
      _isManager = player.role == "manager";
      _groups = List<ObjectId>.from(player.groups);
    });
  }

  /// 입력된 폼 데이터를 검증하고, 유효한 경우 이전 화면으로 데이터를 반환하며 다이얼로그를 닫습니다.
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
        'grade': _selectedSkillLevel,
        'gender': _selectedGender?.value,
        'role': role,
        'played': _playCount ?? 0,
        'waited': _waitCount ?? 0,
        'lated': _lateCount ?? 0,
        'groups': _groups,
        'loaded': _isLoaded,
        'player': _player,
      });
    }
  }

  void _onSkillChanged(String? newValue) {
    setState(() {
      _selectedSkillLevel = newValue;
      if (newValue != null && skillLevelToRate.containsKey(newValue)) {
        _updateRate(skillLevelToRate[newValue]!);
      }
    });
  }

  /// 레이팅을 주어진 [newRate]로 업데이트합니다.
  /// 값은 0에서 [_maxRate] 사이로 제한됩니다.
  void _updateRate(int newRate) {
    final clampedRate = newRate.clamp(0, _maxRate);
    setState(() {
      _rate = clampedRate;
      _rateController.text = clampedRate.toString();
    });
  }
}
