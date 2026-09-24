import 'package:hotswing/src/common/constants/court_constants.dart';
import 'package:hotswing/src/enums/player_feature.dart';
import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/ui/player_drag_data.dart';

/// 코트 슬롯 조작(선수 추가/제거/스왑, 코트 수 변경, 타이머 계산 등)을 전담하는 도메인 서비스.
class CourtSlotService {
  const CourtSlotService();

  /// [courtPlayers]의 인원이 꽉 찼는지([CourtConstants.capacity]명) 확인하여 경기 시작 시간을 계산합니다.
  ///
  /// 인원이 충족되면 기존 [currentStartTime]을 유지하거나 새로 시작된 경우 현재 시각을 반환하며,
  /// 인원이 부족하면 `null`을 반환하여 타이머를 초기화합니다.
  DateTime? calculateCourtStartTime(
    List<Player?> courtPlayers,
    DateTime? currentStartTime,
  ) {
    final activeCount = courtPlayers.where((p) => p != null).length;
    if (activeCount == CourtConstants.capacity) {
      return currentStartTime ?? DateTime.now();
    }
    return null;
  }

  /// [courts] 내에 [courtIndex] 및 [slotIndex]가 유효한 범위에 있는지 검증합니다.
  bool isValidSlot(List<List<Player?>> courts, int courtIndex, int slotIndex) {
    if (courtIndex < 0 || courtIndex >= courts.length) return false;
    if (slotIndex < 0 || slotIndex >= courts[courtIndex].length) return false;
    return true;
  }

  /// [courts]의 [courtIndex]번째 코트의 [slotIndex] 자리에 [player]를 배치합니다.
  ///
  /// [player]가 `null`이거나 인덱스가 유효 범위를 벗어나면 `false`를 반환하고,
  /// 성공적으로 배치되면 `true`를 반환합니다.
  bool setPlayerAt(
    List<List<Player?>> courts,
    int courtIndex,
    int slotIndex,
    Player? player,
  ) {
    if (player == null) return false;
    if (!isValidSlot(courts, courtIndex, slotIndex)) return false;
    courts[courtIndex][slotIndex] = player;
    return true;
  }

  /// [courts]의 [courtIndex]번째 코트의 [slotIndex] 자리에서 선수를 제거하고 반환합니다.
  ///
  /// 인덱스가 유효 범위를 벗어나거나 빈 자리인 경우 `null`을 반환합니다.
  Player? removePlayerAt(
    List<List<Player?>> courts,
    int courtIndex,
    int slotIndex,
  ) {
    if (!isValidSlot(courts, courtIndex, slotIndex)) return null;
    final removed = courts[courtIndex][slotIndex];
    courts[courtIndex][slotIndex] = null;
    return removed;
  }

  /// [court]의 빈 슬롯(`null`)에 [playersToAdd] 목록의 선수들을 순서대로 채워 넣고,
  /// 배치된 선수들을 [unassignedPlayers] 대기열에서 제거합니다.
  ///
  /// 실제로 슬롯에 채워진 선수 수를 반환합니다.
  int fillCourtSlots({
    required List<Player?> court,
    required List<Player> unassignedPlayers,
    required List<Player> playersToAdd,
  }) {
    int addedCount = 0;
    for (int i = 0; i < court.length; i++) {
      if (addedCount >= playersToAdd.length) break;
      if (court[i] == null) {
        final player = playersToAdd[addedCount];
        court[i] = player;
        unassignedPlayers.remove(player);
        addedCount++;
      }
    }
    return addedCount;
  }

  /// [standbyPlayers]의 [standbyIndex]번째 대기 팀(4명 풀팀)을 비어 있는 진행 코트 [assignedPlayers]의 [assignedIndex]로 승격합니다.
  ///
  /// 대상 진행 코트에 이미 선수가 있거나 대기 팀이 4명을 채우지 못한 경우 `false`를 반환합니다.
  bool popStandbyTeam({
    required List<List<Player?>> assignedPlayers,
    required List<List<Player?>> standbyPlayers,
    required int assignedIndex,
    required int standbyIndex,
  }) {
    if (assignedIndex < 0 || assignedIndex >= assignedPlayers.length) {
      return false;
    }
    if (standbyIndex < 0 || standbyIndex >= standbyPlayers.length) return false;

    final targetCourt = assignedPlayers[assignedIndex];
    if (targetCourt.any((player) => player != null)) return false;

    final standbyTeam = standbyPlayers[standbyIndex];
    final bool isFullTeam = standbyTeam.every((player) => player != null);
    if (!isFullTeam) return false;

    assignedPlayers[assignedIndex] = standbyPlayers.removeAt(standbyIndex);
    return true;
  }

  /// [courts] 내의 두 코트([indexA], [indexB])의 위치를 맞교환합니다.
  ///
  /// 어느 한쪽이라도 인덱스 범위를 벗어나면 `false`를 반환합니다.
  bool swapCourts(List<List<Player?>> courts, int indexA, int indexB) {
    if (indexA < 0 || indexA >= courts.length) return false;
    if (indexB < 0 || indexB >= courts.length) return false;

    final temp = courts[indexA];
    courts[indexA] = courts[indexB];
    courts[indexB] = temp;
    return true;
  }

