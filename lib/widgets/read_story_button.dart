import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The single primary action on the screen, full-width per the
/// wireframe, with a speaker icon rather than a book icon — the book
/// belongs on the story card, this button is about audio. Its label
/// changes with state ("Read Me a Story" → "Getting ready…" →
/// "Reading aloud…") so it narrates what's happening rather than
/// needing a separate status widget kept in sync with it.
class ReadStoryButton extends StatefulWidget {
  const ReadStoryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<ReadStoryButton> createState() => _ReadStoryButtonState();
}

class _ReadStoryButtonState extends State<ReadStoryButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : (_) => _pressController.reverse(),
      onTapUp: widget.isLoading ? null : (_) => _pressController.forward(),
      onTapCancel: widget.isLoading ? null : () => _pressController.forward(),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _pressController,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isLoading
                  ? [PebloColors.violet.withOpacity(0.55), PebloColors.deepViolet.withOpacity(0.55)]
                  : const [PebloColors.violet, PebloColors.deepViolet],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: PebloColors.violet.withOpacity(0.32),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                )
              else
                const Icon(Icons.volume_up_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}