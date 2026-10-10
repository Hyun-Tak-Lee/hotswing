import 'package:hotswing/src/data/tts/tts_client.dart';

/// 코트에 배치된 선수를 음성으로 호명하는 도메인 서비스.
class CourtSpeaker {
  final TtsClient _ttsClient;

  CourtSpeaker({TtsClient? ttsClient})
      : _ttsClient = ttsClient ?? TtsClient.instance;

  /// [courtNumber]번 코트의 [playerNames] 선수들을 순서대로 호명합니다.
  Future<void> speakPlayers({
    required int courtNumber,
    required List<String> playerNames,
  }) async {
    if (playerNames.isEmpty) return;
    final names = playerNames.join(', ');
    await _ttsClient.speak('$courtNumber코트, $names');
  }

  /// 현재 호명을 중단합니다.
  Future<void> stop() async {
    await _ttsClient.stop();
  }
}
