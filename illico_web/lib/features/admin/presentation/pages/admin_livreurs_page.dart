import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/demo_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../livreur/data/datasources/livreur_remote_datasource.dart';
import '../../../livreur/presentation/providers/livreur_provider.dart';
import '../../../../core/api/api_client.dart';

class AdminLivreursPage extends ConsumerWidget {
  const AdminLivreursPage({super.key});

  void _deleteLivreur(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce livreur ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(livreurListProvider.notifier).delete(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(livreurListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livreurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(livreurListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(livreurListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucun livreur',
              icon: Icons.two_wheeler_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _LivreurAdminCard(
                livreur: state.items[i],
                onAction: () => ref.read(livreurListProvider.notifier).load(),
              ),
            ),
    );
  }
}

class _AddLivreurDialog extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddLivreurDialog({required this.onAdded});
  @override
  State<_AddLivreurDialog> createState() => _AddLivreurDialogState();
}

class _AddLivreurDialogState extends State<_AddLivreurDialog> {
  final _nomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _vehiculeCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Ajouter un livreur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nomCtrl, decoration: const InputDecoration(labelText: 'Nom complet')),
              TextField(controller: _telCtrl, decoration: const InputDecoration(labelText: 'Téléphone')),
              TextField(
                controller: _passCtrl,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
              ),
              TextField(controller: _vehiculeCtrl, decoration: const InputDecoration(labelText: 'ID Véhicule')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final ds = AuthRemoteDataSource(apiClient);
              final r = await ds.registerLivreur({
                'nom': _nomCtrl.text,
                'telephone': _telCtrl.text,
                'motDePasse': _passCtrl.text,
                'vehicule': _vehiculeCtrl.text,
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

class _LivreurAdminCard extends ConsumerWidget {
  final Map<String, dynamic> livreur;
  final VoidCallback onAction;
  const _LivreurAdminCard({required this.livreur, required this.onAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valide = livreur['valide'] as bool? ?? false;
    final statut = livreur['statut'] as String? ?? 'hors_ligne';
    final cash =
        ((livreur['cashCollecte'] as num?)?.toDouble() ?? 0) -
        ((livreur['cashReverse'] as num?)?.toDouble() ?? 0);
    final isBloque = cash > 50000;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  radius: 22,
                  child: Text(
                    (livreur['nom'] as String? ?? 'L')[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        livreur['nom'] as String? ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        livreur['telephone'] as String? ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _dot(
                      statut == 'en_ligne'
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      Formatters.statutLabel(statut),
                    ),
                    if (isBloque) _dot(AppColors.danger, 'Bloqué cash'),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                  onPressed: () {
                    final parent = context.findAncestorWidgetOfExactType<AdminLivreursPage>();
                    if (parent != null) {
                      parent._deleteLivreur(context, ref, livreur['_id']);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Cash dû: ${Formatters.currency(cash)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isBloque ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (!valide)
                  TextButton.icon(
                    onPressed: () => _validate(context, true),
                    icon: const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.accent,
                    ),
                    label: const Text(
                      'Valider',
                      style: TextStyle(color: AppColors.accent, fontSize: 12),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _validate(context, false),
                    icon: const Icon(
                      Icons.block,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    label: const Text(
                      'Suspendre',
                      style: TextStyle(color: AppColors.danger, fontSize: 12),
                    ),
                  ),
                if (cash > 0)
                  TextButton.icon(
                    onPressed: () => _reverseCash(context, cash),
                    icon: const Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: AppColors.info,
                    ),
                    label: const Text(
                      'Reverser',
                      style: TextStyle(color: AppColors.info, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color c, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, color: c)),
    ],
  );

  void _validate(BuildContext context, bool valide) =>
      demoGuard(context, () async {
        final ds = LivreurRemoteDataSource(apiClient);
        await ds.validate(livreur['_id'] as String, valide);
        onAction();
      });

  void _reverseCash(BuildContext context, double max) {
    demoGuard(context, () async {
      final ds = LivreurRemoteDataSource(apiClient);
      await ds.reverseCash(livreur['_id'] as String, max);
      onAction();
    });
  }
}
