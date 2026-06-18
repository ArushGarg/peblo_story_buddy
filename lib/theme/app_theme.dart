import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Peblo's own brand colours and type, taken directly from the style
/// guidance attached to the wireframe (#6F2BC2 / #36165E / Poppins) —
/// not invented separately from it.
class PebloColors {
  PebloColors._();

  static const violet = Color(0xFF6F2BC2); // brand primary
  static const deepViolet = Color(0xFF36165E); // brand secondary, doubles as ink
  static const violetTint = Color(0xFFF1E9FB); // soft lavender, used sparingly
  static const surface = Colors.white;
  static const canvas = Color(0xFFFAF9FC); // near-white app background

  // Deliberately off-brand: wrong/right feedback uses the universal
  // red/green a child already recognises from traffic lights and
  // games, rather than two shades of purple that read as near-identical
  // at a glance.
  static const coral = Color(0xFFFF6F61);
  static const moss = Color(0xFF3FAE8B);

  // Confetti-only — a celebration burst reads better with a few
  // varied colours mixed in than strictly on-brand purple alone.
  static const gold = Color(0xFFFFC94D);
}

ThemeData buildPebloTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: PebloColors.violet,
    scaffoldBackgroundColor: PebloColors.canvas,
  );

  final poppins = GoogleFonts.poppinsTextTheme(base.textTheme);

  return base.copyWith(
    textTheme: poppins.apply(bodyColor: PebloColors.deepViolet, displayColor: PebloColors.deepViolet),
  );
}