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
