import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';

/// Page admin des transactions.
/// L'API ne fournit PAS de endpoint POST /transactions.
/// Les transactions sont créées automatiquement (livraisons, commissions…).
/// Actions disponibles:
///  - GET /transactions → liste
///  - PUT /transactions/:id/validate → valider / échouer
///  - GET /transactions/admin/stats → statistiques
class AdminTransactionsPage extends ConsumerStatefulWidget {
  const AdminTransactionsPage({super.key});

  @override
  ConsumerState<AdminTransactionsPage> createState() =>
      _AdminTransactionsPageState();
}

class _AdminTransactionsPageState
    extends ConsumerState<AdminTransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Map<String, dynamic>? _stats;
  bool _loadingStats = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final r = await apiClient.dio.get('/transactions/admin/stats');
      setState(() {
        _stats = r.data['data'] as Map<String, dynamic>?;
        _loadingStats = false;
      });
    } catch (_) {
      setState(() => _loadingStats = false);
    }
  }

  /// Valider ou marquer comme échoué une transaction en attente.
  /// PUT /api/transactions/:id/validate → { statut: 'validé' | 'échoué' }
  Future<void> _validateTransaction(
      BuildContext context, String id, String statut) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(statut == 'validé'
            ? 'Valider cette transaction ?'
            : 'Marquer comme échouée ?'),
        content: Text(statut == 'validé'
            ? 'La transaction sera marquée comme validée et le solde client sera ajusté.'
            : 'La transaction sera marquée comme échouée.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: statut == 'validé'
                  ? AppColors.accent
                  : AppColors.danger,
            ),
            child: Text(
              statut == 'validé' ? 'Valider' : 'Échouer',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await apiClient.dio
          .put('/transactions/$id/validate', data: {'statut': statut});
      ref.read(transactionListProvider.notifier).load();
      _loadStats();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(statut == 'validé'
              ? 'Transaction validée ✅'
              : 'Transaction marquée échouée'),
          backgroundColor:
          statut == 'validé' ? AppColors.accent : AppColors.danger,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors de la mise à jour'),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            onPressed: () {
              ref.read(transactionListProvider.notifier).load();
              _loadStats();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Historique'),
            Tab(text: 'Statistiques'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Onglet 1: Liste des transactions ────────────
          _buildList(context, state),
          // ── Onglet 2: Statistiques financières ──────────
          _buildStats(),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, TransactionListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return ErrorDisplay(
        failure: state.error!,
        onRetry: () => ref.read(transactionListProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return const EmptyState(
        title: 'Aucune transaction',
        subtitle: 'Les transactions apparaissent automatiquement.',
        icon: Icons.receipt_long_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final tx = state.items[i];
        final statut = tx['statut'] as String? ?? '';
        final type = tx['type'] as String? ?? '';
        final montant =
            (tx['montant'] as num?)?.toDouble() ?? 0;
        final isPending = statut == 'en_attente';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icône type
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _typeColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_typeIcon(type),
                          color: _typeColor(type), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _typeLabel(type),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                          if (tx['description'] != null)
                            Text(
                              tx['description'] as String,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    // Montant + statut
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.currency(montant),
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: _typeColor(type)),
                        ),
                        _StatutBadge(statut: statut),
                      ],
                    ),
                  ],
                ),
                // Infos complémentaires
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (tx['client'] is Map)
                      _TxInfo(
                          icon: Icons.person_outline,
                          value: (tx['client'] as Map)['nom'] as String? ??
                              '-'),
                    if (tx['livreur'] is Map) ...[
                      const SizedBox(width: 12),
                      _TxInfo(
                          icon: Icons.two_wheeler,
                          value: (tx['livreur'] as Map)['nom']
                          as String? ??
                              '-'),
                    ],
                    const Spacer(),
                    if (tx['dateTransaction'] != null)
                      Text(
                        Formatters.dateTime(
                            DateTime.tryParse(
                                tx['dateTransaction'] as String)),
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary),
                      ),
                  ],
                ),
                // Actions uniquement si en_attente
                if (isPending) ...[
                  const Divider(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _validateTransaction(
                              context, tx['_id'] as String, 'échoué'),
                          icon: const Icon(Icons.cancel_outlined,
                              size: 14, color: AppColors.danger),
                          label: const Text('Échouer',
                              style: TextStyle(
                                  color: AppColors.danger, fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.danger),
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _validateTransaction(
                              context, tx['_id'] as String, 'validé'),
                          icon: const Icon(Icons.check_circle_outline,
                              size: 14, color: Colors.white),
                          label: const Text('Valider',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            minimumSize: const Size(0, 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStats() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text('Statistiques non disponibles'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadStats,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final parType =
        (_stats!['parType'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final totalMois =
        (_stats!['totalMois'] as num?)?.toDouble() ?? 0;
    final periode = _stats!['periode'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Carte total mois ──────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Revenus du mois',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  Formatters.currency(totalMois),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800),
                ),
                if (periode != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Du ${Formatters.date(DateTime.tryParse(periode['debut'] as String? ?? ''))} '
                        'au ${Formatters.date(DateTime.tryParse(periode['fin'] as String? ?? ''))}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Détail par type',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          // ── Cartes par type ───────────────────────────
          ...parType.map((t) {
            final typeId = t['_id'] as String? ?? '';
            final total = (t['total'] as num?)?.toDouble() ?? 0;
            final count = (t['count'] as num?)?.toInt() ?? 0;
            final valide = (t['valide'] as num?)?.toInt() ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _typeColor(typeId).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_typeIcon(typeId),
                        color: _typeColor(typeId), size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_typeLabel(typeId),
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text(
                          '$count opérations · $valide validées',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    Formatters.currency(total),
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _typeColor(typeId)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helpers
  Color _typeColor(String type) => switch (type) {
    'paiement' => AppColors.primary,
    'commission_livreur' => AppColors.info,
    'commission_point' => AppColors.accent,
    'stockage' => AppColors.warning,
    'remboursement' => AppColors.danger,
    _ => AppColors.textSecondary,
  };

  IconData _typeIcon(String type) => switch (type) {
    'paiement' => Icons.payment,
    'commission_livreur' => Icons.two_wheeler,
    'commission_point' => Icons.store_outlined,
    'stockage' => Icons.inventory_2_outlined,
    'remboursement' => Icons.undo,
    _ => Icons.receipt_outlined,
  };

  String _typeLabel(String type) => switch (type) {
    'paiement' => 'Paiement client',
    'commission_livreur' => 'Commission livreur',
    'commission_point' => 'Commission Point ILLICO',
    'stockage' => 'Frais de stockage',
    'remboursement' => 'Remboursement',
    _ => type,
  };
}

// ── Widgets utilitaires ─────────────────────────────────────
class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge({required this.statut});

  Color get _color => switch (statut) {
    'validé' => AppColors.accent,
    'échoué' => AppColors.danger,
    'en_attente' => AppColors.warning,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      Formatters.statutLabel(statut).toUpperCase(),
      style: TextStyle(
          fontSize: 9, fontWeight: FontWeight.w700, color: _color),
    ),
  );
}

class _TxInfo extends StatelessWidget {
  final IconData icon;
  final String value;
  const _TxInfo({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppColors.textSecondary),
      const SizedBox(width: 3),
      Text(value,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
    ],
  );
}