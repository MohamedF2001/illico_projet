import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_display.dart';
import '../../../../core/widgets/statut_badge.dart';
import '../providers/livraison_provider.dart';
import '../../domain/entities/livraison_entity.dart';

class LivraisonsListPage extends ConsumerStatefulWidget {
  const LivraisonsListPage({super.key});
  @override ConsumerState<LivraisonsListPage> createState() => _LivraisonsListPageState();
}

class _LivraisonsListPageState extends ConsumerState<LivraisonsListPage> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(livraisonListProvider);
    final filtered = _filter == 'all' ? state.items
        : state.items.where((l) => l.statut == _filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes livraisons'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(livraisonListProvider.notifier).load())],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/livraison/new'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Commander', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        _FilterBar(selected: _filter, onSelected: (v) => setState(() => _filter = v)),
        Expanded(child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? ErrorDisplay(failure: state.error!, onRetry: () => ref.read(livraisonListProvider.notifier).load())
                : filtered.isEmpty
                    ? const EmptyState(title: 'Aucune livraison', subtitle: 'Vos livraisons apparaîtront ici.', icon: Icons.inventory_2_outlined)
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) => _LivraisonCard(livraison: filtered[i]),
                      )),
      ]),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _FilterBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final filters = {'all': 'Tout', 'en_attente': 'En attente', 'livré': 'Livrés', 'annulé': 'Annulés'};
    return SizedBox(height: 48,
      child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filters.entries.map((e) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(e.value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: selected == e.key ? Colors.white : AppColors.textSecondary)),
            selected: selected == e.key,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            onSelected: (_) => onSelected(e.key),
          ),
        )).toList()),
    );
  }
}

class _LivraisonCard extends StatelessWidget {
  final LivraisonEntity livraison;
  const _LivraisonCard({required this.livraison});

  String get _clientNom {
    final c = livraison.client;
    if (c is Map) return c['nom'] as String? ?? '-';
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.go('/livraison/${livraison.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Livraison #${livraison.id?.substring(livraison.id!.length - 6) ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(livraison.dateCreation != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(livraison.dateCreation!)
                    : '-',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              StatutBadge(statut: livraison.statut),
            ]),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _RouteRow(depart: livraison.pointDepart.adresse, arrivee: livraison.pointArrivee.adresse),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(Formatters.currency(livraison.prixFinal ?? livraison.prixEstime),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
              Text(livraison.mode == 'express' ? '⚡ Express' : '🏪 Point ILLICO',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final String depart;
  final String arrivee;
  const _RouteRow({required this.depart, required this.arrivee});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Column(children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
        Container(width: 2, height: 24, color: AppColors.divider),
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
      ]),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(depart, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),
        Text(arrivee, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }
}
