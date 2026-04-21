import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../colis/presentation/providers/colis_provider.dart';

class AdminColisPage extends ConsumerWidget {
  const AdminColisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(colisListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Colis & Alertes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(colisListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(colisListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun colis',
              icon: Icons.inventory_2_outlined,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Référence')),
                    DataColumn(label: Text('Destinataire')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Poids')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: state.items.map((colis) => DataRow(
                    cells: [
                      DataCell(Text(colis['reference'] ?? '-')),
                      DataCell(Text(colis['destinataire']?['nom'] ?? '-')),
                      DataCell(_statusBadge(colis['statut'] ?? '')),
                      DataCell(Text('${colis['poids'] ?? 0} kg')),
                      DataCell(Text(colis['createdAt'] != null ? Formatters.date(DateTime.parse(colis['createdAt'])) : '-')),
                    ],
                  )).toList(),
                ),
              ),
            ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = AppColors.info;
    if (status == 'livre') color = AppColors.accent;
    if (status == 'en_attente') color = AppColors.warning;
    if (status == 'annule') color = AppColors.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
