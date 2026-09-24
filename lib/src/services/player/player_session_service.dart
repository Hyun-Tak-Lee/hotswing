import 'dart:convert';

import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:realm/realm.dart';

/// 앱 재시작 시 세션 유지를 위해 경기/대기 상태 데이터를 로컬 스토리지에 저장하고 복원하는 서비스.
class PlayerSessionService {
  final SharedProvider _sharedProvider = SharedProvider();

  // SharedPreferences 저장 키 상수
  static const String _keyAssignedPlayers = 'assignedPlayers';
  static const String _keyStandbyPlayers = 'standbyPlayers';
  static const String _keyUnassignedPlayers = 'unassignedPlayers';
  static const String _keyPlayers = 'players';
  static const String _keyCourtStartTimes = 'courtStartTimes';
  static const String _keyCustomGroupNames = 'customGroupNames';

  // 6개 플레이어 세션 정보 내부 변수 캐시
  List<String>? _cachedAssignedPlayers;
  List<String>? _cachedStandbyPlayers;
  List<String>? _cachedUnassignedPlayers;
  List<String>? _cachedPlayers;
  List<String>? _cachedCourtStartTimes;
  String? _cachedCustomGroupNames;

  // MARK: - Load Methods

  /// 로컬 저장소에서 세션에 등록된 전체 선수 ID 목록을 복원합니다.
  Future<List<ObjectId>> loadPlayerIds() async {
    final ids = await _sharedProvider.getStringList(_keyPlayers);
    _cachedPlayers = List<String>.from(ids);
    return ids.map((id) => ObjectId.fromHexString(id)).toList();
  }

  /// 로컬 저장소에서 미배정(대기열) 선수 ID 목록을 복원합니다.
  Future<List<ObjectId>> loadUnassignedPlayerIds() async {
    final ids = await _sharedProvider.getStringList(_keyUnassignedPlayers);
    _cachedUnassignedPlayers = List<String>.from(ids);
    return ids.map((id) => ObjectId.fromHexString(id)).toList();
  }

  /// 로컬 저장소에서 진행 코트별 선수 ID 2차원 목록을 복원합니다.
  Future<List<List<ObjectId?>>> loadAssignedPlayerIds() async {
    final encodedList = await _sharedProvider.getStringList(_keyAssignedPlayers);
    _cachedAssignedPlayers = List<String>.from(encodedList);
    return _decodeCourts(encodedList);
  }

  /// 로컬 저장소에서 대기 코트별 선수 ID 2차원 목록을 복원합니다.
  Future<List<List<ObjectId?>>> loadStandbyPlayerIds() async {
    final encodedList = await _sharedProvider.getStringList(_keyStandbyPlayers);
    _cachedStandbyPlayers = List<String>.from(encodedList);
    return _decodeCourts(encodedList);
  }

  /// 로컬 저장소에서 코트별 경기 시작 시각 목록을 복원합니다.
  Future<List<DateTime?>> loadCourtStartTimes() async {
    final stringList = await _sharedProvider.getStringList(_keyCourtStartTimes);
    _cachedCourtStartTimes = List<String>.from(stringList);
    return stringList
        .map((str) => str.isEmpty ? null : DateTime.tryParse(str))
        .toList();
  }

  /// 로컬 저장소에서 동반 그룹 사용자 정의 이름 맵을 복원합니다.
  Future<Map<String, String>> loadCustomGroupNames() async {
    final jsonStr = await _sharedProvider.getString(_keyCustomGroupNames);
    _cachedCustomGroupNames = jsonStr ?? '';
    if (jsonStr == null || jsonStr.isEmpty) {
      return {};
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  // MARK: - Save Method

  /// 현재 코트 배정 현황, 대기 선수 및 그룹 설정 등 세션 전체 상태를 로컬 저장소에 저장합니다.
  ///
  /// 캐시와 비교하여 변경된 항목만 선택적으로 비동기 저장합니다.
  Future<void> saveSession({
    required Map<ObjectId, Player> players,
    required List<Player> unassignedPlayers,
    required List<List<Player?>> assignedPlayers,
    required List<List<Player?>> standbyPlayers,
    required List<DateTime?> courtStartTimes,
    required Map<String, String> customGroupNames,
  }) async {
    final List<Future<void>> saveTasks = [];

    // 1. 배정 코트 선수
    final assignedEncoded = _encodeCourts(assignedPlayers);
    if (!_isListEqual(_cachedAssignedPlayers, assignedEncoded)) {
      _cachedAssignedPlayers = assignedEncoded;
      saveTasks.add(
        _sharedProvider.saveStringList(_keyAssignedPlayers, assignedEncoded),
      );
    }

    // 2. 대기 코트 선수
    final standbyEncoded = _encodeCourts(standbyPlayers);
    if (!_isListEqual(_cachedStandbyPlayers, standbyEncoded)) {
      _cachedStandbyPlayers = standbyEncoded;
      saveTasks.add(
        _sharedProvider.saveStringList(_keyStandbyPlayers, standbyEncoded),
      );
    }

    // 3. 미배정 선수
    final unassignedIds =
        unassignedPlayers.map((player) => player.id.toString()).toList();
    if (!_isListEqual(_cachedUnassignedPlayers, unassignedIds)) {
      _cachedUnassignedPlayers = unassignedIds;
      saveTasks.add(
        _sharedProvider.saveStringList(_keyUnassignedPlayers, unassignedIds),
      );
    }

    // 4. 전체 선수 키
    final playerIds = players.keys.map((key) => key.toString()).toList();
    if (!_isListEqual(_cachedPlayers, playerIds)) {
      _cachedPlayers = playerIds;
      saveTasks.add(_sharedProvider.saveStringList(_keyPlayers, playerIds));
    }

    // 5. 코트 경기 시작 시간
    final startTimeStrings =
        courtStartTimes.map((dt) => dt?.toIso8601String() ?? '').toList();
    if (!_isListEqual(_cachedCourtStartTimes, startTimeStrings)) {
      _cachedCourtStartTimes = startTimeStrings;
      saveTasks.add(
        _sharedProvider.saveStringList(_keyCourtStartTimes, startTimeStrings),
      );
    }

    // 6. 커스텀 그룹 이름
    final groupNamesJson = jsonEncode(customGroupNames);
    if (_cachedCustomGroupNames != groupNamesJson) {
      _cachedCustomGroupNames = groupNamesJson;
      saveTasks.add(
        _sharedProvider.saveString(_keyCustomGroupNames, groupNamesJson),
      );
    }

    if (saveTasks.isNotEmpty) {
      await Future.wait(saveTasks);
    }
  }

  // MARK: - Helpers

  List<String> _encodeCourts(List<List<Player?>> courts) {
    return courts
        .map(
          (innerList) =>
              innerList.map((player) => player?.id.toString() ?? '').toList(),
        )
        .map((idList) => jsonEncode(idList))
        .toList();
  }

  List<List<ObjectId?>> _decodeCourts(List<String> encodedList) {
    return encodedList.map((encoded) {
      final List<dynamic> decoded = jsonDecode(encoded);
      return decoded
          .map((id) => (id == '') ? null : ObjectId.fromHexString(id as String))
          .toList();
    }).toList();
  }

  bool _isListEqual(List<String>? a, List<String> b) {
    if (a == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
