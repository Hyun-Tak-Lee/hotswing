import 'dart:async';
import 'dart:convert';

import 'package:hotswing/src/common/constants/court_constants.dart';
import 'package:hotswing/src/common/constants/session_constants.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/shared_preferences/shared_preferences.dart';
import 'package:realm/realm.dart';

/// 앱 재시작 시 세션 유지를 위해 경기/대기 상태 데이터를 로컬 스토리지에 저장하고 복원하는 서비스.
class PlayerSessionService {
  final SharedProvider _sharedProvider = SharedProvider();

  // 6개 플레이어 세션 정보 내부 변수 캐시
  List<String>? _cachedAssignedPlayers;
  List<String>? _cachedStandbyPlayers;
  List<String>? _cachedUnassignedPlayers;
  List<String>? _cachedPlayers;
  List<String>? _cachedCourtStartTimes;
  String? _cachedCustomGroupNames;

  Timer? _saveDebounce;
  DateTime? _pendingSince;

  // MARK: - Load Methods

  /// 로컬 저장소에서 세션에 등록된 전체 선수 ID 목록을 복원합니다.
  Future<List<ObjectId>> loadPlayerIds() async {
    final ids = await _sharedProvider.getStringList(
      SessionConstants.playersKey,
    );
    _cachedPlayers = List<String>.from(ids);
    return _parseIds(ids);
  }

  /// 로컬 저장소에서 미배정(대기열) 선수 ID 목록을 복원합니다.
  Future<List<ObjectId>> loadUnassignedPlayerIds() async {
    final ids = await _sharedProvider.getStringList(
      SessionConstants.unassignedPlayersKey,
    );
    _cachedUnassignedPlayers = List<String>.from(ids);
    return _parseIds(ids);
  }

  /// 로컬 저장소에서 진행 코트별 선수 ID 2차원 목록을 복원합니다.
  Future<List<List<ObjectId?>>> loadAssignedPlayerIds() async {
    final encodedList = await _sharedProvider.getStringList(
      SessionConstants.assignedPlayersKey,
    );
    _cachedAssignedPlayers = List<String>.from(encodedList);
    return _decodeCourts(encodedList);
  }

  /// 로컬 저장소에서 대기 코트별 선수 ID 2차원 목록을 복원합니다.
  Future<List<List<ObjectId?>>> loadStandbyPlayerIds() async {
    final encodedList = await _sharedProvider.getStringList(
      SessionConstants.standbyPlayersKey,
    );
    _cachedStandbyPlayers = List<String>.from(encodedList);
    return _decodeCourts(encodedList);
  }

  /// 로컬 저장소에서 코트별 경기 시작 시각 목록을 복원합니다.
  Future<List<DateTime?>> loadCourtStartTimes() async {
    final stringList = await _sharedProvider.getStringList(
      SessionConstants.courtStartTimesKey,
    );
    _cachedCourtStartTimes = List<String>.from(stringList);
    return stringList
        .map((str) => str.isEmpty ? null : DateTime.tryParse(str))
        .toList();
  }

