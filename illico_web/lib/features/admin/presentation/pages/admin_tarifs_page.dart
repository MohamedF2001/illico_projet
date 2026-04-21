import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../tarif/presentation/providers/tarif_provider.dart';

class AdminTarifsPage extends ConsumerWidget {
  const AdminTarifsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tarifListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarifs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(tarifListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(tarifListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun tarif',
              icon: Icons.price_change_outlined,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nom')),
                    DataColumn(label: Text('Prix base')),
                    DataColumn(label: Text('Km inclus')),
                    DataColumn(label: Text('Prix/Km sup')),
                    DataColumn(label: Text('Zone')),
                  ],
                  rows: state.items.map((tarif) => DataRow(
                    cells: [
                      DataCell(Text(tarif['nom'] ?? '-')),
                      DataCell(Text(Formatters.currency((tarif['prixBase'] as num?)?.toDouble() ?? 0))),
                      DataCell(Text('${tarif['distanceInclus'] ?? 0} km')),
                      DataCell(Text(Formatters.currency((tarif['prixKmSupp'] as num?)?.toDouble() ?? 0))),
                      DataCell(Text(tarif['zoneId']?.toString() ?? '-')),
                    ],
                  )).toList(),
                ),
              ),
            ),
    );
  }
}
