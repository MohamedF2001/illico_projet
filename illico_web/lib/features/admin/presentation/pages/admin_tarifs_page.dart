import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../tarif/presentation/providers/tarif_provider.dart';

class AdminTarifsPage extends ConsumerWidget {
  const AdminTarifsPage({super.key});

  void _deleteTarif(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce tarif ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(tarifListProvider.notifier).delete(id);
    }
  }

  void _showAddTarifForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddTarifDialog(onAdded: (body) {
        ref.read(tarifListProvider.notifier).add(body);
      }),
    );
  }

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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddTarifForm(context, ref),
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
              onRetry: () => ref.read(tarifListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun tarif',
              icon: Icons.price_change_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final tarif = state.items[i];
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
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.price_change_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tarif['nom'] ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Zone: ${tarif['zoneId']?.toString() ?? '-'}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                              onPressed: () => _deleteTarif(context, ref, tarif['_id']),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Info(
                              label: 'Prix base',
                              value: Formatters.currency((tarif['prixBase'] as num?)?.toDouble() ?? 0),
                            ),
                            _Info(label: 'Km inclus', value: '${tarif['distanceInclus'] ?? 0} km'),
                            _Info(
                              label: 'Prix/Km sup',
                              value: Formatters.currency((tarif['prixKmSupp'] as num?)?.toDouble() ?? 0),
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

class _AddTarifDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdded;
  const _AddTarifDialog({required this.onAdded});
  @override
  State<_AddTarifDialog> createState() => _AddTarifDialogState();
}

class _AddTarifDialogState extends State<_AddTarifDialog> {
  final _nomCtrl = TextEditingController();
  final _baseCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final _zoneIdCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Ajouter un tarif'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nomCtrl, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(
              controller: _baseCtrl,
              decoration: const InputDecoration(labelText: 'Prix base'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _kmCtrl,
              decoration: const InputDecoration(labelText: 'Prix/Km sup'),
              keyboardType: TextInputType.number,
            ),
            TextField(controller: _zoneIdCtrl, decoration: const InputDecoration(labelText: 'ID Zone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              widget.onAdded({
                'nom': _nomCtrl.text,
                'prixBase': double.tryParse(_baseCtrl.text) ?? 0,
                'prixKmSupp': double.tryParse(_kmCtrl.text) ?? 0,
                'zoneId': _zoneIdCtrl.text,
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
