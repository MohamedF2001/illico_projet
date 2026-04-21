import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../livraison/presentation/providers/livraison_provider.dart';

class AdminLivraisonsPage extends ConsumerWidget {
  const AdminLivraisonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(livraisonListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livraisons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(livraisonListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(livraisonListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucune livraison',
              icon: Icons.local_shipping_outlined,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Client')),
                    DataColumn(label: Text('Mode')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Prix')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: state.items.map((liv) => DataRow(
                    cells: [
                      DataCell(Text(liv.id != null && liv.id!.length >= 6 ? liv.id!.substring(liv.id!.length - 6) : (liv.id ?? '-'))),
                      DataCell(Text(liv.client is Map ? (liv.client['nom'] ?? '-') : (liv.client?.toString() ?? '-'))),
                      DataCell(Text(liv.mode.toUpperCase())),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(liv.statut).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          Formatters.statutLabel(liv.statut),
                          style: TextStyle(color: _getStatusColor(liv.statut), fontSize: 12),
                        ),
                      )),
                      DataCell(Text(Formatters.currency(liv.prixEstime))),
                      DataCell(Text(liv.dateCreation != null ? Formatters.date(liv.dateCreation!) : '-')),
                    ],
                  )).toList(),
                ),
              ),
            ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut) {
      case 'livre':
      case 'termine':
        return AppColors.accent;
      case 'annule':
        return AppColors.danger;
      case 'en_attente':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }
}
