import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_theme.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/formatters.dart';
import '../../../colis/presentation/providers/colis_provider.dart';
import '../../../livraison/presentation/providers/livraison_provider.dart';
import '../../../livreur/presentation/providers/livreur_provider.dart';
import '../../../transaction/presentation/providers/transaction_provider.dart';
import '../../../point_illico/presentation/providers/point_illico_provider.dart';

final _dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // On utilise apiClient.dio directement pour avoir un contrôle total et éviter les erreurs de middleware Client
  // On enveloppe chaque appel pour éviter que le dashboard ne crash si un endpoint échoue (ex: 500 sur /colis/admin)
  final results = await Future.wait([
    apiClient.dio.get('/transactions/admin/stats').catchError((e) {
      debugPrint('Error fetching tx stats: $e');
      return Response(data: {'data': {}}, requestOptions: RequestOptions());
    }),
    apiClient.dio.get('/livreurs').catchError((e) {
      debugPrint('Error fetching livreurs: $e');
      return Response(data: {'data': []}, requestOptions: RequestOptions());
    }),
    apiClient.dio.get('/points').catchError((e) {
      debugPrint('Error fetching points: $e');
      return Response(data: {'data': []}, requestOptions: RequestOptions());
    }),
    apiClient.dio.get('/colis/admin').catchError((e) {
      debugPrint('Error fetching colis: $e');
      return Response(data: {'data': []}, requestOptions: RequestOptions());
    }),
    apiClient.dio.get('/livraisons').catchError((e) {
      debugPrint('Error fetching livraisons: $e');
      return Response(data: {'data': []}, requestOptions: RequestOptions());
    }),
  ]);

  final txStats = (results[0].data?['data'] as Map<String, dynamic>?) ?? {};
  final livreurs = (results[1].data?['data'] as List?) ?? [];
  final points = (results[2].data?['data'] as List?) ?? [];
  final colis = (results[3].data?['data'] as List?) ?? [];
  final livraisons = (results[4].data?['data'] as List?) ?? [];

  // Calcul manuel des revenus si les stats admin échouent
  double totalRevenus = (txStats['revenusTotal'] as num?)?.toDouble() ?? 0;
  double moisRevenus = (txStats['revenusMois'] as num?)?.toDouble() ?? 0;

  if (totalRevenus == 0) {
    for (final l in livraisons) {
      if (['livré', 'termine', 'livre'].contains(l['statut'])) {
        totalRevenus += (l['prixEstime'] as num?)?.toDouble() ?? 0;
      }
    }
  }

  final totalLiv = (txStats['totalLivraisons'] as num?)?.toInt() ?? livraisons.length;
  final livrees = (txStats['livraisonsTerminees'] as num?)?.toInt() ?? livraisons.where((l) => ['livré', 'termine', 'livre'].contains(l['statut'])).length;

  return {
    'revenus': {
      'mois': moisRevenus,
      'total': totalRevenus
    },
    'livraisons': {
      'total': totalLiv,
      'enCours': (txStats['livraisonsEnCours'] as num?)?.toInt() ?? livraisons.where((l) => !['livré', 'annulé', 'termine', 'livre', 'annule'].contains(l['statut'])).length,
      'tauxReussite': (txStats['tauxReussite'] as num?)?.toInt() ?? (totalLiv > 0 ? (livrees / totalLiv * 100).round() : 0),
      'livrees': livrees
    },
    'utilisateurs': {
      'clients': (txStats['totalClients'] as num?)?.toInt() ?? livraisons.map((l) => l['clientId']).toSet().length,
      'livreurs': livreurs.length,
      'points': points.length,
    },
    'livreurs': {
      'enLigne': livreurs.where((l) => (l as Map)['statut'] == 'en_ligne').length,
      'enMission': livreurs.where((l) => (l as Map)['statut'] == 'en_mission').length,
    },
    'colis': {
      'enAttente': colis.where((c) => ['en_attente', 'receptionné', 'reçu'].contains((c as Map)['statut'])).length,
      'enRetard': 0,
    }
  };
});

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiAsync = ref.watch(_dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(livraisonListProvider.notifier).load();
              ref.read(livreurListProvider.notifier).load();
              ref.read(transactionListProvider.notifier).load();
              ref.read(colisListProvider.notifier).load();
              ref.read(pointIllicoListProvider.notifier).load();
            },
          ),
        ],
      ),
      body: kpiAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Erreur: ${e is Failure ? e.displayMessage : e}',
                style: const TextStyle(color: AppColors.danger),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(livraisonListProvider.notifier).load();
                  ref.read(livreurListProvider.notifier).load();
                  ref.read(transactionListProvider.notifier).load();
                  ref.read(colisListProvider.notifier).load();
                  ref.read(pointIllicoListProvider.notifier).load();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Données du mois en cours',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              // Revenus
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revenus du mois',
                      style: TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.currency(
                        (data['revenus']?['mois'] as num?)?.toDouble() ?? 0,
                      ),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${Formatters.currency((data['revenus']?['total'] as num?)?.toDouble() ?? 0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _KpiCard(
                    title: 'Livraisons',
                    value: '${data['livraisons']?['total'] ?? 0}',
                    sub: 'En cours: ${data['livraisons']?['enCours'] ?? 0}',
                    color: AppColors.info,
                    icon: Icons.local_shipping_rounded,
                  ),
                  _KpiCard(
                    title: 'Taux réussite',
                    value: '${data['livraisons']?['tauxReussite'] ?? 0}%',
                    sub: 'Livrées: ${data['livraisons']?['livrees'] ?? 0}',
                    color: AppColors.accent,
                    icon: Icons.check_circle_rounded,
                  ),
                  _KpiCard(
                    title: 'Clients',
                    value: '${data['utilisateurs']?['clients'] ?? 0}',
                    sub: 'Points: ${data['utilisateurs']?['points'] ?? 0}',
                    color: AppColors.warning,
                    icon: Icons.people_rounded,
                  ),
                  _KpiCard(
                    title: 'Livreurs',
                    value: '${data['livreurs']?['enLigne'] ?? 0} en ligne',
                    sub: 'En mission: ${data['livreurs']?['enMission'] ?? 0}',
                    color: AppColors.primary,
                    icon: Icons.two_wheeler_rounded,
                  ),
                  _KpiCard(
                    title: 'Colis',
                    value: '${data['colis']?['enAttente'] ?? 0} en attente',
                    sub: 'En retard: ${data['colis']?['enRetard'] ?? 0}',
                    color: AppColors.danger,
                    icon: Icons.inventory_2_rounded,
                  ),
                  _KpiCard(
                    title: 'Total livreurs',
                    value: '${data['utilisateurs']?['livreurs'] ?? 0}',
                    sub: 'Enregistrés',
                    color: AppColors.secondary,
                    icon: Icons.badge_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title, value, sub;
  final Color color;
  final IconData icon;
  const _KpiCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}
