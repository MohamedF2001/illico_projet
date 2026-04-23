// ============================================================
//  ROUTEUR WEB — ILLICO DELIVERY
//  Gère uniquement les rôles : Admin & Point ILLICO
//  Layout Admin : Sidebar + contenu (ShellRoute)
//  Layout Point ILLICO : Interface simplifiée gestion colis
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Auth ────────────────────────────────────────────────────
import '../../features/auth/presentation/pages/admin_auth_page.dart';
import '../../features/auth/presentation/pages/point_auth_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/web_landing_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// ── Admin (ShellRoute avec sidebar) ─────────────────────────
import '../../features/admin/presentation/widgets/admin_shell.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_livraisons_page.dart';
import '../../features/admin/presentation/pages/admin_livreurs_page.dart';
import '../../features/admin/presentation/pages/admin_points_page.dart';
import '../../features/admin/presentation/pages/admin_colis_page.dart';
import '../../features/admin/presentation/pages/admin_zones_page.dart';
import '../../features/admin/presentation/pages/admin_tarifs_page.dart';
import '../../features/admin/presentation/pages/admin_transactions_page.dart';
import '../../features/admin/presentation/pages/admin_forfaits_page.dart';
import '../../features/vehicule/presentation/pages/vehicule_list_page.dart';

// ── Point ILLICO ─────────────────────────────────────────────
import '../../features/point_illico/presentation/pages/point_colis_page.dart';

// ─────────────────────────────────────────────────────────────
//  Provider principal du routeur web
//  Nommé [webRouterProvider] pour éviter tout conflit avec
//  le provider mobile si les packages sont combinés.
// ─────────────────────────────────────────────────────────────
final webRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Démarre toujours sur le splash screen
    initialLocation: '/splash',

    // Se rafraîchit à chaque changement d'état auth
    refreshListenable: _RouterNotifier(ref),

    // ── Logique de redirection globale ───────────────────────
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isLoggedIn;
      final loc = state.matchedLocation;

      // Pages accessibles sans authentification
      final isPublic = loc == '/splash' ||
          loc == '/' ||
          loc == '/auth/admin' ||
          loc == '/auth/point';

      // Non connecté → page d'accueil du portail
      if (!isLoggedIn && !isPublic) return '/';

      // Connecté sur une page publique → redirige vers home du rôle
      if (isLoggedIn && isPublic && loc != '/splash') {
        return _homeForRole(authState.user?.role);
      }

      // Bloque les rôles Client et Livreur sur l'app web
      final role = authState.user?.role;
      if (isLoggedIn && (role == 'Client' || role == 'Livreur')) {
        return '/'; // Mauvaise application pour ce rôle
      }

      return null; // Pas de redirection nécessaire
    },

    // ── Définition des routes ────────────────────────────────
    routes: [

      // ── Écran de chargement initial ───────────────────────
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashPage(),
      ),

      // ── Page d'accueil du portail professionnel ────────────
      // Choix entre Admin et Point ILLICO
      GoRoute(
        path: '/',
        builder: (_, _) => const WebLandingPage(),
      ),

      // ── Connexion Admin ────────────────────────────────────
      // Email + mot de passe, interface desktop
      GoRoute(
        path: '/auth/admin',
        builder: (_, _) => const AdminAuthPage(),
      ),

      // ── Connexion Point ILLICO ─────────────────────────────
      // Téléphone + mot de passe + inscription point
      GoRoute(
        path: '/auth/point',
        builder: (_, _) => const PointAuthPage(),
      ),

      // ── Page colis Point ILLICO ────────────────────────────
      // Interface de gestion des colis sans sidebar admin
      GoRoute(
        path: '/point/colis',
        builder: (_, _) => const PointColisPage(),
      ),

      // ════════════════════════════════════════════════════════
      //  ESPACE ADMIN — Shell avec sidebar de navigation
      //  Toutes les routes /admin/* sont imbriquées dans le Shell
      //  qui affiche la sidebar latérale persistante.
      // ════════════════════════════════════════════════════════
      ShellRoute(
        // Le Shell encapsule chaque page admin avec la sidebar
        builder: (context, state, child) => AdminShell(child: child),
        routes: [

          // Tableau de bord KPI (revenus, livraisons, livreurs...)
          GoRoute(
            path: '/admin/dashboard',
            builder: (_, _) => const AdminDashboardPage(),
          ),

          // Liste et suivi de toutes les livraisons
          GoRoute(
            path: '/admin/livraisons',
            builder: (_, _) => const AdminLivraisonsPage(),
          ),

          // Gestion des livreurs (validation, suspension, cash)
          GoRoute(
            path: '/admin/livreurs',
            builder: (_, _) => const AdminLivreursPage(),
          ),

          // Activation/désactivation des Points ILLICO
          GoRoute(
            path: '/admin/points',
            builder: (_, _) => const AdminPointsPage(),
          ),

          // Alertes colis en retard (>48h, >7j)
          GoRoute(
            path: '/admin/colis',
            builder: (_, _) => const AdminColisPage(),
          ),

          // CRUD des types de véhicules et leurs tarifs de base
          GoRoute(
            path: '/admin/vehicules',
            builder: (_, _) => const AdminVehiculesPage(),
          ),

          // Gestion des zones géographiques avec suppléments
          GoRoute(
            path: '/admin/zones',
            builder: (_, _) => const AdminZonesPage(),
          ),

          // Grilles tarifaires par véhicule et zone
          GoRoute(
            path: '/admin/tarifs',
            builder: (_, _) => const AdminTarifsPage(),
          ),

          // Historique des transactions financières
          GoRoute(
            path: '/admin/transactions',
            builder: (_, _) => const AdminTransactionsPage(),
          ),

          // Gestion des forfaits clients professionnels
          GoRoute(
            path: '/admin/forfaits',
            builder: (_, _) => const AdminForfaitsPage(),
          ),
        ],
      ),
    ],

    // Gestion des routes introuvables
    errorBuilder: (_, state) => Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Color(0xFFFF3B30)),
            const SizedBox(height: 20),
            const Text(
              'Page introuvable',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => state.namedLocation('/'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});

// ─────────────────────────────────────────────────────────────
//  Utilitaire : détermine la page d'accueil selon le rôle
// ─────────────────────────────────────────────────────────────
String _homeForRole(String? role) => switch (role) {
  'Admin' => '/admin/dashboard',
  'PointIllico' => '/point/colis',
  _ => '/', // Rôle inconnu → portail de sélection
};

// ─────────────────────────────────────────────────────────────
//  Notifier pour rafraîchir le router quand l'auth change
// ─────────────────────────────────────────────────────────────
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    // Se déclenche à chaque changement de l'état auth
    _ref.listen(authProvider, (_, _) => notifyListeners());
  }
}