import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/demo_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/statut_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/livreur_provider.dart';

class MissionsPage extends ConsumerWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state  = ref.watch(missionsProvider);
    final auth   = ref.watch(authProvider);
    final user   = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Missions'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Switch(
              value: state.statut == 'en_ligne',
              activeColor: AppColors.accent,
              onChanged: (_) => demoGuard(context, () => ref.read(missionsProvider.notifier).toggleStatut()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(missionsProvider.notifier).loadAll(),
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _HeaderCard(user: user, state: state)),
          state.isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              : state.missions.isEmpty
                  ? SliverFillRemaining(child: EmptyState(
                      title: state.statut == 'hors_ligne' ? 'Vous êtes hors ligne' : 'Aucune mission en cours',
                      subtitle: state.statut == 'hors_ligne' ? 'Activez votre statut pour recevoir des missions.' : 'En attente de nouvelles missions.',
                      icon: Icons.two_wheeler_outlined))
                  : SliverList(delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                          child: _MissionCard(mission: state.missions[i])),
                      childCount: state.missions.length)),
        ]),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final dynamic user;
  final MissionsState state;
  const _HeaderCard({this.user, required this.state});

  @override
  Widget build(BuildContext context) {
    final stats = state.stats;
    return Container(margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.secondary, Color(0xFF2D2D5E)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 28, backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(user?.nom.isNotEmpty == true ? user!.nom[0].toUpperCase() : 'L',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user?.nom ?? 'Livreur', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle,
                  color: state.statut == 'en_ligne' ? AppColors.accent : AppColors.textSecondary)),
              const SizedBox(width: 6),
              Text(Formatters.statutLabel(state.statut),
                  style: TextStyle(fontSize: 12, color: state.statut == 'en_ligne' ? AppColors.accent : AppColors.textSecondary)),
            ]),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
              child: Text('⭐ ${user?.scoreNote?.toStringAsFixed(1) ?? '5.0'}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white))),
        ]),
        if (stats != null) ...[
          const SizedBox(height: 20),
          Row(children: [
            _StatItem(label: 'Livraisons', value: '${stats['totalLivraisons'] ?? 0}'),
            _StatItem(label: 'Réussite', value: '${stats['tauxReussite'] ?? 0}%'),
            _StatItem(label: 'Revenus', value: Formatters.currency((stats['revenuTotal'] as num?)?.toDouble() ?? 0)),
          ]),
        ],
      ]),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
    Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
  ]));
}

class _MissionCard extends StatefulWidget {
  final Map<String, dynamic> mission;
  const _MissionCard({required this.mission});
  @override State<_MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<_MissionCard> {
  Timer? _timer;
  int _countdown = AppConfig.missionTimeoutSeconds;

  @override
  void initState() {
    super.initState();
    if (widget.mission['statut'] == 'affecté') {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_countdown <= 0) { t.cancel(); return; }
        setState(() => _countdown--);
      });
    }
  }

  @override void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = widget.mission;
    final statut = m['statut'] as String? ?? '';
    final isNew = statut == 'affecté';
    final depart = (m['pointDepart'] as Map?)?['adresse'] as String? ?? '-';
    final arrivee = (m['pointArrivee'] as Map?)?['adresse'] as String? ?? '-';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
          side: isNew ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none),
      child: InkWell(
        onTap: () => context.go('/livraison/${m['_id']}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            StatutBadge(statut: statut),
            if (isNew) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('⏱ $_countdown s', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger))),
          ]),
          const SizedBox(height: 12),
          _RouteRow(depart: depart, arrivee: arrivee),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(Formatters.currency((m['prixEstime'] as num?)?.toDouble() ?? 0),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
            Text('Voir détails →', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
          ]),
        ])),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String depart, arrivee;
  const _RouteRow({required this.depart, required this.arrivee});
  @override Widget build(BuildContext context) => Row(children: [
    Column(children: [
      const Icon(Icons.my_location, size: 14, color: AppColors.accent),
      Container(width: 2, height: 20, color: AppColors.divider),
      const Icon(Icons.location_on, size: 14, color: AppColors.primary),
    ]),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(depart, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 14),
      Text(arrivee, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
    ])),
  ]);
}