  /// 로컬 저장소에서 동반 그룹 사용자 정의 이름 맵을 복원합니다.
  Future<Map<String, String>> loadCustomGroupNames() async {
    final jsonStr = await _sharedProvider.getString(
      SessionConstants.customGroupNamesKey,
    );
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
        _sharedProvider.saveStringList(
          SessionConstants.assignedPlayersKey,
          assignedEncoded,
        ),
      );
    }

    // 2. 대기 코트 선수
    final standbyEncoded = _encodeCourts(standbyPlayers);
    if (!_isListEqual(_cachedStandbyPlayers, standbyEncoded)) {
      _cachedStandbyPlayers = standbyEncoded;
      saveTasks.add(
        _sharedProvider.saveStringList(
          SessionConstants.standbyPlayersKey,
          standbyEncoded,
        ),
      );
    }

    // 3. 미배정 선수
    final unassignedIds = unassignedPlayers
        .map((player) => player.id.toString())
        .toList();
    if (!_isListEqual(_cachedUnassignedPlayers, unassignedIds)) {
      _cachedUnassignedPlayers = unassignedIds;
      saveTasks.add(
        _sharedProvider.saveStringList(
          SessionConstants.unassignedPlayersKey,
          unassignedIds,
        ),
      );
    }

    // 4. 전체 선수 키
    final playerIds = players.keys.map((key) => key.toString()).toList();
    if (!_isListEqual(_cachedPlayers, playerIds)) {
      _cachedPlayers = playerIds;
      saveTasks.add(
        _sharedProvider.saveStringList(SessionConstants.playersKey, playerIds),
      );
    }

    // 5. 코트 경기 시작 시간
    final startTimeStrings = courtStartTimes
        .map((dt) => dt?.toIso8601String() ?? '')
        .toList();
    if (!_isListEqual(_cachedCourtStartTimes, startTimeStrings)) {
      _cachedCourtStartTimes = startTimeStrings;
      saveTasks.add(
        _sharedProvider.saveStringList(
          SessionConstants.courtStartTimesKey,
          startTimeStrings,
        ),
      );
    }

    // 6. 커스텀 그룹 이름
    final groupNamesJson = jsonEncode(customGroupNames);
    if (_cachedCustomGroupNames != groupNamesJson) {
      _cachedCustomGroupNames = groupNamesJson;
      saveTasks.add(
        _sharedProvider.saveString(
          SessionConstants.customGroupNamesKey,
          groupNamesJson,
        ),
      );
    }

    if (saveTasks.isNotEmpty) {
      await Future.wait(saveTasks);
    }
  }

  /// 변경 사항 저장을 디바운스 및 최대 대기 시간을 고려하여 예약합니다.
  void scheduleSave(Future<void> Function() onSave) {
    _saveDebounce?.cancel();

    final now = DateTime.now();
    _pendingSince ??= now;

    if (now.difference(_pendingSince!) >= SessionConstants.saveMaxWait) {
      _pendingSince = null;
      onSave();
      return;
    }

    _saveDebounce = Timer(SessionConstants.saveDebounceDuration, () {
      _pendingSince = null;
      _saveDebounce = null;
      onSave();
    });
  }

  /// 디바운스 대기 중인 저장이 있으면 즉시 수행합니다.
  ///
  /// 앱이 백그라운드로 전환되거나 종료되기 직전 호출하여 변경 사항 유실을 방지합니다.
  Future<void> flushPendingSave(Future<void> Function() onSave) async {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    if (_pendingSince == null) return;
    _pendingSince = null;
    await onSave();
  }

  /// 보류 중인 저장을 즉시 수행하고 타이머 자원을 해제합니다.
  void dispose({Future<void> Function()? onFlush}) {
    _saveDebounce?.cancel();
    _saveDebounce = null;
    if (_pendingSince != null) {
      _pendingSince = null;
      onFlush?.call();
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

  /// 손상된 코트 데이터는 빈 코트로, 잘못된 ID는 빈 슬롯으로 복원하여 슬롯 위치를 보존합니다.
  List<List<ObjectId?>> _decodeCourts(List<String> encodedList) {
    return encodedList.map((encoded) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is! List) {
          return List<ObjectId?>.filled(CourtConstants.capacity, null);
        }
        return decoded
            .map((id) => id is String ? _tryParseObjectId(id) : null)
            .toList();
      } on FormatException {
        return List<ObjectId?>.filled(CourtConstants.capacity, null);
      }
    }).toList();
  }

  List<ObjectId> _parseIds(List<String> ids) {
    return ids.map(_tryParseObjectId).whereType<ObjectId>().toList();
  }

  ObjectId? _tryParseObjectId(String hex) {
    if (hex.isEmpty) return null;
    try {
      return ObjectId.fromHexString(hex);
    } catch (_) {
      return null;
    }
  }

  bool _isListEqual(List<String>? a, List<String> b) {
    if (a == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
