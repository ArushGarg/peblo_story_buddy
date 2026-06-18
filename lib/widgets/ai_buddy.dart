import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/buddy_emotion.dart';
import '../theme/app_theme.dart';

/// Pip, hand-drawn entirely with [CustomPainter] in Peblo's own brand
/// purple — no bundled image assets, so the character adds ~0KB to the
/// APK and stays crisp at any screen density on a budget device.
class AiBuddy extends StatefulWidget {
  const AiBuddy({super.key, required this.emotion, this.size = 140});

  final BuddyEmotion emotion;
  final double size;

  @override
  State<AiBuddy> createState() => _AiBuddyState();
}

class _AiBuddyState extends State<AiBuddy> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _blinkController;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _scheduleNextBlink();
  }

  void _scheduleNextBlink() {
    final wait = Duration(milliseconds: 2200 + math.Random().nextInt(2400));
    Future.delayed(wait, () async {
      if (_disposed || !mounted) return;
      await _blinkController.forward();
      if (_disposed || !mounted) return;
      await _blinkController.reverse();
      _scheduleNextBlink();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _floatController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _blinkController]),
      builder: (context, _) {
        final floatOffset = math.sin(_floatController.value * math.pi) * 5;
        return Transform.translate(
          offset: Offset(0, -floatOffset),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _BuddyPainter(emotion: widget.emotion, blink: _blinkController.value),
            ),
          ),
        );
      },
    );
  }
}

class _BuddyPainter extends CustomPainter {
  _BuddyPainter({required this.emotion, required this.blink});

  final BuddyEmotion emotion;
  final double blink;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius * 0.92, Paint()..color = PebloColors.violet);
    canvas.drawCircle(center, radius * 0.72, Paint()..color = Colors.white.withOpacity(0.95));

    final antennaPaint = Paint()
      ..color = PebloColors.gold
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round;
    final antennaBase = Offset(center.dx, center.dy - radius * 0.9);
    final antennaTip = Offset(center.dx, center.dy - radius * 1.2);
    canvas.drawLine(antennaBase, antennaTip, antennaPaint);
    canvas.drawCircle(antennaTip, size.width * 0.05, antennaPaint);

    const eyeColor = PebloColors.deepViolet;
    final eyeDx = radius * 0.32;
    final eyeOpenHeight = radius * 0.26;
    final eyeHeight = (eyeOpenHeight * (1 - blink)).clamp(2.0, eyeOpenHeight);

    void drawEye(double dxSign) {
      final eyeCenter = Offset(center.dx + dxSign * eyeDx, center.dy - radius * 0.05);
      final rect = Rect.fromCenter(center: eyeCenter, width: radius * 0.22, height: eyeHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.12)),
        Paint()..color = eyeColor,
      );
    }

    drawEye(-1);
    drawEye(1);

    final mouthPaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.08
      ..strokeCap = StrokeCap.round;

    final mouthCenter = Offset(center.dx, center.dy + radius * 0.28);
    final mouthWidth = radius * 0.5;
    final path = Path();

    switch (emotion) {
      case BuddyEmotion.happy:
        path.moveTo(mouthCenter.dx - mouthWidth / 2, mouthCenter.dy - radius * 0.05);
        path.quadraticBezierTo(mouthCenter.dx, mouthCenter.dy + radius * 0.28,
            mouthCenter.dx + mouthWidth / 2, mouthCenter.dy - radius * 0.05);
        break;
      case BuddyEmotion.sad:
        path.moveTo(mouthCenter.dx - mouthWidth / 2, mouthCenter.dy + radius * 0.1);
        path.quadraticBezierTo(mouthCenter.dx, mouthCenter.dy - radius * 0.12,
            mouthCenter.dx + mouthWidth / 2, mouthCenter.dy + radius * 0.1);
        break;
      case BuddyEmotion.thinking:
        path.moveTo(mouthCenter.dx - mouthWidth / 2.4, mouthCenter.dy);
        path.lineTo(mouthCenter.dx + mouthWidth / 2.4, mouthCenter.dy);
        break;
      case BuddyEmotion.idle:
        path.moveTo(mouthCenter.dx - mouthWidth / 2.6, mouthCenter.dy - radius * 0.02);
        path.quadraticBezierTo(mouthCenter.dx, mouthCenter.dy + radius * 0.12,
            mouthCenter.dx + mouthWidth / 2.6, mouthCenter.dy - radius * 0.02);
        break;
    }
    canvas.drawPath(path, mouthPaint);

    if (emotion == BuddyEmotion.happy) {
      final cheekPaint = Paint()..color = PebloColors.coral.withOpacity(0.35);
      canvas.drawCircle(Offset(center.dx - radius * 0.5, center.dy + radius * 0.12), radius * 0.12, cheekPaint);
      canvas.drawCircle(Offset(center.dx + radius * 0.5, center.dy + radius * 0.12), radius * 0.12, cheekPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BuddyPainter oldDelegate) {
    return oldDelegate.emotion != emotion || oldDelegate.blink != blink;
  }
}