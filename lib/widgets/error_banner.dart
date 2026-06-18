import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PebloColors.coral.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: PebloColors.coral.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sentiment_dissatisfied_rounded, color: PebloColors.coral),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(color: PebloColors.deepViolet, fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry', style: TextStyle(color: PebloColors.coral, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}