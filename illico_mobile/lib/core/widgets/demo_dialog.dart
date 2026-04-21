import 'package:flutter/material.dart';
import '../config/app_config.dart';

void showDemoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Mode Démo'),
      content: const Text('Cette action est désactivée en mode démonstration.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

/// Wrapper : appelle [action] sauf en mode démo
void demoGuard(BuildContext context, VoidCallback action) {
  if (kDemoMode) { showDemoDialog(context); return; }
  action();
}
