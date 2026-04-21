// ============================================================
//  ILLICO DELIVERY — Application Mobile
//  Rôles gérés : Client & Livreur
//  Stack : Flutter + Riverpod + GoRouter + Clean Architecture
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/config/app_theme.dart';
import 'core/config/app_router.dart';

/// Point d'entrée de l'application mobile ILLICO.
/// - ProviderScope encapsule toute l'app pour Riverpod.
/// - Le flavor est fixé à [AppFlavor.client] par défaut ;
///   il sera écrasé dynamiquement selon le rôle choisi.
void main() {
  // Déclare le flavor courant (utile pour la logique conditionnelle)
  currentFlavor = AppFlavor.client;

  runApp(
    // ProviderScope est nécessaire pour que tous les providers
    // Riverpod soient accessibles dans l'arbre de widgets.
    const ProviderScope(
      child: IllicoMobileApp(),
    ),
  );
}

/// Widget racine de l'application mobile.
/// Utilise [ConsumerWidget] pour écouter le routerProvider.
class IllicoMobileApp extends ConsumerWidget {
  const IllicoMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupère le router configuré (GoRouter) depuis le provider
    final router = ref.watch(mobileRouterProvider);

    return MaterialApp.router(
      title: 'ILLICO DELIVERY',

      // Masque la bannière debug en production
      debugShowCheckedModeBanner: false,

      // Thème global de l'application (couleurs, typographie, etc.)
      theme: AppTheme.light,

      // Configuration du router (GoRouter)
      routerConfig: router,
    );
  }
}