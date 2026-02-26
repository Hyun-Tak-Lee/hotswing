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
    // 1. 점수 기준 최적의 첫 번째 팀 선정
    final firstTeam = getRecommendedTeamCandidates(
      unassignedPlayers: unassignedPlayers,
      currentPlayersOnCourt: currentPlayersOnCourt,
    );

    if (firstTeam.isEmpty) return [];

    // 2. 첫 번째 팀을 제외한 나머지 풀에서 두 번째 팀 선정
    final firstTeamIds = firstTeam.map((p) => p.id.hexString).toSet();
    final remainingPlayers = unassignedPlayers
        .where((p) => !firstTeamIds.contains(p.id.hexString))
        .toList();

    final secondTeam = _getRecommendedSecondPair(
      unassignedPlayers: remainingPlayers,
      firstTeamPlayers: firstTeam,
    );

    return [...firstTeam, ...secondTeam];
  }

  /// 점수가 가장 높은 최적의 팀(페어) 하나를 반환
  List<Player> getRecommendedTeamCandidates({
    required List<Player> unassignedPlayers,
    required List<Player> currentPlayersOnCourt,
  }) {
    final pairs = _generateScoredPairs(unassignedPlayers);
    if (pairs.isEmpty) return [];
    return pairs.first['pair'] as List<Player>;
  }

  /// 두 플레이어 간의 매칭 점수를 계산 (높을수록 좋음)
  double calculatePairScore(Player player1, Player player2) {
    // 실력 점수 계산
    double rateDiff = (player1.rate - player2.rate).abs().toDouble();
    double skillScore = 1.0 - (rateDiff / 1000.0);

    // 성별 점수 계산
    double genderScore = 1.0;
    if (player1.gender == player2.gender) {
      genderScore = 2.0;
    }

    // 대기 횟수 및 플레이 횟수에 따른 추가 점수 (비율을 낮게 적용)
    double waitedScore = (player1.waited + player2.waited) * 0.2;

    double totalPlayed =
        ((player1.played + player1.lated) + (player2.played + player2.lated))
            .toDouble();
    double playedScore = totalPlayed * 0.25;

    // 함께 플레이한 횟수 점수 계산
    int gamesPlayed = player1.gamesPlayedWith[player2.id.hexString] ?? 0;
    double playedWithFactor = gamesPlayed * 0.5;
    double playedWithScore = 1.0 - playedWithFactor;

    // 최종 점수 반환
    return (skillScore * _options.skillWeight) +
        (genderScore * _options.genderWeight) +
        (waitedScore * _options.waitedWeight) +
        (playedScore * _options.playedWeight) +
        (playedWithScore * _options.playedWithWeight);
  }

  /// 첫 번째 팀과의 중복 플레이 횟수에 따라 패널티를 부여하여 두 번째 팀(페어) 선정
  List<Player> _getRecommendedSecondPair({
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
            (entry['score'] as double) - (gamesWithA + gamesWithB) * 0.25;
      }
    }

    // 패널티 적용 후 재정렬
    pairsWithScore.sort(
      (a, b) => (a['score'] as double).compareTo(b['score'] as double),
    );

    if (pairsWithScore.isEmpty) return [];
    return pairsWithScore.first['pair'] as List<Player>;
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
      (a, b) => (a['score'] as double).compareTo(b['score'] as double),
    );

    return pairsWithScore;
  }
}
