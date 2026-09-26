import 'package:flutter/material.dart';
import 'package:hotswing/src/common/theme/app_colors.dart';
import 'package:hotswing/src/providers/players_provider.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

/// 교류전 그룹의 이름을 변경하거나 기본값으로 복원할 수 있는 세련된 모달 다이얼로그.
class EditGroupNameDialog extends StatefulWidget {
  /// 현재 그룹의 표시 라벨 (예: "A", "불꽃").
  final String currentLabel;

  /// 기본 그룹 라벨 (예: "A").
  final String defaultLabel;

  /// 그룹에 속한 멤버 선수들의 ObjectId 목록.
  final List<ObjectId> groupMembers;

  /// 그룹 식별용 테마 색상.
  final Color groupColor;

  /// [EditGroupNameDialog] 생성자.
  const EditGroupNameDialog({
    super.key,
    required this.currentLabel,
    required this.defaultLabel,
    required this.groupMembers,
    required this.groupColor,
  });

  /// 다이얼로그 표시 헬퍼 메서드.
  static Future<void> show({
    required BuildContext context,
    required String currentLabel,
    required String defaultLabel,
    required List<ObjectId> groupMembers,
    required Color groupColor,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditGroupNameDialog(
        currentLabel: currentLabel,
        defaultLabel: defaultLabel,
        groupMembers: groupMembers,
        groupColor: groupColor,
      ),
    );
  }

  @override
  State<EditGroupNameDialog> createState() => _EditGroupNameDialogState();
}

class _EditGroupNameDialogState extends State<EditGroupNameDialog> {
  late final TextEditingController _controller;
  bool _canClear = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentLabel);
    _canClear = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _canClear) {
      setState(() {
        _canClear = hasText;
      });
    }
  }

  void _handleReset() {
    context.read<PlayersProvider>().updateGroupName(widget.groupMembers, '');
    Navigator.of(context).pop();
  }

  void _handleSave() {
    final newName = _controller.text.trim();
    context.read<PlayersProvider>().updateGroupName(
      widget.groupMembers,
      newName,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final baseColors = context.baseColors;
    final playerColors = context.playerColors;
    final isCustomized = widget.currentLabel != widget.defaultLabel;

    return Dialog(
      backgroundColor: baseColors.cardBg,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22.0, 24.0, 22.0, 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. 헤더: 아이콘 + 타이틀 가로 배치
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.groupColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: widget.groupColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '그룹 이름 변경',
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: baseColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 3. 이름 입력 TextField
              TextField(
                controller: _controller,
                autofocus: true,
                maxLength: 6,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: baseColors.textPrimary,
                ),
                decoration: InputDecoration(
                  labelText: '새 그룹 이름',
                  labelStyle: TextStyle(
                    fontSize: 13.0,
                    color: baseColors.textSecondary,
                  ),
                  hintText: '예: 청팀, 불꽃, 1조',
                  hintStyle: TextStyle(
                    fontSize: 13.0,
                    color: baseColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.label_outline_rounded,
                    size: 20,
                    color: widget.groupColor,
                  ),
                  suffixIcon: _canClear
                      ? IconButton(
                          icon: const Icon(Icons.cancel, size: 18),
                          color: baseColors.textSecondary,
                          onPressed: () => _controller.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: playerColors.playerInputFill,
                  counterStyle: TextStyle(
                    fontSize: 11.0,
                    color: baseColors.textSecondary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 12.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: baseColors.textSecondary.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: baseColors.textSecondary.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: widget.groupColor,
                      width: 1.8,
                    ),
                  ),
                ),
                onSubmitted: (_) => _handleSave(),
              ),
              const SizedBox(height: 8),

              // 4. 기본값 복원 액션 (커스텀 이름이 설정되어 있을 때 유용하게 노출)
              if (isCustomized) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _handleReset,
                    icon: Icon(
                      Icons.restart_alt_rounded,
                      size: 15,
                      color: baseColors.textSecondary,
                    ),
                    label: Text(
                      '기본 이름 (${widget.defaultLabel})으로 초기화',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: baseColors.textSecondary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 2.0,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 5. 하단 버튼 (취소 / 저장)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        side: BorderSide(
                          color: baseColors.textSecondary.withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: baseColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _handleSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.groupColor,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
