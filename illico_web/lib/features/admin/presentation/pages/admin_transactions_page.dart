import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

class AdminTransactionsPage extends ConsumerWidget {
  const AdminTransactionsPage({super.key});

  void _deleteTransaction(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer cette transaction ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(transactionListProvider.notifier).delete(id);
    }
  }

  void _showAddTransactionForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddTransactionDialog(onAdded: (body) {
        ref.read(transactionListProvider.notifier).add(body);
      }),
    );
  }

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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTransactionForm(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter'),
            ),
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
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final tx = state.items[i];
                final status = tx['statut'] ?? '';
                Color color = AppColors.info;
                if (status == 'reussi' || status == 'success' || status == 'complete') color = AppColors.accent;
                if (status == 'en_attente' || status == 'pending') color = AppColors.warning;
                if (status == 'echoue' || status == 'failed') color = AppColors.danger;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx['type']?.toString().toUpperCase() ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    tx['reference'] ?? '-',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                              onPressed: () => _deleteTransaction(context, ref, tx['_id']),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Info(
                              label: 'Montant',
                              value: Formatters.currency((tx['montant'] as num?)?.toDouble() ?? 0),
                            ),
                            _Info(
                              label: 'Date',
                              value: tx['createdAt'] != null
                                  ? Formatters.date(DateTime.parse(tx['createdAt']))
                                  : '-',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

}

class _AddTransactionDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdded;
  const _AddTransactionDialog({required this.onAdded});
  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _typeCtrl = TextEditingController();
  final _montantCtrl = TextEditingController();
  final _clientIdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Ajouter une transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _typeCtrl, decoration: const InputDecoration(labelText: 'Type (paiement, commission...)')),
            TextField(
              controller: _montantCtrl,
              decoration: const InputDecoration(labelText: 'Montant'),
              keyboardType: TextInputType.number,
            ),
            TextField(controller: _clientIdCtrl, decoration: const InputDecoration(labelText: 'ID Client')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              widget.onAdded({
                'type': _typeCtrl.text,
                'montant': double.tryParse(_montantCtrl.text) ?? 0,
                'client': _clientIdCtrl.text,
              });
              Navigator.pop(context);
            },
            child: const Text('Ajouter'),
          ),
        ],
      );
}

class _Info extends StatelessWidget {
  final String label, value;
  const _Info({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      );
}
