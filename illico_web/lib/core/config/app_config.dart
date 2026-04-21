// ============================================================
//  CONFIGURATION — Application Web
//  Contient les constantes de configuration pour l'app web.
//  Change [baseUrl] selon l'environnement cible.
// ============================================================

/// Enum des différentes saveurs de l'application.
/// Permet d'adapter le comportement selon le contexte.
enum AppFlavor {
  client,      // App mobile — espace client
  livreur,     // App mobile — espace livreur
  pointIllico, // App web — espace point ILLICO
  admin,       // App web — espace administrateur
}

/// Flavor actif — initialisé dans main.dart selon l'app lancée.
AppFlavor currentFlavor = AppFlavor.admin;

/// Active/désactive le mode démo (bloque les actions d'écriture).
const bool kDemoMode = false;

/// Constantes globales de l'application.
class AppConfig {
  // ── URL de l'API backend ─────────────────────────────────
  // En développement local (web) : http://localhost:3000/api
  // En production : URL Vercel déployée
  //static const String baseUrl = 'https://illico-delivery.vercel.app/api';

  static const String baseUrl = 'http://localhost:3000/api';

  // ── URL Socket.io pour le temps réel ─────────────────────
  static const String socketUrl = 'https://illico-delivery.vercel.app';

  // ── Timeouts réseau (en millisecondes) ────────────────────
  static const int connectTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000; // 30 secondes

  // ── Règles métier ─────────────────────────────────────────
  /// Seuil de cash (FCFA) au-delà duquel un livreur est bloqué
  static const double cashBlocageSeuil = 50000;

  /// Durée (secondes) avant expiration d'une mission non acceptée
  static const int missionTimeoutSeconds = 30;

  /// Tarif de stockage journalier après la période gratuite (48h)
  static const double stockageTarifJour = 200;
}