import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../livraison/presentation/providers/livraison_provider.dart';

class AdminLivraisonsPage extends ConsumerWidget {
  const AdminLivraisonsPage({super.key});

  void _showAddLivraisonForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddLivraisonDialog(onAdded: (body) {
        ref.read(livraisonFormProvider.notifier).create(body).then((success) {
          if (success) ref.read(livraisonListProvider.notifier).load();
        });
      }),
    );
  }

  void _deleteLivraison(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer cette livraison ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(livraisonListProvider.notifier).delete(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(livraisonListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livraisons'),
        /*actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(livraisonListProvider.notifier).load(),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => _showAddLivraisonForm(context, ref),
          ),
        ],*/
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
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final liv = state.items[i];
                final color = _getStatusColor(liv.statut);
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
                              child: Icon(Icons.local_shipping_outlined, color: color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '#${liv.id != null && liv.id!.length >= 6 ? liv.id!.substring(liv.id!.length - 6) : (liv.id ?? '-')}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    liv.client is Map ? (liv.client['nom'] ?? '-') : (liv.client?.toString() ?? '-'),
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
                                Formatters.statutLabel(liv.statut),
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                              onPressed: () => _deleteLivraison(context, ref, liv.id!),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Info(label: 'Prix', value: Formatters.currency(liv.prixEstime)),
                            _Info(label: 'Mode', value: liv.mode.toUpperCase()),
                            _Info(
                              label: 'Date',
                              value: liv.dateCreation != null ? Formatters.date(liv.dateCreation!) : '-',
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

class _AddLivraisonDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdded;
  const _AddLivraisonDialog({required this.onAdded});
  @override
  State<_AddLivraisonDialog> createState() => _AddLivraisonDialogState();
}

class _AddLivraisonDialogState extends State<_AddLivraisonDialog> {
  final _clientCtrl = TextEditingController();
  final _departCtrl = TextEditingController();
  final _arriveeCtrl = TextEditingController();
  final _poidsCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Nouvelle livraison'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _clientCtrl, decoration: const InputDecoration(labelText: 'ID Client')),
            TextField(controller: _departCtrl, decoration: const InputDecoration(labelText: 'Adresse Départ')),
            TextField(controller: _arriveeCtrl, decoration: const InputDecoration(labelText: 'Adresse Arrivée')),
            TextField(
              controller: _poidsCtrl,
              decoration: const InputDecoration(labelText: 'Poids (kg)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              widget.onAdded({
                'client': _clientCtrl.text,
                'pointDepart': {'adresse': _departCtrl.text, 'coordinates': [0.0, 0.0]},
                'pointArrivee': {'adresse': _arriveeCtrl.text, 'coordinates': [0.0, 0.0]},
                'mode': 'express',
                'poids': double.tryParse(_poidsCtrl.text) ?? 1,
                'vehicule': 'moto', // Default
              });
              Navigator.pop(context);
            },
            child: const Text('Créer'),
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
