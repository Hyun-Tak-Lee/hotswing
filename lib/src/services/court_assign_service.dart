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
    // 코트에 채울 수 있는 인원이 4명 이하인 경우 모든 인원을 바로 배치 (연산 최적화)
    if (unassignedPlayers.length + currentPlayersOnCourt.length <= 4) {
      return unassignedPlayers.toList();
    }

    // 매칭 후보를 복사하여 사용
    List<Player> availablePlayers = List.from(unassignedPlayers);

    // reserveManager 가 true 일 경우,
    // 매칭을 돌리기 전에 가장 매니저로서 적합한 1명(플레이 수가 많고, 대기 수가 적은 사람)을 미리 후보군에서 제외합니다.
    if (_options.reserveManager) {
      final bestManagerCandidate = _selectBestManagerCandidate(
        availablePlayers,
      );
      if (bestManagerCandidate != null) {
        availablePlayers.removeWhere(
          (p) => p.id.hexString == bestManagerCandidate.id.hexString,
        );
      }
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
        // 0명인 경우 기본 로직
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

    // 첫 번째 팀 멤버와의 중복 플레이 횟수 당 패널티 적용 (0.25 유지)
    for (var entry in pairsWithScore) {
      final playerA = (entry['pair'] as List<Player>)[0];
      final playerB = (entry['pair'] as List<Player>)[1];

      for (var firstTeamPlayer in firstTeamPlayers) {
        final gamesWithA =
            playerA.gamesPlayedWith[firstTeamPlayer.id.hexString] ?? 0;
        final gamesWithB =
            playerB.gamesPlayedWith[firstTeamPlayer.id.hexString] ?? 0;
        entry['score'] =
            (entry['score'] as double) -
            (gamesWithA + gamesWithB) * 0.25 * _options.playedWithWeight;

        if (playerA.gender == firstTeamPlayer.gender) {
          entry['score'] =
              (entry['score'] as double) + 1.0 * (_options.genderWeight - 1.0);
        }
        if (playerB.gender == firstTeamPlayer.gender) {
          entry['score'] =
              (entry['score'] as double) + 1.0 * (_options.genderWeight - 1.0);
        }
      }
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

    // 1. 기존 3명 중 최적의 페어(가장 매칭 점수가 높은 2명)를 찾음
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

    // 2. 나머지 1명을 파트너로 설정
    final partner = existingPlayers.firstWhere(
      (p) =>
          p.id.hexString != bestOpponent1!.id.hexString &&
          p.id.hexString != bestOpponent2!.id.hexString,
    );

    Player? bestMatch;
    double highestScore = -double.infinity;

    for (var candidate in unassignedPlayers) {
      double score = calculatePairScore(partner, candidate);

      final gamesPlayed1 =
          candidate.gamesPlayedWith[bestOpponent1!.id.hexString] ?? 0;
      final gamesPlayed2 =
          candidate.gamesPlayedWith[bestOpponent2!.id.hexString] ?? 0;
      score -= (gamesPlayed1 + gamesPlayed2) * 0.25 * _options.playedWithWeight;

      if (candidate.gender == bestOpponent1.gender) {
        score += 1.0 * (_options.genderWeight - 1.0);
      }
      if (candidate.gender == bestOpponent2.gender) {
        score += 1.0 * (_options.genderWeight - 1.0);
      }

      if (score > highestScore) {
        highestScore = score;
        bestMatch = candidate;
      }
    }

    return bestMatch;
  }

  /// 코트가 비어있을 때 4명을 완전히 새로 매칭하는 헬퍼 메서드
  List<Player> _assignForEmptyCourt({required List<Player> unassignedPlayers}) {
    // 1. 점수 기준 최적의 첫 번째 팀 선정
    final firstTeam = getBestMatchPair(
      unassignedPlayers: unassignedPlayers,
      currentPlayersOnCourt: const [], // 빈 리스트
    );

    if (firstTeam.isEmpty) return [];

    // 2. 첫 번째 팀을 제외한 나머지 풀에서 두 번째 팀 선정
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
    // 초기값을 매우 작은 값으로 설정 (음수가 나올 수 있으므로)
    double highestScore = -double.infinity;

    for (var player in unassignedPlayers) {
      double score = calculatePairScore(targetPlayer, player);
      if (score > highestScore) {
        highestScore = score;
        bestMatch = player;
      }
    }

    return bestMatch;
  }

  /// 두 플레이어 간의 매칭 점수를 계산 (높을수록 좋음)
  double calculatePairScore(Player player1, Player player2) {
    // 1. 실력 점수: 레이팅 차이가 적을수록 높은 점수
    final rateDiff = (player1.rate - player2.rate).abs();
    final skillScore = 1.0 - (rateDiff / 1000.0);

    // 2. 성별 점수: 같은 성별일 경우 가산점 (혼성이 아닌 동성 매치를 우선하는 경우 등)
    final genderScore = (player1.gender == player2.gender) ? 5.0 : 0.0;

    // 3. 대기 점수: 대기 횟수가 많을수록 높은 점수 (가중치 적용 전 기본 스케일링)
    final totalWaited = player1.waited + player2.waited;
    final waitedScore = totalWaited * 0.2;

    // 4. 플레이 점수 (패널티): 이미 많이 플레이했거나 지각한 사람일수록 감점 요소로 작용
    final totalPlayed =
        player1.played + player1.lated + player2.played + player2.lated;
    final playedScore = totalPlayed * -0.25; // 음수화하여 감점 처리

    // 5. 중복 플레이 점수 (패널티): 이전에 이미 같이 친 페어일수록 감점 요소로 작용
    final gamesPlayedTogether =
        player1.gamesPlayedWith[player2.id.hexString] ?? 0;
    final playedWithScore = 1.0 - (gamesPlayedTogether * 0.25);

    // 각 항목에 설정된 가중치를 곱하여 최종 점수 산출
    return (skillScore * _options.skillWeight) +
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
      for (
        int j = i + 1;
        j < min(i + 1 + searchRange, sortedPlayers.length);
        j++
      ) {
        final playerA = sortedPlayers[i];
        final playerB = sortedPlayers[j];
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

  /// 매니저(대기자)로서 가장 적합한 플레이어 하나를 선정
  /// (플레이 횟수가 많고, 대기 횟수가 적은 사람 우선)
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
