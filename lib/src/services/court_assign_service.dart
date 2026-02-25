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
    List<Player> recommendedPlayers = [];
    List<Player> tempUnassignedPlayers = List.from(unassignedPlayers);
    List<Player> tempCurrentCourtPlayers = List.from(currentPlayersOnCourt);

    int neededPlayers = 4 - currentPlayersOnCourt.length;

    return [];
  }

  List<List<Player>> getPlayerTeamForCourt({
    required List<Player> unassignedPlayers,
    required List<Player> currentPlayersOnCourt,
  }) {
    List<List<Player>> allPossiblePairs = [];
    List<Map<String, dynamic>> pairsWithScore = [];

    // 플레이어를 실력(rate) 기준으로 오름차순 정렬하되,
    // 실력이 같은 경우 매번 무작위로 순서가 바뀌도록 정렬 조건을 추가
    List<Player> sortedPlayers = List.from(unassignedPlayers)
      ..sort((a, b) {
        int rateComparison = a.rate.compareTo(b.rate);
        if (rateComparison != 0) {
          return rateComparison;
        }
        return _random.nextInt(3) - 1;
      });

    int searchRange = 16;

    // 1. 인접한 플레이어들과의 조합 생성
    for (int i = 0; i < sortedPlayers.length; i++) {
      for (
        int j = i + 1;
        j < min(i + 1 + searchRange, sortedPlayers.length);
        j++
      ) {
        allPossiblePairs.add([sortedPlayers[i], sortedPlayers[j]]);
      }
    }

    // 2. 필터링된 조합에 대해서만 점수 계산
    for (int i = 0; i < allPossiblePairs.length; i++) {
      Player playerA = allPossiblePairs[i][0];
      Player playerB = allPossiblePairs[i][1];

      double score = calculateScoreBetweenTwoPlayers(playerA, playerB);
      pairsWithScore.add({
        'pair': [playerA, playerB],
        'score': score,
      });
    }

    pairsWithScore.sort(
      (a, b) => (a['score'] as double).compareTo(b['score'] as double),
    );

    return pairsWithScore
        .take(3)
        .map((e) => e['pair'] as List<Player>)
        .toList();
  }

  double calculateScoreBetweenTwoPlayers(Player player1, Player player2) {
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
    double playedScore = totalPlayed * 0.2;

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
}
