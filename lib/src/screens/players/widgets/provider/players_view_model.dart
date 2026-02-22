import 'package:flutter/foundation.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/players.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/common/utils/game/skill_utils.dart';
import 'package:hotswing/src/common/utils/database/realm_query_builder.dart';
import 'package:realm/realm.dart';

class PlayersViewModel extends ChangeNotifier {
  final PlayerRepository _repository = PlayerRepository.instance;

  // 현재 화면에 표시되는 플레이어 목록
  List<Player> _players = [];
  List<Player> get players => _players;

  // 로딩 상태 (UI 인디케이터 제어용)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 추가 데이터 존재 여부 (무한 스크롤 제어용)
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // 필터 상태 (다중 선택 가능)
  final Set<PlayerRole> _selectedRoles = {};
  Set<PlayerRole> get selectedRoles => _selectedRoles;

  // 성별 필터 (다중 선택 가능)
  final Set<PlayerGender> _selectedGenders = {};
  Set<PlayerGender> get selectedGenders => _selectedGenders;

  // 선택 모드 상태
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  // 선택된 플레이어 ID 집합
  final Set<ObjectId> _selectedPlayerIds = {};
  Set<ObjectId> get selectedPlayerIds => _selectedPlayerIds;

  // 이름 검색어
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // 급수 필터 (다중 선택 가능, skill_utils 기준 키값)
  final Set<String> _selectedSkills = {};
  Set<String> get selectedSkills => _selectedSkills;

  // 한 번에 불러올 데이터 개수
  static const int _pageSize = 30;

  // 필터링 및 정렬된 전체 쿼리 결과 (지연 로딩을 위해 전체 객체를 메모리에 두지 않고 쿼리 결과만 유지)
  late RealmResults<Player> _queryResults;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  PlayersViewModel() {
    _loadInitialData();
  }

  // 초기 데이터 로드 (필터 적용 포함)
  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    final queryBuilder = RealmQueryBuilder()
        .addStartsWithCondition('name', _searchQuery)
        .addInCondition('role', _selectedRoles.map((e) => e.value))
        .addInCondition('gender', _selectedGenders.map((e) => e.value));

    // 선택된 급수를 기반으로 rate 범위 조건 구성
    if (_selectedSkills.isNotEmpty) {
      final entries = skillLevelToRate.entries.toList();
      List<List<num>> rateRanges = [];
      for (var skill in _selectedSkills) {
        int index = entries.indexWhere((e) => e.key == skill);
        if (index != -1) {
          int min = index == 0
              ? 0
              : (entries[index - 1].value + entries[index].value) ~/ 2;
          int max = index == entries.length - 1
              ? 10000
              : (entries[index].value + entries[index + 1].value) ~/ 2;
          rateRanges.add([min, max]);
        }
      }
      queryBuilder.addMultiRangeOrCondition(
        'rate',
        rateRanges,
        includeMax: false,
      );
    }

    // 1. 데이터 조회
    _queryResults = _repository.getPlayers(
      query: queryBuilder.build(),
      args: queryBuilder.args,
      sortField: 'name',
      sortAscending: true,
    );

    // 2. 페이지 데이터 구성
    int initialCount = _queryResults.length < _pageSize
        ? _queryResults.length
        : _pageSize;
    _players = _queryResults.take(initialCount).toList();

    _hasMore = _players.length < _queryResults.length;

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  // 역할 필터 토글 (데이터 로드 지연)
  void toggleRoleFilter(PlayerRole role) {
    if (_selectedRoles.contains(role)) {
      _selectedRoles.remove(role);
    } else {
      _selectedRoles.add(role);
    }
    notifyListeners();
  }

  // 성별 필터 토글 (데이터 로드 지연)
  void toggleGenderFilter(PlayerGender gender) {
    if (_selectedGenders.contains(gender)) {
      _selectedGenders.remove(gender);
    } else {
      _selectedGenders.add(gender);
    }
    notifyListeners();
  }

  // 급수 필터 토글 (데이터 로드 지연)
  void toggleSkillFilter(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
    } else {
      _selectedSkills.add(skill);
    }
    notifyListeners();
  }

  // 필터 일괄 적용 메서드 (바텀 시트 닫힐 때 호출)
  void applyFilters() {
    _loadInitialData();
  }

  // 이름 검색어 설정 (검색은 즉시 적용)
  void setSearchQuery(String query) {
    _searchQuery = query;
    _loadInitialData();
  }

  // 추가 데이터 로드 (무한 스크롤)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    int currentLength = _players.length;
    int nextCount = currentLength + _pageSize;

    if (nextCount > _queryResults.length) {
      nextCount = _queryResults.length;
    }

    // 다음 페이지 범위만큼 가져와서 기존 리스트에 추가
    List<Player> nextBatch = [];
    for (int i = currentLength; i < nextCount; i++) {
      nextBatch.add(_queryResults[i]);
    }

    _players.addAll(nextBatch);

    if (_players.length >= _queryResults.length) {
      _hasMore = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 선택 모드 설정
  void setSelectionMode(bool enabled) {
    _isSelectionMode = enabled;
    if (!enabled) {
      _selectedPlayerIds.clear();
    }
    notifyListeners();
  }

  // 플레이어 선택 토글
  void toggleSelection(ObjectId playerId) {
    if (_selectedPlayerIds.contains(playerId)) {
      _selectedPlayerIds.remove(playerId);
      // 모든 선택이 해제되면 선택 모드 종료 (옵션) - 기획에 따라 다름, 여기서는 유지
    } else {
      _selectedPlayerIds.add(playerId);
    }
    notifyListeners();
  }

  // 전체 선택 (현재 로드된 플레이어 대상)
  void selectAll() {
    if (_selectedPlayerIds.length == _players.length) {
      _selectedPlayerIds.clear();
    } else {
      _selectedPlayerIds.addAll(_players.map((p) => p.id));
    }
    notifyListeners();
  }

  // 단일 플레이어 삭제
  void deletePlayer(Player player) {
    _repository.deletePlayer(player.id);

    // 삭제 후 리스트 갱신 (Realm 객체가 삭제되면무효화되므로 isValid 체크)
    _players.removeWhere((p) => !p.isValid);
    notifyListeners();
  }

  // 다중 플레이어 삭제
  void deleteSelectedPlayers() {
    if (_selectedPlayerIds.isEmpty) return;

    _repository.deletePlayers(_selectedPlayerIds.toList());

    _players.removeWhere((p) => !p.isValid);

    // 선택 모드 종료 및 초기화
    setSelectionMode(false);
  }
}
