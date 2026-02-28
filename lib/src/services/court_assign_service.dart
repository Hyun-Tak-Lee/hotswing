import 'dart:math';

import 'package:hotswing/src/models/players/player.dart';
import 'package:hotswing/src/models/options/option.dart';

class CourtAssignService {
  final Random _random = Random();
  final Options _options;

  CourtAssignService(this._options);

  List<Player> getRecommendedPlayersForCourt({
    required List<Player> unassignedPlayers,
    required List<Player> currentPlayersOnCourt,
  }) {
    // 비활성화 유저 및 매니저 필터링
    List<Player> availablePlayers = _filterUnnecessaryPlayers(
      unassignedPlayers,
    );

    // 인원이 적을 경우 즉시 배치
    if (availablePlayers.length + currentPlayersOnCourt.length <= 4) {
      return availablePlayers;
    }

    List<Player> results;

    switch (currentPlayersOnCourt.length) {
      case 1:
        results = _assignForOnePlayerOnCourt(
          unassignedPlayers: availablePlayers,
          currentPlayersOnCourt: currentPlayersOnCourt,
        );
        break;
      case 2:
        results = _getBestMatchSecondPair(
          unassignedPlayers: availablePlayers,
          firstTeamPlayers: currentPlayersOnCourt,
        );
        break;
      case 3:
        final fourthPlayer = _getBestMatchForThreePlayers(
          existingPlayers: currentPlayersOnCourt,
          unassignedPlayers: availablePlayers,
        );
        results = fourthPlayer != null ? [fourthPlayer] : [];
        break;
      default:
        // 코트가 비어 있는 경우
        results = _assignForEmptyCourt(unassignedPlayers: availablePlayers);
        break;
    }

    return results;
  }

  /// 1명이 이미 코트에 있을 때 추가 매칭을 수행하는 헬퍼 메서드
  List<Player> _assignForOnePlayerOnCourt({
    required List<Player> unassignedPlayers,
    required List<Player> currentPlayersOnCourt,
  }) {
    final secondPlayer = _getBestMatchForPlayer(
      targetPlayer: currentPlayersOnCourt.first,
      unassignedPlayers: unassignedPlayers,
    );
    if (secondPlayer == null) return [];

    final firstTeam = [currentPlayersOnCourt.first, secondPlayer];
    final remainingPlayers = unassignedPlayers
        .where((p) => p.id.hexString != secondPlayer.id.hexString)
        .toList();

    final secondTeam = _getBestMatchSecondPair(
      unassignedPlayers: remainingPlayers,
      firstTeamPlayers: firstTeam,
    );

    return [secondPlayer, ...secondTeam];
  }

  /// 첫 번째 팀과의 중복 플레이 횟수에 따라 패널티를 부여하여 두 번째 팀(페어) 선정
  List<Player> _getBestMatchSecondPair({
    required List<Player> unassignedPlayers,
    required List<Player> firstTeamPlayers,
  }) {
    if (unassignedPlayers.length < 2) return unassignedPlayers;

    final pairsWithScore = _generateScoredPairs(unassignedPlayers);

    // 상대 팀(첫 번째 팀)과의 매칭 페널티 및 성별 보너스 적용
    for (var entry in pairsWithScore) {
      final playerA = (entry['pair'] as List<Player>)[0];
      final playerB = (entry['pair'] as List<Player>)[1];

      double teamModifier = 0.0;
      // 1. 중복 플레이 기반 페널티
      teamModifier += _calculatePlayedWithPenalty(playerA, firstTeamPlayers);
      teamModifier += _calculatePlayedWithPenalty(playerB, firstTeamPlayers);

      // 2. 팀 대 팀 성별 구성 비교 보너스 (앞 팀 구성과 뒷 팀 구성이 일치할수록 가중)
      teamModifier += _calculateTeamGenderBonus(firstTeamPlayers, [
        playerA,
        playerB,
      ]);

      // 3. 팀 간 실력(Rate) 차이에 따른 미세 조정 (평균 레이팅이 비슷할수록 소폭 가산점 부여)
      teamModifier += _calculateTeamRateBonus(firstTeamPlayers, [
        playerA,
        playerB,
      ]);

      entry['score'] = (entry['score'] as double) + teamModifier;
    }

    // 패널티 적용 후 재정렬
    pairsWithScore.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    if (pairsWithScore.isEmpty) return [];
    return pairsWithScore.first['pair'] as List<Player>;
  }

