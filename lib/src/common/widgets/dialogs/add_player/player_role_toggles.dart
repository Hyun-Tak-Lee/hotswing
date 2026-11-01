import 'package:flutter/material.dart';
import 'package:hotswing/src/common/utils/ui/responsive_utils.dart';

/// 플레이어 추가/수정 다이얼로그 헤더의 역할 토글(게스트 · 운영진) 위젯.
///
/// 게스트와 운영진은 상호 배타적이며, 게스트가 켜지면 운영진 토글은 비활성화됩니다.
class PlayerRoleToggles extends StatelessWidget {
  const PlayerRoleToggles({
    super.key,
    required this.showGuestToggle,
    required this.isGuest,
    required this.isManager,
    required this.enabled,
    required this.onGuestChanged,
    required this.onManagerChanged,
  });

  final bool showGuestToggle;
  final bool isGuest;
  final bool isManager;
  final bool enabled;
  final ValueChanged<bool> onGuestChanged;
  final ValueChanged<bool> onManagerChanged;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGuestToggle) ...[
            _LabeledSwitch(
              label: '게스트',
              value: isGuest,
              onChanged: enabled ? onGuestChanged : null,
            ),
            const SizedBox(width: 8),
          ],
          Opacity(
            opacity: isGuest ? 0.4 : 1.0,
            child: _LabeledSwitch(
              label: '운영진',
              value: isManager,
              onChanged: enabled && !isGuest ? onManagerChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledSwitch extends StatelessWidget {
  const _LabeledSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: ResponsiveUtils.getResponsiveStyle(
            context,
            Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 4),
        Switch(
          value: value,
          activeThumbColor: Theme.of(context).primaryColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
