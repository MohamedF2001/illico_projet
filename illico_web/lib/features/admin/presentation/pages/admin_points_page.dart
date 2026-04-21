import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../point_illico/presentation/providers/point_illico_provider.dart';

class AdminPointsPage extends ConsumerWidget {
  const AdminPointsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pointIllicoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Points ILLICO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pointIllicoListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(pointIllicoListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun point ILLICO',
              icon: Icons.store_outlined,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Ville')),
                    DataColumn(label: Text('Contact')),
                    DataColumn(label: Text('Statut')),
                  ],
                  rows: state.items.map((point) => DataRow(
                    cells: [
                      DataCell(Text(point['nom'] ?? '-')),
                      DataCell(Text(point['ville'] ?? '-')),
                      DataCell(Text(point['telephone'] ?? '-')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ((point['actif'] as bool? ?? false) ? AppColors.accent : AppColors.danger).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (point['actif'] as bool? ?? false) ? 'ACTIF' : 'INACTIF',
                          style: TextStyle(color: (point['actif'] as bool? ?? false) ? AppColors.accent : AppColors.danger, fontSize: 12),
                        ),
                      )),
                    ],
                  )).toList(),
                ),
              ),
            ),
    );
  }
}
