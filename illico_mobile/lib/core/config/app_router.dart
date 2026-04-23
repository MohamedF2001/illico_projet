// ============================================================
//  ROUTEUR MOBILE — ILLICO DELIVERY
//  Gère uniquement les rôles : Client & Livreur
//  Utilise GoRouter avec redirection automatique selon le rôle
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ── Auth ────────────────────────────────────────────────────
import '../../features/auth/presentation/pages/client_auth_page.dart';
import '../../features/auth/presentation/pages/livreur_auth_page.dart';
import '../../features/auth/presentation/pages/role_selection_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/livraison/presentation/pages/client_home_page.dart';
import '../../features/livraison/presentation/pages/livraison_detail_page.dart';
import '../../features/livraison/presentation/pages/livraison_list_page.dart';
import '../../features/livreur/presentation/pages/missions_page.dart';
import '../../features/point_illico/presentation/pages/point_colis_page.dart';

// ─────────────────────────────────────────────────────────────
//  Provider principal du routeur mobile
//  Exposé sous le nom [mobileRouterProvider] pour être distinct
//  du routeur web si jamais les deux packages sont combinés.
// ─────────────────────────────────────────────────────────────
final mobileRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Démarre toujours sur le splash screen
    initialLocation: '/splash',

    // Le router se rafraîchit à chaque changement d'état auth
    refreshListenable: _RouterNotifier(ref),

    // ── Logique de redirection globale ───────────────────────
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isLoggedIn;
      final loc = state.matchedLocation;

      // Pages accessibles sans être connecté
      final isPublic = loc == '/splash' ||
          loc == '/role' ||
          loc == '/auth/client' ||
          loc == '/auth/livreur';

      // Non connecté → renvoie vers la sélection de rôle
      if (!isLoggedIn && !isPublic) return '/role';

      // Connecté sur une page publique → redirige vers la home
      if (isLoggedIn && (loc == '/role' || loc == '/auth/client' || loc == '/auth/livreur')) {
        return _homeForRole(authState.user?.role);
      }

      // Rôle Admin ou PointIllico sur l'app mobile → bloque
      final role = authState.user?.role;
      if (isLoggedIn && (role == 'Admin' || role == 'PointIllico')) {
        return '/role'; // Mauvaise application pour ce rôle
      }

      return null; // Pas de redirection nécessaire
    },

    // ── Définition des routes ────────────────────────────────
    routes: [

      // ── Écran de chargement initial ──────────────────────
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashPage(),
      ),

      // ── Sélection du rôle (Client ou Livreur) ─────────────
      // Premier écran affiché à tout utilisateur non connecté
      GoRoute(
        path: '/role',
        builder: (_, _) => const RoleSelectionPage(),
      ),

      // ── Authentification Client ────────────────────────────
      // Contient connexion (téléphone + PIN) et inscription en 3 étapes
      GoRoute(
        path: '/auth/client',
        builder: (_, _) => const ClientAuthPage(),
      ),

      // ── Authentification Livreur ───────────────────────────
      // Contient connexion (téléphone + mot de passe) et inscription
      GoRoute(
        path: '/auth/livreur',
        builder: (_, _) => const LivreurAuthPage(),
      ),

      // ════════════════════════════════════════════════════════
      //  ESPACE CLIENT
      // ════════════════════════════════════════════════════════

      // Page d'accueil client avec raccourcis et livraisons récentes
      GoRoute(
        path: '/home',
        builder: (_, _) => const ClientHomePage(),
      ),

      // Historique complet des livraisons avec filtres
      GoRoute(
        path: '/mes-livraisons',
        builder: (_, _) => const LivraisonsListPage(),
      ),

      // Nouvelle commande de livraison
      GoRoute(
        path: '/livraison/new',
        builder: (_, _) => const CreateLivraisonPlaceholderPage(),
      ),

      // Détail d'une livraison avec validation OTP et annulation
      GoRoute(
        path: '/livraison/:id',
        builder: (_, state) => LivraisonDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),

      // Page colis du client (colis en point ILLICO)
      GoRoute(
        path: '/colis',
        builder: (_, _) => const ColisClientPlaceholderPage(),
      ),

      // Forfaits et abonnements professionnels
      GoRoute(
        path: '/forfaits',
        builder: (_, _) => const ForfaitsPlaceholderPage(),
      ),

      // Profil du client
      GoRoute(
        path: '/profil',
        builder: (_, _) => const ProfilePlaceholderPage(),
      ),

      // ════════════════════════════════════════════════════════
      //  ESPACE LIVREUR
      // ════════════════════════════════════════════════════════

      // Tableau de bord des missions avec statut en ligne/hors ligne
      GoRoute(
        path: '/livreur/missions',
        builder: (_, _) => const MissionsPage(),
      ),

      // Détail d'une mission (même page que détail livraison)
      GoRoute(
        path: '/livreur/mission/:id',
        builder: (_, state) => LivraisonDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),

      // Gains, commissions et suivi du cash collecté
      GoRoute(
        path: '/livreur/gains',
        builder: (_, _) => const GainsPlaceholderPage(),
      ),

      // ════════════════════════════════════════════════════════
      //  POINT ILLICO (accès depuis l'app mobile si connecté
      //  en tant que PointIllico — rare mais possible)
      // ════════════════════════════════════════════════════════
      GoRoute(
        path: '/point/colis',
        builder: (_, _) => const PointColisPage(),
      ),
    ],

    // Gestion des routes introuvables
    errorBuilder: (_, state) => Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Route inconnue : ${state.matchedLocation}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
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
  'Client' => '/home',
  'Livreur' => '/livreur/missions',
  'PointIllico' => '/point/colis', // Normalement sur l'app web
  _ => '/role',
};

