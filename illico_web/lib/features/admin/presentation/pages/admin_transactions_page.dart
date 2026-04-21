import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

class AdminTransactionsPage extends ConsumerWidget {
  const AdminTransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(transactionListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(transactionListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucune transaction',
              icon: Icons.receipt_long_outlined,
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Montant')),
                    DataColumn(label: Text('Statut')),
                    DataColumn(label: Text('Référence')),
                    DataColumn(label: Text('Date')),
                  ],
                  rows: state.items.map((tx) => DataRow(
                    cells: [
                      DataCell(Text(tx['type']?.toString().toUpperCase() ?? '-')),
                      DataCell(Text(Formatters.currency((tx['montant'] as num?)?.toDouble() ?? 0))),
                      DataCell(_statusBadge(tx['statut'] ?? '')),
                      DataCell(Text(tx['reference'] ?? '-')),
                      DataCell(Text(tx['createdAt'] != null ? Formatters.date(DateTime.parse(tx['createdAt'])) : '-')),
                    ],
                  )).toList(),
                ),
              ),
            ),
    );
  }

  Widget _statusBadge(String status) {
    Color color = AppColors.info;
    if (status == 'reussi' || status == 'success' || status == 'complete') color = AppColors.accent;
    if (status == 'en_attente' || status == 'pending') color = AppColors.warning;
    if (status == 'echoue' || status == 'failed') color = AppColors.danger;

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
