import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/buddy_emotion.dart';
import '../providers/story_buddy_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ai_buddy.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/error_banner.dart';
import '../widgets/quiz_card.dart';
import '../widgets/read_story_button.dart';
import '../widgets/story_card.dart';

class StoryBuddyScreen extends StatelessWidget {
  const StoryBuddyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: PebloColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const Icon(Icons.menu_rounded, color: PebloColors.deepViolet),
        title: Text(
          'AI Story Buddy',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: PebloColors.violet,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle_outlined, color: PebloColors.deepViolet),
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<StoryBuddyProvider>(
            builder: (context, provider, _) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  children: [
                    // Isolated with RepaintBoundary + Selector so the
                    // buddy's continuous float/blink animation never
                    // forces the rest of the screen to repaint, and it
                    // only rebuilds when its own emotion changes.
                    RepaintBoundary(
                      child: Selector<StoryBuddyProvider, BuddyEmotion>(
                        selector: (_, p) => p.buddyEmotion,
                        builder: (_, emotion, __) => _BuddyStage(emotion: emotion),
                      ),
                    ),
                    const SizedBox(height: 20),
                    StoryCard(text: provider.storyText),
                    const SizedBox(height: 24),
                    if (provider.narrationState == NarrationState.error && provider.errorMessage != null) ...[
                      ErrorBanner(message: provider.errorMessage!, onRetry: provider.retryNarration),
                      const SizedBox(height: 16),
                    ],
                    if (provider.quizPhase == QuizPhase.hidden)
                      SizedBox(
                        width: double.infinity,
                        child: ReadStoryButton(
                          label: provider.narrationState == NarrationState.loading
                              ? 'Getting ready…'
                              : provider.narrationState == NarrationState.playing
                              ? 'Reading aloud…'
                              : 'Read Me a Story',
                          isLoading: provider.isReading,
                          onPressed: provider.readStory,
                        ),
                      ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 420),
                      transitionBuilder: (child, animation) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
                            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: provider.quizPhase == QuizPhase.hidden
                          ? const SizedBox.shrink(key: ValueKey('hidden'))
                          : Padding(
                        key: const ValueKey('quiz'),
                        padding: const EdgeInsets.only(top: 8),
                        child: QuizCard(
                          quiz: provider.quiz,
                          selectedOption: provider.selectedOption,
                          isWrong: provider.quizPhase == QuizPhase.wrongAnswer,
                          isCorrect: provider.quizPhase == QuizPhase.correct,
                          onSelect: provider.selectAnswer,
                          onShakeFinished: provider.acknowledgeWrongAnswer,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Same isolation strategy as the buddy above — confetti only
          // exists in the tree, and only repaints, while it's playing.
          RepaintBoundary(
            child: Selector<StoryBuddyProvider, bool>(
              selector: (_, p) => p.quizPhase == QuizPhase.correct,
              builder: (_, isCorrect, __) => ConfettiOverlay(play: isCorrect),
            ),
          ),
        ],
      ),
    );
  }
}

/// The buddy placeholder slot from the wireframe, sized and framed
/// like a card. Pip himself is custom-painted rather than a literal
/// placeholder image, but the area he sits in matches their layout.
class _BuddyStage extends StatelessWidget {
  const _BuddyStage({required this.emotion});

  final BuddyEmotion emotion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 196,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PebloColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: PebloColors.deepViolet.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: AiBuddy(emotion: emotion),
    );
  }
}