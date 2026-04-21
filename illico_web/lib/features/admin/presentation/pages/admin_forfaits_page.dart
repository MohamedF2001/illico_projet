import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../forfait/presentation/providers/forfait_provider.dart';

class AdminForfaitsPage extends ConsumerWidget {
  const AdminForfaitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forfaitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forfaits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(forfaitListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(forfaitListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun forfait',
              icon: Icons.card_membership_outlined,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Prix')),
                    DataColumn(label: Text('Volume')),
                    DataColumn(label: Text('Validité')),
                    DataColumn(label: Text('Statut')),
                  ],
                  rows: state.items.map((forfait) => DataRow(
                    cells: [
                      DataCell(Text(forfait['nom'] ?? '-')),
                      DataCell(Text(Formatters.currency((forfait['prix'] as num?)?.toDouble() ?? 0))),
                      DataCell(Text('${forfait['volume'] ?? 0} unités')),
                      DataCell(Text('${forfait['validiteJours'] ?? 0} jours')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ((forfait['actif'] as bool? ?? false) ? AppColors.accent : AppColors.danger).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (forfait['actif'] as bool? ?? false) ? 'ACTIF' : 'INACTIF',
                          style: TextStyle(color: (forfait['actif'] as bool? ?? false) ? AppColors.accent : AppColors.danger, fontSize: 12),
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
