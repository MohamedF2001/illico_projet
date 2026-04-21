import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../zone/presentation/providers/zone_provider.dart';

class AdminZonesPage extends ConsumerWidget {
  const AdminZonesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(zoneListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(zoneListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(zoneListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucune zone',
              icon: Icons.map_outlined,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Supplément')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Statut')),
                  ],
                  rows: state.items.map((zone) => DataRow(
                    cells: [
                      DataCell(Text(zone.nom)),
                      DataCell(Text(Formatters.currency(zone.supplement))),
                      DataCell(Text(zone.description ?? '-')),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (zone.actif ? AppColors.accent : AppColors.danger).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          zone.actif ? 'ACTIF' : 'INACTIF',
                          style: TextStyle(color: zone.actif ? AppColors.accent : AppColors.danger, fontSize: 12),
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
