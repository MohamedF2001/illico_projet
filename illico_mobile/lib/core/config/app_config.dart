// ============================================================
//  CONFIGURATION — Application Mobile
//  10.0.2.2 = localhost vu depuis l'émulateur Android.
//  Changer l'URL selon l'environnement de déploiement.
// ============================================================

enum AppFlavor { client, livreur, pointIllico, admin }

/// Flavor actif — modifié dans main.dart selon l'app
AppFlavor currentFlavor = AppFlavor.client;

/// Mode démo : bloque les mutations (écriture) sur l'API
const bool kDemoMode = false;

class AppConfig {
  // ── URLs ───────────────────────────────────────────────────
  // Développement Android : http://10.0.2.2:3000/api
  // Développement iOS     : http://localhost:3000/api
  // Production            : https://illico-delivery.vercel.app/api
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static const String socketUrl = 'https://illico-delivery.vercel.app';

  // ── Réseau ─────────────────────────────────────────────────
  static const int connectTimeout = 30000; // ms
  static const int receiveTimeout = 30000; // ms

  // ── Règles métier ──────────────────────────────────────────
  static const double cashBlocageSeuil = 50000;    // FCFA
  static const int missionTimeoutSeconds = 30;      // secondes
  static const double stockageTarifJour = 200;      // FCFA/jour
}