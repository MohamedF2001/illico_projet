import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';

class AdminPointsPage extends ConsumerWidget {
  const AdminPointsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Points ILLICO'),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () {})]),
      body: const Center(child: Text('Chargement...', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
