import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../livraison/domain/entities/livraison_entity.dart';
import '../providers/livreur_provider.dart';

class AvailableDeliveriesPage extends ConsumerWidget {
  const AvailableDeliveriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availableDeliveriesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Livraisons Disponibles',
          style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(availableDeliveriesProvider.notifier).load(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? Center(child: Text(state.error!.displayMessage))
                : state.items.isEmpty
                    ? const EmptyState(
                        title: 'Aucune livraison disponible',
                        subtitle: 'Revenez plus tard pour de nouvelles missions.',
                        icon: Icons.inventory_2_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          return _DeliveryCard(delivery: state.items[index]);
                        },
                      ),
      ),
    );
  }
}

class _DeliveryCard extends ConsumerWidget {
  final LivraisonEntity delivery;
  const _DeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    delivery.mode.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  Formatters.currency(delivery.prixEstime),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Column(
                  children: [
                    Icon(Icons.my_location, size: 18, color: AppColors.accent),
                    SizedBox(height: 20),
                    Icon(Icons.location_on, size: 18, color: AppColors.primary),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.pointDepart.adresse,
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        delivery.pointArrivee.adresse,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.black45),
                const SizedBox(width: 8),
                Text(
                  delivery.natureColis ?? 'Colis standard',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.monitor_weight_outlined, size: 16, color: Colors.black45),
                const SizedBox(width: 8),
                Text(
                  '${delivery.poids} kg',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await ref
                      .read(availableDeliveriesProvider.notifier)
                      .accept(delivery.id!);
                  if (success) {
                    ref.read(missionsProvider.notifier).loadAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Livraison acceptée !')),
                    );
                    context.go('/livreur/mission/${delivery.id}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Accepter la mission',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
