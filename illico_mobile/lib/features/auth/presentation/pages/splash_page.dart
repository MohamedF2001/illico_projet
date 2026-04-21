// ============================================================
//  SPLASH PAGE — Application Mobile
//  Écran de démarrage avec animation fade-in.
//  Redirige automatiquement vers :
//   - La sélection de rôle si non connecté
//   - La page d'accueil du rôle si déjà connecté
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  // Contrôleur pour l'animation de fondu
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Animation de fondu sur 800ms avec une courbe easeIn
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    // Navigation automatique après 2 secondes
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  /// Redirige selon l'état d'authentification actuel.
  void _navigate() {
    if (!mounted) return;
    final auth = ref.read(authProvider);

    if (auth.isLoggedIn) {
      // Connecté → va directement à la page d'accueil du rôle
      context.go(_homeForRole(auth.user?.role));
    } else {
      // Non connecté → sélection du rôle (Client ou Livreur)
      context.go('/role');
    }
  }

  /// Retourne la route d'accueil selon le rôle de l'utilisateur.
  String _homeForRole(String? role) => switch (role) {
    'Client' => '/home',
    'Livreur' => '/livreur/missions',
    'PointIllico' => '/point/colis',
    _ => '/role',
  };

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary, // Fond sombre ILLICO

      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo ────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // ── Nom de l'application ─────────────────────
              const Text(
                'ILLICO',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),

              const Text(
                'DELIVERY',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: AppColors.primary,
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: 8),

              // ── Slogan ───────────────────────────────────
              Text(
                'Livré. Maintenant.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 60),

              // ── Indicateur de chargement ─────────────────
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}