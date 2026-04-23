import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';

class AdminForfaitsPage extends ConsumerWidget {
  const AdminForfaitsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forfaits'),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () {})]),
      body: const Center(child: Text('Chargement...', style: TextStyle(color: AppColors.textSecondary))),
    );
  }
}
