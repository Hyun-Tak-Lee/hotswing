import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

/// TTS 하드웨어 음성 출력을 전담하는 클라이언트.
class TtsClient {
  static final TtsClient instance = TtsClient._internal();
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;

  factory TtsClient() => instance;
  TtsClient._internal();

  /// 음성이 이미 출력 중인지 여부.
  bool get isPlaying => _isPlaying;

  /// 지정된 [text]를 음성으로 출력합니다. (재생 중 중복 호출 방지)
  Future<void> speak(String text) async {
    if (_isPlaying) return;

    await _initTts();
    _isPlaying = true;
    try {
      await _tts.speak(text);
    } catch (_) {
      _isPlaying = false;
    }
  }

  /// 현재 음성 출력을 중단합니다.
  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
  }

  Future<void> _initTts() async {
    if (_isInitialized) return;

    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // 최신 권장: speak()가 음성 재생 완료 시까지 비동기 대기하도록 설정
    await _tts.awaitSpeakCompletion(true);

    _tts.setCompletionHandler(() => _isPlaying = false);
    _tts.setCancelHandler(() => _isPlaying = false);
    _tts.setErrorHandler((_) => _isPlaying = false);

    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }
    _isInitialized = true;
  }
}
