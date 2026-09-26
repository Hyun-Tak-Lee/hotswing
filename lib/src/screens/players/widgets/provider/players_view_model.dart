import 'package:flutter/foundation.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/players.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/common/utils/database/realm_query_builder.dart';
import 'package:realm/realm.dart';

/// 선수 관리 화면의 필터링, 검색, 무한 스크롤, 다중 선택 및 편집 상태를 관리하는 뷰모델.
class PlayersViewModel extends ChangeNotifier {
  // 한 번에 불러올 데이터 개수
  static const int _pageSize = 30;

  final PlayerRepository _repository = PlayerRepository.instance;

  // 현재 화면에 표시되는 플레이어 목록
  List<Player> _players = [];

  // 로딩 상태 (UI 인디케이터 제어용)
  bool _isLoading = false;

  // 추가 데이터 존재 여부 (무한 스크롤 제어용)
  bool _hasMore = true;

  // 필터 상태 (다중 선택 가능)
  final Set<PlayerRole> _selectedRoles = {};

  // 성별 필터 (다중 선택 가능)
  final Set<PlayerGender> _selectedGenders = {};

  // 선택 모드 상태
  bool _isSelectionMode = false;

  // 선택된 플레이어 ID 집합
  final Set<ObjectId> _selectedPlayerIds = {};

  // 이름 검색어
  String _searchQuery = '';

  // 급수 필터 (다중 선택 가능, skill_utils 기준 키값)
  final Set<String> _selectedSkills = {};

  // 현재 수정 중인 플레이어 ID
  ObjectId? _editingPlayerId;

  // 필터링 및 정렬된 전체 쿼리 결과 (지연 로딩을 위해 전체 객체를 메모리에 두지 않고 쿼리 결과만 유지)
  late RealmResults<Player> _queryResults;

  bool _isDisposed = false;

  /// [PlayersViewModel] 생성자. 초기 데이터를 조회합니다.
  PlayersViewModel() {
    _loadInitialData();
  }

  /// 현재 화면에 로드되어 표시되는 선수 목록.
  List<Player> get players => _players;

  /// 추가 데이터 로딩 중 여부.
  bool get isLoading => _isLoading;

  /// 다음 페이지 데이터가 존재하는지 여부.
  bool get hasMore => _hasMore;

  /// 선택된 역할 필터 목록.
  Set<PlayerRole> get selectedRoles => _selectedRoles;

  /// 선택된 성별 필터 목록.
  Set<PlayerGender> get selectedGenders => _selectedGenders;

  /// 다중 선택 모드 활성화 여부.
  bool get isSelectionMode => _isSelectionMode;

  /// 선택된 선수들의 식별자 집합.
  Set<ObjectId> get selectedPlayerIds => _selectedPlayerIds;

  /// 현재 입력된 이름 검색어.
  String get searchQuery => _searchQuery;

  /// 선택된 급수 필터 목록.
  Set<String> get selectedSkills => _selectedSkills;

  /// 현재 정보 수정 중인 선수의 식별자.
  ObjectId? get editingPlayerId => _editingPlayerId;

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

  /// 특정 역할 필터([role])의 선택 여부를 토글합니다.
  void toggleRoleFilter(PlayerRole role) {
    if (_selectedRoles.contains(role)) {
      _selectedRoles.remove(role);
    } else {
      _selectedRoles.add(role);
    }
    notifyListeners();
  }

  /// 특정 성별 필터([gender])의 선택 여부를 토글합니다.
  void toggleGenderFilter(PlayerGender gender) {
    if (_selectedGenders.contains(gender)) {
      _selectedGenders.remove(gender);
    } else {
      _selectedGenders.add(gender);
    }
    notifyListeners();
  }

