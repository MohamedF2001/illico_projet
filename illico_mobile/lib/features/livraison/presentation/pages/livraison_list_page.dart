/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/livraison_provider.dart';

class LivraisonsListPage extends ConsumerStatefulWidget {
  const LivraisonsListPage({super.key});

  @override
  ConsumerState<LivraisonsListPage> createState() => _LivraisonsListPageState();
}

class _LivraisonsListPageState extends ConsumerState<LivraisonsListPage> {
  String? _selectedStatut;

  final Map<String, String> _statuts = {
    'Tous': 'tous',
    'En attente': 'en_attente',
    'Affecté': 'affecté',
    'Livré': 'livré',
    'Annulé': 'annulé',
  };

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(livraisonListProvider);
    var livraisons = state.items;

    if (_selectedStatut != null && _selectedStatut != 'tous') {
      livraisons = livraisons.where((l) => l.statut == _selectedStatut).toList();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'ILLICO',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historiques',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${livraisons.length} colis',
                  style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // FILTRES DE STATUT
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: _statuts.entries.map((e) {
                final isSelected = (_selectedStatut == null && e.value == 'tous') || _selectedStatut == e.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatut = e.value),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFFF1F1F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      e.key,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: state.isLoading && livraisons.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => ref.read(livraisonListProvider.notifier).load(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: livraisons.length,
                      itemBuilder: (context, index) {
                        final l = livraisons[index];
                        return _HistoryItem(
                          title: 'Colis personnel',
                          subtitle: '${Formatters.date(l.dateCreation)} . ${l.pointArrivee.adresse}',
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HistoryItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/livraison_provider.dart';
import '../../domain/entities/livraison_entity.dart';

class LivraisonsListPage extends ConsumerWidget {
  const LivraisonsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(livraisonListProvider);
    final livraisons = state.items;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E5E5),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'ILLICO',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'Historiques',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: state.isLoading && livraisons.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : livraisons.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune livraison',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vos livraisons apparaîtront ici',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () => ref.read(livraisonListProvider.notifier).load(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: livraisons.length,
                itemBuilder: (context, index) {
                  return _HistoryItem(livraison: livraisons[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final LivraisonEntity livraison;

  const _HistoryItem({required this.livraison});

  Color get _statutColor => switch (livraison.statut) {
    'livré' || 'retiré' => AppColors.accent,
    'affecté' || 'arrivé_pickup' || 'colis_récupéré' || 'receptionné' => AppColors.info,
    'annulé' || 'échoué' || 'retourné' => AppColors.danger,
    'en_attente' => AppColors.warning,
    _ => AppColors.primary,
  };

  IconData get _statutIcon => switch (livraison.statut) {
    'livré' || 'retiré' => Icons.check_circle_rounded,
    'affecté' || 'arrivé_pickup' || 'colis_récupéré' => Icons.local_shipping_rounded,
    'annulé' || 'échoué' || 'retourné' => Icons.cancel_rounded,
    'en_attente' => Icons.hourglass_empty_rounded,
    'receptionné' => Icons.store_rounded,
    _ => Icons.inventory_2_rounded,
  };

  bool get _peutAnnuler => livraison.statut == 'en_attente';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/livraison/${livraison.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(20),
          border: _peutAnnuler
              ? Border.all(color: AppColors.warning.withOpacity(0.4), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Icône statut
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _statutColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_statutIcon, color: _statutColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          livraison.natureColis ?? 'Colis personnel',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Badge "Annulable" si en attente
                      if (_peutAnnuler)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Annulable',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Formatters.date(livraison.dateCreation)} · ${livraison.pointArrivee.adresse}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      // Badge statut
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statutColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          Formatters.statutLabel(livraison.statut),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _statutColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Prix
                      Text(
                        Formatters.currency(livraison.prixFinal ?? livraison.prixEstime),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Flèche de navigation
            const Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }
}

