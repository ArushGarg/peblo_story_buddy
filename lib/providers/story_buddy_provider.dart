import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/buddy_emotion.dart';
import '../models/quiz_question.dart';
import '../services/tts_service.dart';

enum NarrationState { idle, loading, playing, error }

enum QuizPhase { hidden, revealed, wrongAnswer, correct }

/// Holds all state for the Story Buddy screen: narration playback,
/// loading/error handling, and the data-driven quiz flow.
///
/// [StoryNarrator] is injected so this class is unit-testable without
/// touching a real TTS engine — see test/story_buddy_provider_test.dart.
class StoryBuddyProvider extends ChangeNotifier {
  StoryBuddyProvider({
    required this.storyText,
    required this.quiz,
    StoryNarrator? narrator,
  }) : _narrator = narrator ?? DeviceTtsNarrator() {
    _narrator.setOnComplete(_handleNarrationComplete);
    _narrator.setOnError(_handleNarrationError);
  }

  final String storyText;
  final QuizQuestion quiz;
  final StoryNarrator _narrator;

  Timer? _watchdog;

  NarrationState _narrationState = NarrationState.idle;
  QuizPhase _quizPhase = QuizPhase.hidden;
  String? _selectedOption;
  String? _errorMessage;

  NarrationState get narrationState => _narrationState;
  QuizPhase get quizPhase => _quizPhase;
  String? get selectedOption => _selectedOption;
  String? get errorMessage => _errorMessage;

  bool get isReading =>
      _narrationState == NarrationState.loading || _narrationState == NarrationState.playing;

  BuddyEmotion get buddyEmotion {
    if (_quizPhase == QuizPhase.correct) return BuddyEmotion.happy;
    if (_quizPhase == QuizPhase.wrongAnswer) return BuddyEmotion.sad;
    if (isReading) return BuddyEmotion.thinking;
    return BuddyEmotion.idle;
  }

  Future<void> readStory() async {
    if (isReading) return;

    _errorMessage = null;
    _narrationState = NarrationState.loading;
    notifyListeners();

    // A short, deliberate beat before speech starts: it gives the
    // "preparing" state long enough to register for a child instead of
    // flashing past, and mirrors the delay a remote TTS call would add.
    await Future.delayed(const Duration(milliseconds: 350));

    _narrationState = NarrationState.playing;
    notifyListeners();

    _watchdog?.cancel();
    _watchdog = Timer(const Duration(seconds: 20), () {
      if (_narrationState == NarrationState.playing) {
        _handleNarrationError('Narration timed out.');
      }
    });

    await _narrator.speak(storyText);
  }

  Future<void> retryNarration() async {
    _errorMessage = null;
    await readStory();
  }

  void selectAnswer(String option) {
    if (_quizPhase != QuizPhase.revealed) return;

    _selectedOption = option;
    _quizPhase = option == quiz.answer ? QuizPhase.correct : QuizPhase.wrongAnswer;
    notifyListeners();
  }

  /// Called once the wrong-answer shake animation finishes, returning
  /// the card to a state that accepts a new tap.
  void acknowledgeWrongAnswer() {
    if (_quizPhase != QuizPhase.wrongAnswer) return;
    _quizPhase = QuizPhase.revealed;
    _selectedOption = null;
    notifyListeners();
  }

  void _handleNarrationComplete() {
    _watchdog?.cancel();
    _narrationState = NarrationState.idle;
    _quizPhase = QuizPhase.revealed;
    notifyListeners();
  }

  void _handleNarrationError(String _) {
    _watchdog?.cancel();
    _narrationState = NarrationState.error;
    _errorMessage = "Oops, I couldn't read the story. Let's try again!";
    notifyListeners();
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _narrator.dispose();
    super.dispose();
  }
}
