import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../colis/presentation/providers/colis_provider.dart';

/// Page admin des colis.
/// L'API ne fournit PAS de endpoint POST /colis pour l'admin.
/// Les colis sont créés automatiquement lors de la réception
/// par un Point ILLICO via POST /points/colis/reception.
/// Cette page permet uniquement de :
///  - Consulter la liste des colis (GET /colis)
///  - Mettre à jour le statut (PUT /colis/:id/statut)
///  - Consulter les alertes (GET /colis/admin/alertes)
class AdminColisPage extends ConsumerStatefulWidget {
  const AdminColisPage({super.key});

  @override
  ConsumerState<AdminColisPage> createState() => _AdminColisPageState();
}

class _AdminColisPageState extends ConsumerState<AdminColisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(colisListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Colis & Alertes'),
            Text(
              '${state.items.length} colis',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.accent),
            tooltip: 'Actualiser',
            onPressed: () =>
                ref.read(colisListProvider.notifier).load(),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Tous les colis'),
            Tab(text: '⚠️ Alertes retard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Onglet 1 : Liste des colis ──────────────────
          _ColisListTab(state: state, ref: ref),
          // ── Onglet 2 : Alertes retard ───────────────────
          const _AlertesTab(),
        ],
      ),
    );
  }
}

// ── Liste des colis ─────────────────────────────────────────
class _ColisListTab extends StatelessWidget {
  final ColisListState state;
  final WidgetRef ref;
  const _ColisListTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return ErrorDisplay(
        failure: state.error!,
        onRetry: () => ref.read(colisListProvider.notifier).load(),
      );
    }
    if (state.items.isEmpty) {
      return const EmptyState(
        title: 'Aucun colis',
        subtitle:
        'Les colis apparaissent après réception dans un Point ILLICO.',
        icon: Icons.inventory_2_outlined,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final colis = state.items[i];
        final statut = colis['statut'] as String? ?? 'en_attente';
        final reference = colis['reference'] as String? ?? '-';
        final limite = colis['dateLimiteGratuite'] != null
            ? DateTime.tryParse(colis['dateLimiteGratuite'] as String)
            : null;
        final isRetard =
            limite != null && DateTime.now().isAfter(limite);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isRetard
                ? const BorderSide(
                color: AppColors.warning, width: 1.5)
                : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _statutColor(statut).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          color: _statutColor(statut), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reference,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                fontFamily: 'monospace'),
                          ),
                          // Point ILLICO
                          if (colis['pointIllico'] is Map)
                            Text(
                              (colis['pointIllico'] as Map)['nom'] ??
                                  '-',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                        ],
                      ),
                    ),
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                        _statutColor(statut).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        Formatters.statutLabel(statut).toUpperCase(),
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _statutColor(statut)),
                      ),
                    ),
                  ],
                ),
                if (limite != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        isRetard
                            ? Icons.warning_amber
                            : Icons.timer_outlined,
                        size: 13,
                        color: isRetard
                            ? AppColors.warning
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRetard
                            ? 'En retard — limite: ${Formatters.dateTime(limite)}'
                            : 'Limite gratuite: ${Formatters.dateTime(limite)}',
                        style: TextStyle(
                            fontSize: 11,
                            color: isRetard
                                ? AppColors.warning
                                : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
                // Frais stockage
                if ((colis['fraisStockage'] as num? ?? 0) > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Frais: ${Formatters.currency((colis['fraisStockage'] as num).toDouble())}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statutColor(String statut) => switch (statut) {
    'retiré' => AppColors.accent,
    'receptionné' => AppColors.info,
    'retourné' => AppColors.danger,
    'en_attente' => AppColors.warning,
    _ => AppColors.textSecondary,
  };
}

// ── Onglet alertes retard ───────────────────────────────────
class _AlertesTab extends StatefulWidget {
  const _AlertesTab();

  @override
  State<_AlertesTab> createState() => _AlertesTabState();
}

class _AlertesTabState extends State<_AlertesTab> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _alertes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await apiClient.dio.get('/colis/admin/alertes');
      setState(() {
        _alertes = r.data['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les alertes.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.danger, size: 40),
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: AppColors.danger)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final a48h =
        (_alertes?['aRetirer48h'] as List?) ?? [];
    final a7j = (_alertes?['aRetirer7j'] as List?) ?? [];
    final enRetard = (_alertes?['enRetard'] as List?) ?? [];

    final total = a48h.length + a7j.length + enRetard.length;

    if (total == 0) {
      return const EmptyState(
        title: 'Aucune alerte',
        subtitle: 'Tous les colis sont dans les délais.',
        icon: Icons.check_circle_outline,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Résumé ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber,
                  color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$total colis nécessitent une action',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.warning),
                    ),
                    Text(
                      'Contactez les clients pour planifier le retrait.',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppColors.warning),
                onPressed: _load,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Section < 48h ────────────────────────────────
        if (a48h.isNotEmpty) ...[
          _AlertSection(
            title: '⏰ À retirer sous 48h (${a48h.length})',
            color: AppColors.warning,
            colis: a48h.cast<Map<String, dynamic>>(),
          ),
          const SizedBox(height: 16),
        ],

        // ── Section 48h – 7j ─────────────────────────────
        if (a7j.isNotEmpty) ...[
          _AlertSection(
            title: '📦 En retard > 48h (${a7j.length})',
            color: AppColors.danger,
            colis: a7j.cast<Map<String, dynamic>>(),
          ),
          const SizedBox(height: 16),
        ],

        // ── Section > 7j ─────────────────────────────────
        if (enRetard.isNotEmpty) ...[
          _AlertSection(
            title: '🚨 Critique > 7 jours (${enRetard.length})',
            color: const Color(0xFF7C0000),
            colis: enRetard.cast<Map<String, dynamic>>(),
          ),
        ],
      ],
    );
  }
}

class _AlertSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<Map<String, dynamic>> colis;
  const _AlertSection(
      {required this.title,
        required this.color,
        required this.colis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: color,
                fontSize: 13)),
        const SizedBox(height: 8),
        ...colis.map((c) {
          final ref = c['reference'] as String? ?? '-';
          final point = c['pointIllico'] is Map
              ? (c['pointIllico'] as Map)['nom'] as String? ?? '-'
              : '-';
          final limite = c['dateLimiteGratuite'] != null
              ? DateTime.tryParse(c['dateLimiteGratuite'] as String)
              : null;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ref,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: color)),
                      Text(point,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (limite != null)
                  Text(
                    Formatters.dateTime(limite),
                    style: TextStyle(fontSize: 11, color: color),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}