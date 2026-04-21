import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../point_illico/data/datasources/point_illico_remote_datasource.dart';
import '../../../point_illico/presentation/providers/point_illico_provider.dart';

class AdminPointsPage extends ConsumerWidget {
  const AdminPointsPage({super.key});

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
