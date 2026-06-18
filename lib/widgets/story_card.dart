import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Matches the wireframe's structure: a small label + icon header row,
/// then the narrative text left-aligned below it (left-aligned reads
/// far better than centered across several lines, which is also what
/// the wireframe itself shows).
class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PebloColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: PebloColors.deepViolet.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PIP'S STORY",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PebloColors.violet,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Icon(Icons.menu_book_rounded, color: PebloColors.violet.withOpacity(0.55), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}