  /// 진행 코트 목록의 크기를 [newCount]로 조정합니다.
  ///
  /// 코트 수가 줄어들 경우 제거되는 코트에 있던 선수들을 [unassignedPlayers] 대기열로 복구하며,
  /// 코트 수에 맞춰 [assignedPlayers]와 [courtStartTimes]의 크기를 동기화합니다.
  void resizeAssignedCourts({
    required List<List<Player?>> assignedPlayers,
    required List<DateTime?> courtStartTimes,
    required List<Player> unassignedPlayers,
    required int newCount,
  }) {
    if (newCount < 0) return;
    final int currentCount = assignedPlayers.length;

    if (newCount < currentCount) {
      for (int i = newCount; i < currentCount; i++) {
        for (final player in assignedPlayers[i].whereType<Player>()) {
          if (!unassignedPlayers.contains(player)) {
            unassignedPlayers.add(player);
          }
        }
      }
      assignedPlayers.removeRange(newCount, currentCount);
      courtStartTimes.removeRange(newCount, currentCount);
    } else if (newCount > currentCount) {
      final addedCount = newCount - currentCount;
      assignedPlayers.addAll(
        List.generate(
          addedCount,
          (_) => List.filled(CourtConstants.capacity, null),
        ),
      );
      courtStartTimes.addAll(List.filled(addedCount, null));
    }
  }

  /// 드래그 앤 드롭 [data]를 바탕으로 소스 위치에서 선수를 추출하여 [targetSectionKind]의 해당 슬롯으로 이동하거나 맞교환(스왑)합니다.
  ///
  /// 선수 이동 및 스왑으로 인해 경기 시작 시간 갱신이 필요한 진행 코트들의 인덱스 집합을 반환합니다.
  Set<int> moveOrSwapPlayer({
    required List<List<Player?>> assignedPlayers,
    required List<List<Player?>> standbyPlayers,
    required List<Player> unassignedPlayers,
    required PlayerDragData data,
    required String targetSectionKind,
    required int targetSectionIndex,
    required int targetSubIndex,
  }) {
    final affectedAssignedCourtIndices = <int>{};

    final String sourceSectionKind = data.sectionKind;
    final int sourceSectionIndex = data.sectionIndex;
    final int sourceSubIndex = data.subIndex;

    // [1] 소스 위치에서 추출
    Player? draggedPlayer;
    if (sourceSectionKind == PlayerSectionKind.unassigned.value) {
      draggedPlayer = data.player;
      unassignedPlayers.remove(draggedPlayer);
    } else if (sourceSectionKind == PlayerSectionKind.assigned.value) {
      draggedPlayer = removePlayerAt(
        assignedPlayers,
        sourceSectionIndex,
        sourceSubIndex,
      );
      affectedAssignedCourtIndices.add(sourceSectionIndex);
    } else if (sourceSectionKind == PlayerSectionKind.standby.value) {
      draggedPlayer = removePlayerAt(
        standbyPlayers,
        sourceSectionIndex,
        sourceSubIndex,
      );
    }

    if (draggedPlayer == null) return affectedAssignedCourtIndices;

    // [2] 타겟이 대기열인 경우 (단순 이동)
    if (targetSectionKind == PlayerSectionKind.unassigned.value ||
        targetSectionKind == PlayerSectionKind.drop.value) {
      if (!unassignedPlayers.contains(draggedPlayer)) {
        unassignedPlayers.add(draggedPlayer);
      }
      return affectedAssignedCourtIndices;
    }

    // [3] 타겟 위치의 기존 선수 추출 및 교체
    Player? existingTargetPlayer;
    if (targetSectionKind == PlayerSectionKind.assigned.value) {
      existingTargetPlayer = removePlayerAt(
        assignedPlayers,
        targetSectionIndex,
        targetSubIndex,
      );
      setPlayerAt(
        assignedPlayers,
        targetSectionIndex,
        targetSubIndex,
        draggedPlayer,
      );
      affectedAssignedCourtIndices.add(targetSectionIndex);
    } else if (targetSectionKind == PlayerSectionKind.standby.value) {
      existingTargetPlayer = removePlayerAt(
        standbyPlayers,
        targetSectionIndex,
        targetSubIndex,
      );
      setPlayerAt(
        standbyPlayers,
        targetSectionIndex,
        targetSubIndex,
        draggedPlayer,
      );
    }

    // [4] 기존 타겟 선수가 있었을 경우, 소스 위치로 복구 (스왑)
    if (existingTargetPlayer != null) {
      if (sourceSectionKind == PlayerSectionKind.unassigned.value) {
        if (!unassignedPlayers.contains(existingTargetPlayer)) {
          unassignedPlayers.add(existingTargetPlayer);
        }
      } else if (sourceSectionKind == PlayerSectionKind.assigned.value) {
        setPlayerAt(
          assignedPlayers,
          sourceSectionIndex,
          sourceSubIndex,
          existingTargetPlayer,
        );
        affectedAssignedCourtIndices.add(sourceSectionIndex);
      } else if (sourceSectionKind == PlayerSectionKind.standby.value) {
        setPlayerAt(
          standbyPlayers,
          sourceSectionIndex,
          sourceSubIndex,
          existingTargetPlayer,
        );
      }
    }

    return affectedAssignedCourtIndices;
  }
}