// ─────────────────────────────────────────────────────────────
//  Notifier pour rafraîchir le router quand l'auth change
// ─────────────────────────────────────────────────────────────
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    // Écoute les changements d'état d'authentification
    _ref.listen(authProvider, (_, _) => notifyListeners());
  }
}

// ─────────────────────────────────────────────────────────────
//  PAGES PLACEHOLDER
//  Pages en cours de développement — à remplacer par les
//  vraies implémentations au fur et à mesure.
// ─────────────────────────────────────────────────────────────

/// Widget de base pour les pages en construction
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const _PlaceholderPage({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: const Color(0xFFFF6B00)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle ?? 'Page en cours de développement',
            style: const TextStyle(color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

/// Page de création d'une nouvelle livraison
class CreateLivraisonPlaceholderPage extends StatelessWidget {
  const CreateLivraisonPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(
    title: 'Nouvelle livraison',
    icon: Icons.add_location_alt_outlined,
    subtitle: 'Sélectionnez votre point de départ et d\'arrivée',
  );
}

/// Page de liste des colis du client en point ILLICO
class ColisClientPlaceholderPage extends StatelessWidget {
  const ColisClientPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(
    title: 'Mes colis',
    icon: Icons.inventory_2_outlined,
    subtitle: 'Retrouvez vos colis disponibles en point ILLICO',
  );
}

/// Page des forfaits disponibles
class ForfaitsPlaceholderPage extends StatelessWidget {
  const ForfaitsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(
    title: 'Forfaits',
    icon: Icons.card_membership_outlined,
    subtitle: 'Abonnements professionnels avec réductions',
  );
}

/// Page de profil utilisateur
class ProfilePlaceholderPage extends StatelessWidget {
  const ProfilePlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(
    title: 'Mon profil',
    icon: Icons.person_outline,
  );
}

/// Page des gains du livreur
class GainsPlaceholderPage extends StatelessWidget {
  const GainsPlaceholderPage({super.key});
  @override
  Widget build(BuildContext context) => const _PlaceholderPage(
    title: 'Gains & Cash',
    icon: Icons.payments_outlined,
    subtitle: 'Suivi de vos commissions et cash collecté',
  );
}