import 'dart:math';

import 'package:hotswing/src/models/players/player.dart';

class CourtAssignService {
  final Random _random = Random();

  Player? findBestPlayerForCourt({
    required List<Player> unassignedPlayers,
    required List<Player> currentPlayersOnCourt,
    required double skillWeight,
    required double genderWeight,
    required double waitedWeight,
    required double playedWeight,
    required double playedWithWeight,
  }) {
    if (unassignedPlayers.isEmpty) return null;

    final int unassignedManagersCount = unassignedPlayers
        .where((p) => p.role == "manager")
        .length;
    final bool isNotLastManager =
        unassignedManagersCount == 1 &&
        unassignedPlayers.any((p) => p.role != "manager");

    if (currentPlayersOnCourt.isEmpty) {
      List<Player> candidatePlayers = unassignedPlayers;
      if (isNotLastManager) {
        final nonManagers = unassignedPlayers
            .where((p) => p.role != "manager")
            .toList();
        if (nonManagers.isNotEmpty) {
          candidatePlayers = nonManagers;
        }
      }
      final sortedCandidates = List.of(candidatePlayers)
        ..sort((a, b) {
          int playedCompare = (a.played + a.lated).compareTo(
            b.played + b.lated,
          );
          if (playedCompare != 0) return playedCompare;
          return b.waited.compareTo(a.waited);
        });

      if (sortedCandidates.isEmpty) return null;

      final topPlayer = sortedCandidates.first;
      final topTierPlayers = sortedCandidates
          .where(
            (p) =>
                (p.played + p.lated) == (topPlayer.played + topPlayer.lated) &&
                p.waited == topPlayer.waited,
          )
          .toList();

      final randomIndex = _random.nextInt(topTierPlayers.length);
      return topTierPlayers[randomIndex];
    }

    final sortedUnassignedPlayers = List.of(unassignedPlayers)
      ..sort((a, b) {
        double scoreA = calculatePlayerScoreForCourt(
          a,
          currentPlayersOnCourt,
          unassignedPlayers: unassignedPlayers,
          skillWeight: skillWeight,
          genderWeight: genderWeight,
          waitedWeight: waitedWeight,
          playedWeight: playedWeight,
          playedWithWeight: playedWithWeight,
        );
        double scoreB = calculatePlayerScoreForCourt(
          b,
          currentPlayersOnCourt,
          unassignedPlayers: unassignedPlayers,
          skillWeight: skillWeight,
          genderWeight: genderWeight,
          waitedWeight: waitedWeight,
          playedWeight: playedWeight,
          playedWithWeight: playedWithWeight,
        );
        return scoreB.compareTo(scoreA);
      });

    if (sortedUnassignedPlayers.isEmpty) return null;
    Player bestPlayer = sortedUnassignedPlayers.first;

    if (isNotLastManager && bestPlayer.role == "manager") {
      Player? bestNonManager = null;
      for (final pInList in sortedUnassignedPlayers) {
        if (pInList.role != "manager") {
          bestNonManager = pInList;
          break;
        }
      }
      if (bestNonManager != null) {
        return bestNonManager;
      }
    }
    return bestPlayer;
  }

  double calculatePlayerScoreForCourt(
    Player player,
    List<Player> currentPlayersOnCourt, {
    required List<Player> unassignedPlayers,
    required double skillWeight,
    required double genderWeight,
    required double waitedWeight,
    required double playedWeight,
    required double playedWithWeight,
  }) {
    // 실력 균등 분배 (2:2) 계산
    double equalScore;

    if (currentPlayersOnCourt.length == 1) {
      equalScore = 1.0;
    } else if (currentPlayersOnCourt.length == 2) {
      Player player1 = currentPlayersOnCourt[0];
      int rateDiff1 = (player.rate - player1.rate).abs();
      Player player2 = currentPlayersOnCourt[1];
      int rateDiff2 = (player.rate - player2.rate).abs();
      equalScore = 2.0 - min(rateDiff1, rateDiff2) / 1000.0;
    } else {
      final double avgRate =
          currentPlayersOnCourt.map((p) => p.rate).reduce((a, b) => a + b) /
          3.0;
      final Player playerWithMaxDiff = currentPlayersOnCourt.reduce((a, b) {
        final diffA = (a.rate - avgRate).abs();
        final diffB = (b.rate - avgRate).abs();
        return diffA > diffB ? a : b;
      });
      final int finalRateDiff = (player.rate - playerWithMaxDiff.rate).abs();
      equalScore = 2.0 - finalRateDiff / 1000.0;
    }

    // 실력 점수 계산
    double avgRateOfCourt = currentPlayersOnCourt.isEmpty
        ? player.rate.toDouble()
        : currentPlayersOnCourt.map((p) => p.rate).reduce((a, b) => a + b) /
              currentPlayersOnCourt.length;
    double rateDiff = (player.rate - avgRateOfCourt).abs();
    double skillScore = 2.0 - rateDiff / 1000.0;

    // 성별 점수 계산
    int menCount = currentPlayersOnCourt.where((p) => p.gender == '남').length;
    int womenCount = currentPlayersOnCourt.where((p) => p.gender == '여').length;

    if (player.gender == "여") {
      womenCount++;
    } else {
      menCount++;
    }
    double mixScore = 0.25;
    double singleGenderScore = 0.25;

    if (menCount == 2 && womenCount == 2) {
      mixScore = 2.0;
    } else if (womenCount == 1 && menCount == 1) {
      mixScore = 1.5;
    } else if ((menCount == 2 && womenCount == 1) ||
        (womenCount == 2 && menCount == 1)) {
      mixScore = 1.5;
    }
    if (menCount == 4 || womenCount == 4) {
      singleGenderScore = 2.0;
    } else if ((womenCount == 0) || (menCount == 0)) {
      singleGenderScore = 1.5;
    }

    double weightForMix = (2.0 - genderWeight);
    double weightForSingle = genderWeight;

    double genderScore =
        (mixScore * weightForMix) + (singleGenderScore * weightForSingle);

    // 순차적으로 배치 했다고 가정 할 때 (대기인원 / 4) 만큼은 반드시 기다려야 하므로 해당 waited 를 1.0 으로 기준
    double waitedScore =
        player.waited.toDouble() /
        (unassignedPlayers.isEmpty ? 1 : unassignedPlayers.length) *
        4;

    // 플레이 횟수 점수 계산
    final double avgPlayed = unassignedPlayers.isEmpty
        ? 0.0
        : unassignedPlayers.map((p) => p.played).reduce((a, b) => a + b) /
              unassignedPlayers.length;
    double playedScore = avgPlayed - (player.played + player.lated);

    // 함께 플레이한 횟수 점수 계산
    double playedWithFactor = 0;
    if (currentPlayersOnCourt.isNotEmpty) {
      for (Player pInCourt in currentPlayersOnCourt) {
        playedWithFactor += pow(
          (player.gamesPlayedWith[pInCourt.id] ?? 0) * 0.5,
          1.1,
        );
      }
      playedWithFactor = playedWithFactor / currentPlayersOnCourt.length;
      playedWithFactor = min(4.0, playedWithFactor);
    }
    double playedWithScore = 1.0 - playedWithFactor;

    // 최종 점수 = 각 점수 * 가중치의 합
    return equalScore +
        (skillScore * skillWeight) +
        (genderScore * genderWeight) +
        (waitedScore * waitedWeight) +
        (playedScore * playedWeight) +
        (playedWithScore * playedWithWeight);
  }
}
