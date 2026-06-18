import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Kept deliberately modest — 24 particles, capped duration — so the
/// one celebratory moment in the flow doesn't cost frames on a
/// mid-range device. Colours mix the brand purples with gold/moss/
/// coral, since a confetti burst reads better varied than monochrome.
class ConfettiOverlay extends StatefulWidget {
  const ConfettiOverlay({super.key, required this.play});

  final bool play;

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
    if (widget.play) _controller.play();
  }

  @override
  void didUpdateWidget(covariant ConfettiOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play && !oldWidget.play) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 24,
          maxBlastForce: 18,
          minBlastForce: 8,
          gravity: 0.25,
          colors: const [
            PebloColors.violet,
            PebloColors.deepViolet,
            PebloColors.gold,
            PebloColors.moss,
            PebloColors.coral,
          ],
        ),
      ),
    );
  }
}