  /// 특정 급수 필터([skill])의 선택 여부를 토글합니다.
  void toggleSkillFilter(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
    } else {
      _selectedSkills.add(skill);
    }
    notifyListeners();
  }

  /// 모든 필터(역할, 성별, 급수)를 일괄 해제합니다.
  void clearAllFilters() {
    _selectedRoles.clear();
    _selectedGenders.clear();
    _selectedSkills.clear();
    notifyListeners();
  }

  /// 설정된 필터를 적용하여 데이터를 다시 로드합니다.
  void applyFilters() {
    _loadInitialData();
  }

  /// 이름 검색어를 변경하고 데이터를 즉시 필터링하여 다시 로드합니다.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _loadInitialData();
  }

  /// 스크롤에 따라 다음 페이지의 선수 데이터를 추가로 불러옵니다.
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

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

  /// [player]의 상세 정보를 수정하고 UI를 갱신합니다.
  void updatePlayer({
    required Player player,
    required String name,
    required String role,
    required int rate,
    required String grade,
    required String gender,
    required int played,
    required int waited,
    required List<ObjectId> groups,
  }) {
    _repository.updatePlayer(
      player: player,
      name: name,
      role: role,
      rate: rate,
      grade: grade,
      gender: gender,
      played: played,
      waited: waited,
      groups: RealmList<ObjectId>(groups),
    );

    // 목록 데이터 갱신
    notifyListeners();
  }

  /// 특정 선수([playerId])의 수정 폼 모드를 토글합니다.
  void toggleEditMode(ObjectId? playerId) {
    if (_editingPlayerId == playerId) {
      _editingPlayerId = null;
    } else {
      _editingPlayerId = playerId;
      // 수정 모드 진입 시 선택 모드는 해제
      if (playerId != null) {
        setSelectionMode(false);
      }
    }
    notifyListeners();
  }

  /// 다중 선택 모드를 설정하거나 해제합니다.
  void setSelectionMode(bool enabled) {
    _isSelectionMode = enabled;
    if (!enabled) {
      _selectedPlayerIds.clear();
    }
    notifyListeners();
  }

  /// 특정 선수([playerId])의 선택 상태를 토글합니다.
  void toggleSelection(ObjectId playerId) {
    if (_selectedPlayerIds.contains(playerId)) {
      _selectedPlayerIds.remove(playerId);
    } else {
      _selectedPlayerIds.add(playerId);
    }
    notifyListeners();
  }

  /// 현재 로드된 전체 선수를 선택하거나 선택 해제합니다.
  void selectAll() {
    if (_selectedPlayerIds.length == _players.length) {
      _selectedPlayerIds.clear();
    } else {
      _selectedPlayerIds.addAll(_players.map((p) => p.id));
    }
    notifyListeners();
  }

  /// 단일 선수([player])를 DB에서 삭제하고 목록에서 제거합니다.
  void deletePlayer(Player player) {
    _repository.deletePlayer(player.id);

    // 삭제 후 리스트 갱신 (Realm 객체가 삭제되면무효화되므로 isValid 체크)
    _players.removeWhere((p) => !p.isValid);
    notifyListeners();
  }

  /// 선택된 다중 선수들을 DB에서 일괄 삭제하고 선택 모드를 종료합니다.
  void deleteSelectedPlayers() {
    if (_selectedPlayerIds.isEmpty) return;

    _repository.deletePlayers(_selectedPlayerIds.toList());

    _players.removeWhere((p) => !p.isValid);

    // 선택 모드 종료 및 초기화
    setSelectionMode(false);
  }

  // ==========================================
  // Private Helper Methods
  // ==========================================

  /// 초기 데이터 로드 (필터 적용 포함)
  void _loadInitialData() {
    final queryBuilder = RealmQueryBuilder()
        .addStartsWithCondition('name', _searchQuery)
        .addInCondition('role', _selectedRoles.map((e) => e.value))
        .addInCondition('gender', _selectedGenders.map((e) => e.value));

    // 선택된 급수를 기반으로 grade 조건 구성
    if (_selectedSkills.isNotEmpty) {
      queryBuilder.addInCondition('grade', _selectedSkills.toList());
    }

    // 데이터 조회
    _queryResults = _repository.getPlayers(
      query: queryBuilder.build(),
      args: queryBuilder.args,
      sortField: 'name',
      sortAscending: true,
    );

    // 페이지 데이터 구성
    int initialCount = _queryResults.length < _pageSize
        ? _queryResults.length
        : _pageSize;
    _players = _queryResults.take(initialCount).toList();

    _hasMore = _players.length < _queryResults.length;

    _isLoading = false;
    notifyListeners();
  }
}
