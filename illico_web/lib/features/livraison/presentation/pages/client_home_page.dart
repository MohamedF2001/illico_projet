import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/statut_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/data/datasources/notification_remote_datasource.dart';
import '../../../../core/api/api_client.dart';
import '../providers/livraison_provider.dart';

class ClientHomePage extends ConsumerWidget {
  const ClientHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth   = ref.watch(authProvider);
    final state  = ref.watch(livraisonListProvider);
    final user   = auth.user;
    final recent = state.items.take(3).toList();

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: AppColors.secondary,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.secondary, Color(0xFF16213E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Bonjour, ${user?.nom.split(' ').first ?? 'Client'} 👋',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Text('Que livrons-nous aujourd\'hui ?',
                          style: TextStyle(fontSize: 14, color: Colors.white70)),
                    ]),
                    Stack(children: [
                      IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28), onPressed: () {}),
                      Positioned(top: 8, right: 8, child: Container(width: 10, height: 10,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))),
                    ]),
                  ]),
                  const SizedBox(height: 12),
                  if (user?.soldeIllico != null)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text('Solde: ${Formatters.currency(user!.soldeIllico!)}',
                          style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600))),
                ],
              ))),
            ),
          ),
        ),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Commander ──────────────────────────────
            GestureDetector(
              onTap: () => context.go('/livraison/new'),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Commander une livraison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 4),
                    Text('Livré. Maintenant.', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  ]),
                  Icon(Icons.local_shipping_rounded, size: 48, color: Colors.white),
                ]),
              ),
            ),
            const SizedBox(height: 24),
            // ── Accès rapides ──────────────────────────
            Row(children: [
              _QuickAction(icon: Icons.history, label: 'Historique', color: AppColors.info, onTap: () => context.go('/mes-livraisons')),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.inventory_2_outlined, label: 'Mes colis', color: AppColors.accent, onTap: () => context.go('/colis')),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.card_membership, label: 'Forfaits', color: AppColors.warning, onTap: () => context.go('/forfaits')),
            ]),
            const SizedBox(height: 28),
            // ── Livraisons récentes ────────────────────
            const Text('Livraisons récentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (recent.isEmpty)
              Container(padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                child: const Row(children: [
                  Icon(Icons.inbox_outlined, color: AppColors.textSecondary),
                  SizedBox(width: 12),
                  Text('Aucune livraison pour l\'instant.', style: TextStyle(color: AppColors.textSecondary)),
                ]))
            else
              ...recent.map((l) {
                final statut = l.statut;
                return Container(margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.pointArrivee.adresse, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(Formatters.dateTime(l.dateCreation), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ])),
                    const SizedBox(width: 8),
                    StatutBadge(statut: statut),
                  ]),
                );
              }),
          ],
        ))),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2))),
        child: Column(children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ])),
    ),
  );
}
