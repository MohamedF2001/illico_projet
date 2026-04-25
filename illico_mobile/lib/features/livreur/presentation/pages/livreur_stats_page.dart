import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/livreur_provider.dart';

class LivreurStatsPage extends ConsumerWidget {
  const LivreurStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(missionsProvider);
    final stats = state.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Statistiques'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(missionsProvider.notifier).loadAll(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Performance Globale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (stats == null)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildStatCard(
                  title: 'Total Livraisons',
                  value: '${stats['totalLivraisons'] ?? 0}',
                  icon: Icons.delivery_dining,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Taux de Réussite',
                  value: '${stats['tauxReussite'] ?? 0}%',
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Revenu Total',
                  value: Formatters.currency((stats['revenuTotal'] as num?)?.toDouble() ?? 0),
                  icon: Icons.payments_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Note Moyenne',
                  value: '${stats['noteMoyenne'] ?? '5.0'} / 5',
                  icon: Icons.star_outline,
                  color: Colors.amber,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
