import 'dart:convert';

import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:realm/realm.dart';

class PlayerSessionService {
  final SharedProvider _sharedProvider = SharedProvider();

  Future<List<ObjectId>> loadPlayerIds() async {
    List<String> ids = await _sharedProvider.getStringList("players");
    return ids.map((id) => ObjectId.fromHexString(id)).toList();
  }

  Future<List<ObjectId>> loadUnassignedPlayerIds() async {
    List<String> ids = await _sharedProvider.getStringList("unassignedPlayers");
    return ids.map((id) => ObjectId.fromHexString(id)).toList();
  }

  Future<List<List<ObjectId?>>> loadAssignedPlayerIds() async {
    List<String> encodedList = await _sharedProvider.getStringList(
      "assignedPlayers",
    );
    return encodedList.map((encoded) {
      List<dynamic> decoded = jsonDecode(encoded);
      return decoded
          .map((id) => (id == "") ? null : ObjectId.fromHexString(id as String))
          .toList();
    }).toList();
  }

  Future<List<List<ObjectId?>>> loadStandbyPlayerIds() async {
    List<String> encodedList = await _sharedProvider.getStringList(
      "standbyPlayers",
    );
    return encodedList.map((encoded) {
      List<dynamic> decoded = jsonDecode(encoded);
      return decoded
          .map((id) => (id == "") ? null : ObjectId.fromHexString(id as String))
          .toList();
    }).toList();
  }

  Future<void> saveSession({
    required Map<ObjectId, Player> players,
    required List<Player> unassignedPlayers,
    required List<List<Player?>> assignedPlayers,
    required List<List<Player?>> standbyPlayers,
  }) async {
    final List<String> playerIdLists = players.keys
        .map((key) => key.toString())
        .toList();

    final List<String> assignedPlayersIdListNested = assignedPlayers
        .map(
          (innerList) =>
              innerList.map((player) => player?.id.toString() ?? "").toList(),
        )
        .map((idList) => jsonEncode(idList))
        .toList();

    final List<String> standbyPlayersIdListNested = standbyPlayers
        .map(
          (innerList) =>
              innerList.map((player) => player?.id.toString() ?? "").toList(),
        )
        .map((idList) => jsonEncode(idList))
        .toList();

    final List<String> unassignedPlayersIdList = unassignedPlayers
        .map((player) => player.id.toString())
        .toList();

    await _sharedProvider.saveStringList(
      "assignedPlayers",
      assignedPlayersIdListNested,
    );
    await _sharedProvider.saveStringList(
      "standbyPlayers",
      standbyPlayersIdListNested,
    );
    await _sharedProvider.saveStringList(
      "unassignedPlayers",
      unassignedPlayersIdList,
    );
    await _sharedProvider.saveStringList("players", playerIdLists);
  }
}
