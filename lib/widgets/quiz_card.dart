import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/quiz_question.dart';
import '../theme/app_theme.dart';

/// Renders entirely from [quiz] — nothing about the question, option
/// count, or correct answer is hardcoded, so a different JSON payload
/// with 3, 4, or 5 options renders correctly with zero code changes.
///
/// Structurally this mirrors the wireframe: the question sits directly
/// on the page (no enclosing mega-card), and each option is its own
/// white row with a trailing radio-style indicator. The whole row is
/// the tap target, not just the small circle — a far easier hit area
/// for a 6-10 year old than a literal radio button would be.
class QuizCard extends StatefulWidget {
  const QuizCard({
    super.key,
    required this.quiz,
    required this.selectedOption,
    required this.isWrong,
    required this.isCorrect,
    required this.onSelect,
    required this.onShakeFinished,
  });

  final QuizQuestion quiz;
  final String? selectedOption;
  final bool isWrong;
  final bool isCorrect;
  final ValueChanged<String> onSelect;
  final VoidCallback onShakeFinished;

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  }

  @override
  void didUpdateWidget(covariant QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWrong && !oldWidget.isWrong) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0).then((_) {
        _shakeController.reset();
        widget.onShakeFinished();
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  double _shakeOffset(double t) {
    if (t == 0) return 0;
    const oscillations = 3;
    final decay = 1 - t;
    return 16 * decay * math.sin(t * oscillations * 2 * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(offset: Offset(_shakeOffset(_shakeController.value), 0), child: child);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.quiz.question,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (widget.isCorrect)
            _SuccessBadge(answer: widget.quiz.answer)
          else
            ...widget.quiz.options.map((option) {
              final isSelected = option == widget.selectedOption;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OptionButton(
                  label: option,
                  isSelected: isSelected,
                  isWrong: isSelected && widget.isWrong,
                  onTap: widget.isWrong ? null : () => widget.onSelect(option),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.isSelected,
    required this.isWrong,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isWrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isWrong ? PebloColors.coral : PebloColors.violet;
    final borderColor = isSelected || isWrong ? accent : PebloColors.violet.withOpacity(0.15);
    final fillColor = isWrong
        ? PebloColors.coral.withOpacity(0.08)
        : isSelected
        ? PebloColors.violetTint
        : PebloColors.surface;

    return Material(
      color: fillColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: isSelected || isWrong ? 2 : 1),
            boxShadow: [
              BoxShadow(color: PebloColors.deepViolet.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withOpacity(isSelected || isWrong ? 1 : 0.35), width: 2),
                  color: (isSelected && !isWrong) ? accent : Colors.transparent,
                ),
                child: (isSelected && !isWrong) ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessBadge extends StatelessWidget {
  const _SuccessBadge({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: PebloColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: PebloColors.moss.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: PebloColors.deepViolet.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(color: PebloColors.moss, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 12),
            Text(
              "That's it — $answer!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: PebloColors.deepViolet),
            ),
          ],
        ),
      ),
    );
  }
}