  /// 3명의 플레이어가 있을 때 3명 중 매칭 점수가 가장 높은 2명을 한 팀으로 가정한 뒤,
  /// 남은 1명의 파트너로 가장 적합한 1명을 반환 (상대팀 2명과의 중복 플레이 패널티 적용)
  Player? _getBestMatchForThreePlayers({
    required List<Player> existingPlayers,
    required List<Player> unassignedPlayers,
  }) {
    if (unassignedPlayers.isEmpty) return null;
    if (existingPlayers.length < 3) return null; // 방어 로직

    // 기존 플레이어 중 최적의 페어 탐색
    Player? bestOpponent1;
    Player? bestOpponent2;
    double bestExistingPairScore = -double.infinity;

    for (int i = 0; i < existingPlayers.length; i++) {
      for (int j = i + 1; j < existingPlayers.length; j++) {
        double score = calculatePairScore(
          existingPlayers[i],
          existingPlayers[j],
        );
        if (score > bestExistingPairScore) {
          bestExistingPairScore = score;
          bestOpponent1 = existingPlayers[i];
          bestOpponent2 = existingPlayers[j];
        }
      }
    }

    // 나머지 1명을 파트너로 설정
    final partner = existingPlayers.firstWhere(
      (p) =>
          p.id.hexString != bestOpponent1!.id.hexString &&
          p.id.hexString != bestOpponent2!.id.hexString,
    );

    Player? bestMatch;
    double highestScore = -double.infinity;

    for (var candidate in unassignedPlayers) {
      // 그룹 매칭 유효성 검사
      if (!_isValidGroupCandidate(partner, candidate)) continue;

      double score = calculatePairScore(partner, candidate);

      // 그룹 멤버로 일치하는 경우 즉시 반환
      if (_isExactGroupMatch(partner, candidate)) {
        return candidate;
      }

      // 상대 팀 2명에 대한 매칭 페널티 및 성별 조합 보너스 합산 적용
      final opponents = [bestOpponent1!, bestOpponent2!];
      score += _calculatePlayedWithPenalty(candidate, opponents);
      score += _calculateTeamGenderBonus(opponents, [partner, candidate]);
      score += _calculateTeamRateBonus(opponents, [partner, candidate]);

      if (score > highestScore) {
        highestScore = score;
        bestMatch = candidate;
      }
    }

    return bestMatch;
  }

  /// 코트가 비어있을 때 4명을 완전히 새로 매칭하는 헬퍼 메서드
  List<Player> _assignForEmptyCourt({required List<Player> unassignedPlayers}) {
    // 최적의 첫 번째 팀 선정
    final firstTeam = getBestMatchPair(
      unassignedPlayers: unassignedPlayers,
      currentPlayersOnCourt: const [], // 빈 리스트
    );

    if (firstTeam.isEmpty) return [];

    // 나머지 인원에서 두 번째 팀 선정
    final firstTeamIds = firstTeam.map((p) => p.id.hexString).toSet();
    final remainingPlayers = unassignedPlayers
        .where((p) => !firstTeamIds.contains(p.id.hexString))
        .toList();

    final secondTeam = _getBestMatchSecondPair(
      unassignedPlayers: remainingPlayers,
      firstTeamPlayers: firstTeam,
    );

    return [...firstTeam, ...secondTeam];
  }

  /// 점수가 가장 높은 최적의 팀(페어) 하나를 반환
  List<Player> getBestMatchPair({
    required List<Player> unassignedPlayers,
    required List<Player> currentPlayersOnCourt,
  }) {
    final pairs = _generateScoredPairs(unassignedPlayers);
    if (pairs.isEmpty) return [];
    return pairs.first['pair'] as List<Player>;
  }

  /// 특정 플레이어와 가장 매칭 점수가 높은 1명을 반환
  Player? _getBestMatchForPlayer({
    required Player targetPlayer,
    required List<Player> unassignedPlayers,
  }) {
    if (unassignedPlayers.isEmpty) return null;

    Player? bestMatch;
    // 초기값 설정
    double highestScore = -double.infinity;

    for (var player in unassignedPlayers) {
      // 그룹 매칭 유효성 검사
      if (!_isValidGroupCandidate(targetPlayer, player)) continue;

      double score = calculatePairScore(targetPlayer, player);

      // 그룹 멤버로 일치하는 경우 즉시 반환
      if (_isExactGroupMatch(targetPlayer, player)) {
        return player;
      }

      if (score > highestScore) {
        highestScore = score;
        bestMatch = player;
      }
    }

    return bestMatch;
  }

  // --- 매칭 헬퍼 메서드 추가 ---

  /// 대상 플레이어(target)와 후보 플레이어(candidate)가 유효한 매칭 후보인지 확인
  bool _isValidGroupCandidate(Player target, Player candidate) {
    if (target.groups.isNotEmpty) {
      return target.groups.contains(candidate.id);
    }
    return candidate.groups.isEmpty;
  }

