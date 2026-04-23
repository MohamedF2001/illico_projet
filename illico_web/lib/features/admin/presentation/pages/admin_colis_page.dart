import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../colis/presentation/providers/colis_provider.dart';

class AdminColisPage extends ConsumerWidget {
  const AdminColisPage({super.key});

  void _deleteColis(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce colis ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(colisListProvider.notifier).delete(id);
    }
  }

  void _showAddColisForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddColisDialog(onAdded: (body) {
        ref.read(colisListProvider.notifier).add(body);
      }),
    );
  }

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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddColisForm(context, ref),
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
              onRetry: () => ref.read(colisListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun colis',
              icon: Icons.inventory_2_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final colis = state.items[i];
                final status = colis['statut'] ?? '';
                Color color = AppColors.info;
                if (status == 'livre') color = AppColors.accent;
                if (status == 'en_attente') color = AppColors.warning;
                if (status == 'annule') color = AppColors.danger;

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
                              child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    colis['reference'] ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    colis['destinataire']?['nom'] ?? '-',
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
                              onPressed: () => _deleteColis(context, ref, colis['_id']),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Info(label: 'Poids', value: '${colis['poids'] ?? 0} kg'),
                            _Info(
                              label: 'Date',
                              value: colis['createdAt'] != null
                                  ? Formatters.date(DateTime.parse(colis['createdAt']))
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

class _AddColisDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdded;
  const _AddColisDialog({required this.onAdded});
  @override
  State<_AddColisDialog> createState() => _AddColisDialogState();
}

class _AddColisDialogState extends State<_AddColisDialog> {
  final _refCtrl = TextEditingController();
  final _livIdCtrl = TextEditingController();
  final _pointIdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Ajouter un colis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _refCtrl, decoration: const InputDecoration(labelText: 'Référence')),
            TextField(controller: _livIdCtrl, decoration: const InputDecoration(labelText: 'ID Livraison')),
            TextField(controller: _pointIdCtrl, decoration: const InputDecoration(labelText: 'ID Point Illico')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              widget.onAdded({
                'reference': _refCtrl.text,
                'livraison': _livIdCtrl.text,
                'pointIllico': _pointIdCtrl.text,
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
