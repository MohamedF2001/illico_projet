import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../forfait/data/datasources/forfait_remote_datasource.dart';
import '../../../forfait/presentation/providers/forfait_provider.dart';

class AdminForfaitsPage extends ConsumerWidget {
  const AdminForfaitsPage({super.key});

  void _deleteForfait(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce forfait ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(forfaitListProvider.notifier).delete(id);
    }
  }

  void _showAddForfaitForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddForfaitDialog(onAdded: (body) {
        ref.read(forfaitListProvider.notifier).add(body);
      }),
    );
  }

  void _toggleActivation(BuildContext context, WidgetRef ref, String id, bool val) async {
    final ds = ForfaitRemoteDataSource(apiClient);
    final r = await ds.update(id, {'actif': val});
    r.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.displayMessage))),
      (_) => ref.read(forfaitListProvider.notifier).load(),
    );
  }

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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddForfaitForm(context, ref),
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
              onRetry: () => ref.read(forfaitListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun forfait',
              icon: Icons.card_membership_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final forfait = state.items[i];
                final actif = forfait['actif'] as bool? ?? false;
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
                              child: const Icon(Icons.card_membership_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    forfait['nom'] ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${forfait['validiteJours'] ?? 0} jours',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: actif,
                              onChanged: (val) => _toggleActivation(context, ref, forfait['_id'], val),
                              activeColor: AppColors.accent,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                              onPressed: () => _deleteForfait(context, ref, forfait['_id']),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Info(
                              label: 'Prix',
                              value: Formatters.currency((forfait['prix'] as num?)?.toDouble() ?? 0),
                            ),
                            _Info(label: 'Volume', value: '${forfait['volume'] ?? 0} unités'),
                            _Info(label: 'Statut', value: actif ? 'ACTIF' : 'INACTIF'),
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

class _AddForfaitDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdded;
  const _AddForfaitDialog({required this.onAdded});
  @override
  State<_AddForfaitDialog> createState() => _AddForfaitDialogState();
}

class _AddForfaitDialogState extends State<_AddForfaitDialog> {
  final _nomCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _prixCtrl = TextEditingController();
  final _volCtrl = TextEditingController();
  final _valCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Ajouter un forfait'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nomCtrl, decoration: const InputDecoration(labelText: 'Nom')),
              TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(
                controller: _prixCtrl,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _volCtrl,
                decoration: const InputDecoration(labelText: 'Volume (unités)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _valCtrl,
                decoration: const InputDecoration(labelText: 'Validité (jours)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              widget.onAdded({
                'nom': _nomCtrl.text,
                'description': _descCtrl.text,
                'prix': double.tryParse(_prixCtrl.text) ?? 0,
                'volume': int.tryParse(_volCtrl.text) ?? 0,
                'validiteJours': int.tryParse(_valCtrl.text) ?? 0,
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