  /// 대상 플레이어와 후보 플레이어가 일치하는 그룹 멤버인지 확인
  bool _isExactGroupMatch(Player target, Player candidate) {
    return target.groups.isNotEmpty && target.groups.contains(candidate.id);
  }

  /// 상대팀(opponents)과의 중복 플레이 경험에 따른 페널티 계산
  double _calculatePlayedWithPenalty(Player candidate, List<Player> opponents) {
    double penalty = 0.0;

    for (var opponent in opponents) {
      final gamesPlayed = candidate.gamesPlayedWith[opponent.id.hexString] ?? 0;
      penalty -= gamesPlayed * 0.25 * _options.playedWithWeight;
    }

    return penalty;
  }

  /// 코트 전체의 성별 구성에 따른 매칭 점수 보너스
  ///
  /// 1. 1팀(앞 팀)이 혼복인 경우:
  ///    - 2팀도 혼복일 때 최고 보너스(16.0)를 부여해 2:2 혼복 코트를 우선 구성
  ///    - 혼복 vs 동성의 불균형 매칭에는 보너스 없음
  ///
  /// 2. 1팀이 동성(남남/여여)인 경우:
  ///    - 2팀 구성 시 'genderWeight' 값에 따라 선호하는 코트 양상을 반영:
  ///      * 가중치 2.0(단식 코트 선호): 1팀과 똑같은 동성을 2팀으로 선호 (남남 vs 남남)
  ///      * 가중치 0.0(혼성 코트 선호): 1팀과 반대되는 동성을 2팀으로 선호 (남남 vs 여여)
  double _calculateTeamGenderBonus(List<Player> teamA, List<Player> teamB) {
    if (teamA.length < 2 || teamB.length < 2) return 0.0;

    bool isTeamAMixed = teamA[0].gender != teamA[1].gender;
    bool isTeamBMixed = teamB[0].gender != teamB[1].gender;

    // 1. 1팀이 혼복인 경우
    if (isTeamAMixed) {
      // 2팀 또한 혼복일 시 고정 만점을 부여하여 최우선 매칭 (기본 성별 점수 5점 차 극복)
      // 동성일 경우 밸런스 붕괴를 막기 위해 아주 큰 패널티 부여
      return isTeamBMixed ? 16.0 : -16.0;
    }

    // 2. 1팀이 동성인 경우
    // 2-1. 동성 vs 혼복 구도는 피함 (밸런스 붕괴 패널티 부여)
    if (isTeamBMixed) return -16.0;

    // 2-2. 1팀과 2팀이 같은 동성인지 확인 (예: 남남 vs 남남)
    bool isSameGenderAcrossTeams = teamA[0].gender == teamB[0].gender;

    // genderWeight (0.0 ~ 2.0) -> (-1.0 ~ 1.0 비율)
    double weightRatio = _options.genderWeight - 1.0;

    // 동성 매칭 간의 보너스 계수
    // (이 값이 작을수록 코트 성비 점수가 대기 시간 1~2턴 차이 등과 유연하게 경합함)
    double sameGenderMaxBonus = 4.0;

    // 양 팀의 구성(남남/여여)이 일치할 시엔 그대로 배율 적용, 반대 구성이면 음수로 반전
    return (isSameGenderAcrossTeams ? weightRatio : -weightRatio) *
        sameGenderMaxBonus;
  }

  /// 팀 간 평균 레이팅의 차이가 적을수록 보너스를 주며, 차이가 클수록 기하급수적으로 큰 감점(패널티)을 부여
  double _calculateTeamRateBonus(List<Player> teamA, List<Player> teamB) {
    if (teamA.isEmpty || teamB.isEmpty) return 0.0;

    final teamARateAvg =
        teamA.fold(0.0, (sum, p) => sum + p.rate) / teamA.length;
    final teamBRateAvg =
        teamB.fold(0.0, (sum, p) => sum + p.rate) / teamB.length;
    final teamRateDiff = (teamARateAvg - teamBRateAvg).abs();

    // 차이가 0일 때 최고점(0.25 * skillWeight)을 부여합니다.
    // 차이가 커질수록 제곱(square)에 비례하여 마이너스(감점)가 가파르게 커집니다.
    // 1000.0은 감쇄 기준점입니다. 이 수치가 작을수록 더 빨리 감점됩니다.
    return pow(teamRateDiff / 1000.0, 2) * -1 * _options.skillWeight;
  }

