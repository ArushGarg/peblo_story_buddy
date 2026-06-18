import 'package:flutter_tts/flutter_tts.dart';

/// Abstraction over "something that can read a piece of text aloud."
///
/// The brief asks for the device's native TTS engine
/// (`AVSpeechSynthesizer` on iOS, `flutter_tts` on Flutter), implemented
/// below as [DeviceTtsNarrator]. The interface exists so a remote
/// engine (the brief's ElevenLabs bonus) could be dropped in later
/// without touching [StoryBuddyProvider] or any widget — see the
/// README for exactly how that swap, and its caching, would work.
abstract class StoryNarrator {
  Future<void> speak(String text);
  Future<void> stop();
  void setOnComplete(void Function() onComplete);
  void setOnError(void Function(String message) onError);
  void dispose();
}

/// Uses the device's own TTS engine via `flutter_tts` — no network
/// call, no audio file to cache, works offline.
class DeviceTtsNarrator implements StoryNarrator {
  DeviceTtsNarrator() {
    _tts = FlutterTts();
    _configure();
  }

  late final FlutterTts _tts;
  void Function()? _onComplete;
  void Function(String message)? _onError;

  Future<void> _configure() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42); // slower, warmer pace for a young listener
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);

    _tts.setCompletionHandler(() => _onComplete?.call());
    _tts.setErrorHandler((message) => _onError?.call(message.toString()));
    _tts.setCancelHandler(() {
      // A user-triggered stop, not a failure — nothing to surface.
    });
  }

  @override
  void setOnComplete(void Function() onComplete) => _onComplete = onComplete;

  @override
  void setOnError(void Function(String message) onError) => _onError = onError;

  @override
  Future<void> speak(String text) async {
    try {
      final result = await _tts.speak(text);
      if (result != 1) {
        _onError?.call('The device could not start narration.');
      }
    } catch (e) {
      _onError?.call(e.toString());
    }
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }

  @override
  void dispose() {
    _tts.stop();
  }
}
