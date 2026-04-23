import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../point_illico/data/datasources/point_illico_remote_datasource.dart';
import '../../../point_illico/presentation/providers/point_illico_provider.dart';

class AdminPointsPage extends ConsumerWidget {
  const AdminPointsPage({super.key});

  void _deletePoint(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce point ILLICO ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(pointIllicoListProvider.notifier).delete(id);
    }
  }

  void _showAddPointForm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _AddPointDialog(onAdded: () {
        ref.read(pointIllicoListProvider.notifier).load();
      }),
    );
  }

  void _toggleActivation(BuildContext context, WidgetRef ref, String id, bool val) async {
    final ds = PointIllicoRemoteDataSource(apiClient);
    final r = await ds.toggleActivation(id, val);
    r.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.displayMessage))),
      (_) => ref.read(pointIllicoListProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pointIllicoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Points ILLICO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pointIllicoListProvider.notifier).load(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showAddPointForm(context, ref),
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
              onRetry: () => ref.read(pointIllicoListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun point ILLICO',
              icon: Icons.store_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final point = state.items[i];
                final actif = point['actif'] as bool? ?? false;
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
                              child: const Icon(Icons.store_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    point['nom'] ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    point['telephone'] ?? '-',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: actif,
                              onChanged: (val) => _toggleActivation(context, ref, point['_id'], val),
                              activeColor: AppColors.accent,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                              onPressed: () => _deletePoint(context, ref, point['_id']),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Info(label: 'Ville', value: point['ville'] ?? '-'),
                            _Info(
                              label: 'Statut',
                              value: actif ? 'ACTIF' : 'INACTIF',
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

class _AddPointDialog extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddPointDialog({required this.onAdded});
  @override
  State<_AddPointDialog> createState() => _AddPointDialogState();
}

class _AddPointDialogState extends State<_AddPointDialog> {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Ajouter un Point ILLICO'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nomCtrl, decoration: const InputDecoration(labelText: 'Nom')),
              TextField(controller: _telCtrl, decoration: const InputDecoration(labelText: 'Téléphone')),
              TextField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
              ),
              TextField(controller: _addrCtrl, decoration: const InputDecoration(labelText: 'Adresse')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final ds = AuthRemoteDataSource(apiClient);
              final r = await ds.registerPoint({
                'nom': _nomCtrl.text,
                'telephone': _telCtrl.text,
                'motDePasse': _passCtrl.text,
                'adresse': _addrCtrl.text,
              });
              r.fold(
                (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.displayMessage))),
                (_) {
                  widget.onAdded();
                  Navigator.pop(context);
                },
              );
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