  /// 두 플레이어 간의 매칭 점수를 계산 (높을수록 좋음)
  double calculatePairScore(Player player1, Player player2) {
    // 두 사람이 같은 그룹인지 확인
    final bool isGroupMember = player1.groups.contains(player2.id);

    // 실력 점수: 레이팅 차이가 적을수록 높은 점수 부여
    final double rateDiff = isGroupMember
        ? 0.0
        : (player1.rate - player2.rate).abs().toDouble();
    final skillScore = 1.0 - (rateDiff / 1000.0);

    // 성별 점수: 같은 성별일 경우 가산점 5.0을 부여하여 동성 페어 우선 결성 추구
    final genderScore = (isGroupMember || player1.gender == player2.gender)
        ? 5.0
        : 0.0;

    // 대기 점수: 대기 시간이 길수록 높은 점수 부여
    final totalWaited = player1.waited + player2.waited;
    final waitedScore = totalWaited * 0.2;

    // 플레이 점수: 경기 횟수가 많을수록 감점 처리
    final totalPlayed =
        player1.played + player1.lated + player2.played + player2.lated;
    final playedScore = totalPlayed * -0.25; // 음수화하여 감점 처리

    // 중복 플레이 점수: 이미 매칭되었던 페어일 경우 감점 처리
    final gamesPlayedTogether =
        player1.gamesPlayedWith[player2.id.hexString] ?? 0;
    final playedWithScore = 1.0 - (gamesPlayedTogether * 0.15);

    // 각 항목에 설정된 가중치를 곱하여 최종 점수 산출
    return skillScore +
        genderScore +
        (waitedScore * _options.waitedWeight) +
        (playedScore * _options.playedWeight) +
        playedWithScore;
  }

  /// 플레이어 리스트에서 가능한 모든 인접 조합을 생성하고 기본 점수를 매겨 정렬함
  List<Map<String, dynamic>> _generateScoredPairs(List<Player> players) {
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) {
        int rateComparison = a.rate.compareTo(b.rate);
        if (rateComparison != 0) return rateComparison;
        return _random.nextInt(3) - 1;
      });

    const int searchRange = 16;
    final List<Map<String, dynamic>> pairsWithScore = [];

    for (int i = 0; i < sortedPlayers.length; i++) {
      final playerA = sortedPlayers[i];

      // 플레이어가 그룹에 속해있는 경우 상대 그룹 멤버와만 짝을 지음
      if (playerA.groups.isNotEmpty) {
        for (int j = i + 1; j < sortedPlayers.length; j++) {
          final playerB = sortedPlayers[j];
          if (playerA.groups.contains(playerB.id)) {
            pairsWithScore.add({
              'pair': [playerA, playerB],
              'score': calculatePairScore(playerA, playerB),
            });
            break; // 상대방을 찾으면 더 이상 순회하지 않음
          }
        }
        continue; // 그룹이 있는 플레이어는 아래의 일반 매칭 탐색을 건너뜀
      }

      for (
        int j = i + 1;
        j < min(i + 1 + searchRange, sortedPlayers.length);
        j++
      ) {
        final playerB = sortedPlayers[j];
        if (playerB.groups.isNotEmpty) continue; // B가 그룹이 있다면 일반 매칭 대상에서 제외

        pairsWithScore.add({
          'pair': [playerA, playerB],
          'score': calculatePairScore(playerA, playerB),
        });
      }
    }

    pairsWithScore.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    return pairsWithScore;
  }

  /// 매칭에서 제외할 불필요한 유저(비활성화 유저, 매니저 등)를 걸러낸 후의 목록을 반환
  List<Player> _filterUnnecessaryPlayers(List<Player> unassignedPlayers) {
    // 비활성화 유저 제외
    List<Player> filteredPlayers = unassignedPlayers
        .where((p) => p.activate)
        .toList();

    // 매니저 예약 설정 시 매니저 1명 제외
    if (_options.reserveManager) {
      final bestManagerCandidate = _selectBestManagerCandidate(filteredPlayers);
      if (bestManagerCandidate != null) {
        filteredPlayers.removeWhere(
          (p) => p.id.hexString == bestManagerCandidate.id.hexString,
        );
      }
    }

    return filteredPlayers;
  }

  /// 매니저(대기자)로서 가장 적합한 플레이어 하나를 선정
  /// 플레이 횟수 및 대기 횟수 기준 적합자 선정
  Player? _selectBestManagerCandidate(List<Player> players) {
    if (players.isEmpty) return null;

    final managers = players.where((p) => p.role == 'manager').toList();
    if (managers.isEmpty) return null;

    return managers.reduce((a, b) {
      final scoreA = (a.played + a.lated) * 1.0 - (a.waited * 0.15);
      final scoreB = (b.played + b.lated) * 1.0 - (b.waited * 0.15);
      return scoreA > scoreB ? a : b;
    });
  }
}
