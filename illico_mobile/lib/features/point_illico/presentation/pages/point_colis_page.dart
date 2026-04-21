import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/demo_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/statut_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/point_illico_remote_datasource.dart';
import '../../../../core/api/api_client.dart';
import '../providers/point_illico_provider.dart';

class PointColisPage extends ConsumerStatefulWidget {
  const PointColisPage({super.key});
  @override
  ConsumerState<PointColisPage> createState() => _PointColisPageState();
}

class _PointColisPageState extends ConsumerState<PointColisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  final _filters = ['Tous', 'en_attente', 'receptionné', 'retiré'];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(colisPointProvider);
    final user = ref.watch(authProvider).user;
    final stats = state.stats;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mes Colis'),
            Text(
              user?.nom ?? '',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: 'Réceptionner',
            onPressed: () => _showReceptionDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(colisPointProvider.notifier).loadAll(),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: _filters
              .map(
                (f) =>
                    Tab(text: f == 'Tous' ? 'Tous' : Formatters.statutLabel(f)),
              )
              .toList(),
        ),
      ),
      body: Column(
        children: [
          if (stats != null) _StatsBar(stats: stats),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: _filters.map((f) {
                final items = f == 'Tous'
                    ? state.items
                    : state.items.where((c) => c['statut'] == f).toList();
                if (state.isLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state.error != null)
                  return ErrorDisplay(
                    failure: state.error!,
                    onRetry: () =>
                        ref.read(colisPointProvider.notifier).loadAll(),
                  );
                if (items.isEmpty)
                  return const EmptyState(
                    title: 'Aucun colis',
                    icon: Icons.inventory_2_outlined,
                  );
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) => _ColisCard(
                    colis: items[i],
                    onAction: () =>
                        ref.read(colisPointProvider.notifier).loadAll(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showReceptionDialog(BuildContext context) {
    final livraisonCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Réceptionner un colis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: livraisonCtrl,
              decoration: const InputDecoration(labelText: 'ID Livraison'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP de retrait',
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              demoGuard(context, () async {
                Navigator.pop(context);
                final ds = PointIllicoRemoteDataSource(apiClient);
                final r = await ds.receiveColis(
                  livraisonCtrl.text.trim(),
                  otpCtrl.text.trim(),
                );
                if (mounted) {
                  r.fold(
                    (f) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(f.displayMessage),
                        backgroundColor: AppColors.danger,
                      ),
                    ),
                    (_) {
                      ref.read(colisPointProvider.notifier).loadAll();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Colis réceptionné ✅'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                    },
                  );
                }
              });
            },
            child: const Text('Réceptionner'),
          ),
        ],
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsBar({required this.stats});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: AppColors.cardBg,
      border: Border(bottom: BorderSide(color: AppColors.divider)),
    ),
    child: Row(
      children: [
        _Stat('Total', '${stats['totalColis'] ?? 0}', AppColors.primary),
        _Stat('Retirés', '${stats['colisRetires'] ?? 0}', AppColors.accent),
        _Stat(
          'Commission',
          Formatters.currency(
            (stats['commissionTotale'] as num?)?.toDouble() ?? 0,
          ),
          AppColors.warning,
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    ),
  );
}

class _ColisCard extends StatelessWidget {
  final Map<String, dynamic> colis;
  final VoidCallback onAction;
  const _ColisCard({required this.colis, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final statut = colis['statut'] as String? ?? '';
    final frais = (colis['fraisStockageActuel'] as num?)?.toDouble() ?? 0;
    final ref = colis['reference'] as String? ?? '-';
    final limite = colis['dateLimiteGratuite'] != null
        ? DateTime.tryParse(colis['dateLimiteGratuite'] as String)
        : null;
    final isRetard = limite != null && DateTime.now().isAfter(limite);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isRetard
            ? const BorderSide(color: AppColors.warning, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ref,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                ),
                StatutBadge(statut: statut),
              ],
            ),
            if (limite != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    isRetard ? Icons.warning_amber : Icons.timer_outlined,
                    size: 14,
                    color: isRetard
                        ? AppColors.warning
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isRetard
                        ? 'En retard — ${Formatters.currency(frais)}'
                        : 'Limite: ${Formatters.dateTime(limite)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isRetard
                          ? AppColors.warning
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            if (statut == 'receptionné') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => _showRetraitDialog(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Valider retrait',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRetraitDialog(BuildContext context) {
    final otpCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Valider le retrait'),
        content: TextField(
          controller: otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'OTP du client',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              demoGuard(context, () async {
                Navigator.pop(context);
                final ds = PointIllicoRemoteDataSource(apiClient);
                final r = await ds.retrieveColis(
                  colis['_id'] as String,
                  otpCtrl.text.trim(),
                );
                if (context.mounted)
                  r.fold(
                    (f) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(f.displayMessage),
                        backgroundColor: AppColors.danger,
                      ),
                    ),
                    (_) {
                      onAction();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Retrait validé ✅'),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                    },
                  );
              });
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}
