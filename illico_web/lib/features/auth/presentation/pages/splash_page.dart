// ============================================================
//  SPLASH PAGE — Application Web
//  Écran de démarrage identique visuellement à la version mobile.
//  Redirige vers :
//   - Le portail de sélection si non connecté
//   - Le dashboard admin ou la page colis point ILLICO si connecté
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/config/app_theme.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // Animation de fondu au démarrage
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    // Redirection après 2 secondes
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  /// Redirige vers la bonne destination selon l'état d'auth.
  void _navigate() {
    if (!mounted) return;
    final auth = ref.read(authProvider);

    if (auth.isLoggedIn) {
      // Utilisateur déjà connecté → aller directement à son espace
      context.go(_homeForRole(auth.user?.role));
    } else {
      // Pas connecté → portail de sélection Admin / Point ILLICO
      context.go('/');
    }
  }

  /// Route d'accueil selon le rôle.
  String _homeForRole(String? role) => switch (role) {
    'Admin' => '/admin/dashboard',
    'PointIllico' => '/point/colis',
    _ => '/',
  };

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
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

              Text(
                'Portail Professionnel',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 60),

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