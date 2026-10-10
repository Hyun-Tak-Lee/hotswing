import 'package:flutter/material.dart';
import 'package:hotswing/src/common/forms/multi_select_form.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:realm/realm.dart';

class PlayerGroupField extends StatelessWidget {
  const PlayerGroupField({
    super.key,
    required this.players,
    required this.currentGroups,
    required this.groups,
    required this.currentId,
    required this.onSelectionChanged,
  });

  final List<Player> players;
  final List<ObjectId> currentGroups;
  final List<ObjectId> groups;
  final ObjectId? currentId;
  final ValueChanged<List<ObjectId>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final List<Player> sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => a.name.compareTo(b.name));

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 46.0),
      child: MultiSelectForm(
        title: '그룹 멤버 선택',
        options: sortedPlayers.map((p) => p.name).toList(),
        optionsId: sortedPlayers.map((p) => p.id).toList(),
        groupsOptionId: sortedPlayers
            .where((p) => p.groups.isNotEmpty && !currentGroups.contains(p.id))
            .map((p) => p.id)
            .toList(),
        initialValue: groups,
        currentId: currentId,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}
