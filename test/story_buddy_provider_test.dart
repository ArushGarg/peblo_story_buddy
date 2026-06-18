import 'package:flutter_test/flutter_test.dart';
import 'package:peblo_story_buddy/models/quiz_question.dart';
import 'package:peblo_story_buddy/providers/story_buddy_provider.dart';
import 'package:peblo_story_buddy/services/tts_service.dart';

/// A fake narrator that never touches a real TTS engine — it just
/// lets the test fire completion/error callbacks on demand.
class _FakeNarrator implements StoryNarrator {
  void Function()? onComplete;
  void Function(String)? onError;

  @override
  void setOnComplete(void Function() cb) => onComplete = cb;

  @override
  void setOnError(void Function(String message) cb) => onError = cb;

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {}

  @override
  void dispose() {}
}

void main() {
  late StoryBuddyProvider provider;
  late _FakeNarrator narrator;
  final quiz = QuizQuestion.fromJson(const {
    'question': 'Q?',
    'options': ['A', 'B'],
    'answer': 'B',
  });

  setUp(() {
    narrator = _FakeNarrator();
    provider = StoryBuddyProvider(storyText: 'Once upon a time...', quiz: quiz, narrator: narrator);
  });

  test('reveals the quiz once narration completes', () async {
    await provider.readStory();
    narrator.onComplete?.call();
    expect(provider.quizPhase, QuizPhase.revealed);
  });

  test('a wrong answer moves to wrongAnswer, then back to revealed on acknowledge', () async {
    await provider.readStory();
    narrator.onComplete?.call();

    provider.selectAnswer('A');
    expect(provider.quizPhase, QuizPhase.wrongAnswer);

    provider.acknowledgeWrongAnswer();
    expect(provider.quizPhase, QuizPhase.revealed);
  });

  test('the correct answer moves the quiz to correct', () async {
    await provider.readStory();
    narrator.onComplete?.call();

    provider.selectAnswer('B');
    expect(provider.quizPhase, QuizPhase.correct);
  });

  test('a narration error surfaces a friendly message', () async {
    await provider.readStory();
    narrator.onError?.call('boom');
    expect(provider.narrationState, NarrationState.error);
    expect(provider.errorMessage, isNotNull);
  });
}
