// ============================================================
//  ILLICO DELIVERY — Application Web (Back-office)
//  Rôles gérés : Admin & Point ILLICO
//  Stack : Flutter Web + Riverpod + GoRouter + Clean Architecture
//  Optimisé pour : écrans larges, sidebar navigation, tableaux
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_config.dart';
import 'core/config/app_theme.dart';
import 'core/config/app_router.dart';

/// Point d'entrée de l'application web ILLICO.
/// Cette application cible uniquement les rôles Admin et Point ILLICO.
/// Elle est distincte de l'app mobile (illico_mobile).
void main() {
  // Déclare le flavor admin par défaut pour le web
  currentFlavor = AppFlavor.admin;

  runApp(
    // ProviderScope encapsule toute l'app pour Riverpod
    const ProviderScope(
      child: IllicoWebApp(),
    ),
  );
}

/// Widget racine de l'application web back-office.
class IllicoWebApp extends ConsumerWidget {
  const IllicoWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Récupère le router configuré (GoRouter) depuis le provider web
    final router = ref.watch(webRouterProvider);

    return MaterialApp.router(
      title: 'ILLICO — Back-office',

      // Masque la bannière debug
      debugShowCheckedModeBanner: false,

      // Thème global cohérent avec l'app mobile
      theme: AppTheme.light,

      // Configuration GoRouter spécifique au web
      routerConfig: router,
    );
  }
}