import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../zone/data/datasources/zone_remote_datasource.dart';
import '../../../zone/presentation/providers/zone_provider.dart';

class AdminZonesPage extends ConsumerWidget {
  const AdminZonesPage({super.key});

  void _toggleActivation(BuildContext context, WidgetRef ref, String id, bool val) async {
    final ds = ZoneRemoteDataSource(apiClient);
    final r = await ds.update(id, {'actif': val});
    r.fold(
      (f) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.displayMessage))),
      (_) => ref.read(zoneListProvider.notifier).load(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(zoneListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(zoneListProvider.notifier).load(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? ErrorDisplay(
              failure: state.error!,
              onRetry: () => ref.read(zoneListProvider.notifier).load(),
            )
          : state.items.isEmpty
          ? const EmptyState(
              title: 'Aucune zone',
              icon: Icons.map_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final zone = state.items[i];
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
                              child: const Icon(Icons.map_outlined, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    zone.nom,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    zone.description ?? '-',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: zone.actif,
                              onChanged: (val) => _toggleActivation(context, ref, zone.id!, val),
                              activeColor: AppColors.accent,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Info(label: 'Supplément', value: Formatters.currency(zone.supplement)),
                            _Info(
                              label: 'Statut',
                              value: zone.actif ? 'ACTIF' : 'INACTIF',
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
