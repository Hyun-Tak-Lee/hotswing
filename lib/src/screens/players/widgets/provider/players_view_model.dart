import 'package:flutter/foundation.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/repository/realms/players.dart';
import 'package:hotswing/src/enums/player_feature.dart';
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

  final Set<String> _selectedGenders = {};
  Set<String> get selectedGenders => _selectedGenders;

  // 선택 모드 상태
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  // 선택된 플레이어 ID 집합
  final Set<ObjectId> _selectedPlayerIds = {};
  Set<ObjectId> get selectedPlayerIds => _selectedPlayerIds;

  // 한 번에 불러올 데이터 개수
  static const int _pageSize = 30;

  // 필터링 및 정렬된 전체 쿼리 결과 (지연 로딩을 위해 전체 객체를 메모리에 두지 않고 쿼리 결과만 유지)
  late RealmResults<Player> _queryResults;

  PlayersViewModel() {
    _loadInitialData();
  }

  // 초기 데이터 로드 (필터 적용 포함)
  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    // 1. Repository를 통해 데이터 조회
    _queryResults = _repository.getPlayers(
      roleValues: _selectedRoles.map((e) => e.value).toSet(),
      genderValues: _selectedGenders,
      sortField: 'name',
      sortAscending: true,
    );

    // 2. 첫 페이지 데이터 로드
    // 결과 개수가 페이지 사이즈보다 적으면 전체 사용
    int initialCount = _queryResults.length < _pageSize
        ? _queryResults.length
        : _pageSize;
    // RealmResults는 Iterable이므로 toList()로 변환 후 자름
    _players = _queryResults.toList().sublist(0, initialCount);

    _hasMore = _players.length < _queryResults.length;

    // UI 데모를 위한 인위적 지연 (로컬 DB가 너무 빨라서 로딩 표시가 안 보일 수 있음)
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  // 역할 필터 토글
  void toggleRoleFilter(PlayerRole role) {
    if (_selectedRoles.contains(role)) {
      _selectedRoles.remove(role);
    } else {
      _selectedRoles.add(role);
    }
    _loadInitialData(); // 데이터 다시 로드
  }

  // 성별 필터 토글
  void toggleGenderFilter(String gender) {
    if (_selectedGenders.contains(gender)) {
      _selectedGenders.remove(gender);
    } else {
      _selectedGenders.add(gender);
    }
    _loadInitialData(); // 데이터 다시 로드
  }

  // 추가 데이터 로드 (무한 스크롤)
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000)); // UI 데모용 지연

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

    // 메모리 내 리스트에서도 제거 (Realm 객체가 삭제되면 무효화되므로 isValid 체크)
    _players.removeWhere((p) => !p.isValid);

    // 선택 모드 종료 및 초기화
    setSelectionMode(false);
  }
}
