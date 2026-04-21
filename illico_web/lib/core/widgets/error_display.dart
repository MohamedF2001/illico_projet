import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../errors/failures.dart';

class ErrorDisplay extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const ErrorDisplay({super.key, required this.failure, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(failure.displayMessage,
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ]),
      ),
    );
  }
}
