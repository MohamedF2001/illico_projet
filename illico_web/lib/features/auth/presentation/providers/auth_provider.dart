// ============================================================
//  AUTH PROVIDER — Application Web
//  Gère l'état d'authentification pour Admin et Point ILLICO.
//  Restaure automatiquement la session depuis SharedPreferences.
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

// ─────────────────────────────────────────────────────────────
//  État d'authentification
// ─────────────────────────────────────────────────────────────

/// Représente l'état courant de l'authentification.
class AuthState {
  final bool isLoading;      // Chargement en cours (login, restore session)
  final UserEntity? user;    // Utilisateur connecté (null si déconnecté)
  final String? token;       // Token JWT (null si déconnecté)
  final Failure? error;      // Dernière erreur survenue

  const AuthState({
    this.isLoading = false,
    this.user,
    this.token,
    this.error,
  });

  /// Vrai si l'utilisateur est connecté (token ET user présents)
  bool get isLoggedIn => token != null && user != null;

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? token,
    Failure? error,
    bool clearUser = false, // Si true, efface user et token
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        user: clearUser ? null : (user ?? this.user),
        token: clearUser ? null : (token ?? this.token),
        error: error,
      );
}

// ─────────────────────────────────────────────────────────────
//  Notifier d'authentification
// ─────────────────────────────────────────────────────────────

/// Gère toutes les actions d'authentification :
/// - Restauration de session au démarrage
/// - Connexion (Admin ou Point ILLICO)
/// - Déconnexion
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final AuthRepositoryImpl _repo;

  AuthNotifier(this._loginUseCase, this._repo)
      : super(const AuthState()) {
    // Tente de restaurer une session existante dès l'initialisation
    _restoreSession();
  }

  /// Restaure la session depuis les préférences locales.
  /// Si le token est expiré ou invalide, nettoie et déconnecte.
  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return; // Aucune session à restaurer

    // Token trouvé → tente de charger le profil
    state = state.copyWith(token: token, isLoading: true);
    final result = await _repo.getProfile();

    result.fold(
          (failure) async {
        // Token invalide ou expiré → nettoie
        await prefs.remove('token');
        state = const AuthState();
      },
          (user) {
        // Session valide → met à jour l'état
        state = state.copyWith(isLoading: false, user: user);
      },
    );
  }

  /// Connecte un utilisateur selon son rôle.
  /// Retourne [true] si la connexion réussit, [false] sinon.
  /*Future<bool> login({
    required String role,       // 'Admin' ou 'PointIllico'
    String? email,              // Requis pour Admin
    String? telephone,          // Requis pour PointIllico
    String? motDePasse,         // Requis pour Admin et PointIllico
    String? codePin,            // Non utilisé sur le web
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUseCase.execute(
      role: role,
      email: email,
      telephone: telephone,
      motDePasse: motDePasse,
      codePin: codePin,
    );

    return result.fold(
      // Échec → stocke l'erreur pour affichage
          (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
      // Succès → sauvegarde le token et charge le profil complet
          (data) async {
        final token = data['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Charge le profil complet depuis l'API
        final profileResult = await _repo.getProfile();
        profileResult.fold(
              (_) {
            // Profil non chargeable → garde le token quand même
            state = state.copyWith(isLoading: false, token: token);
          },
              (user) {
            state = state.copyWith(isLoading: false, user: user, token: token);
          },
        );

        return true;
      },
    );
  }*/

  Future<bool> login({
    required String role,
    String? email,
    String? telephone,
    String? motDePasse,
    String? codePin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUseCase.execute(
      role: role,
      email: email,
      telephone: telephone,
      motDePasse: motDePasse,
      codePin: codePin,
    );

    return result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, error: failure);
        return false;
      },
          (data) async {
        final token = data['token'] as String;
        final userJson = data['user'] ?? data['data'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // ⚠️ IMPORTANT : check statut actif
        final bool actif = userJson['actif'] ?? true;

        if (!actif) {
          state = state.copyWith(
            isLoading: false,
            error: const Failure.unexpectedError(), // ou custom failure
            token: token,
          );

          return false; // ❌ login refusé UI
        }

        final profileResult = await _repo.getProfile();

        profileResult.fold(
              (_) {
            state = state.copyWith(isLoading: false, token: token);
          },
              (user) {
            state = state.copyWith(
              isLoading: false,
              user: user,
              token: token,
            );
          },
        );

        return true;
      },
    );
  }

  Future<bool> registerPointIllico({
    required String nom,
    required String telephone,
    required String motDePasse,
    required String adresse,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repo.registerPoint(
      body: {
        "nom": nom,
        "telephone": telephone,
        "motDePasse": motDePasse,
        "adresse": adresse,
      },
    );

    return result.fold(
          (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure,
        );
        return false;
      },
          (user) {
        // inscription OK → pas de login automatique
        state = state.copyWith(
          isLoading: false,
        );
        return true;
      },
    );
  }

  /// Déconnecte l'utilisateur et nettoie le stockage local.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = const AuthState(); // Réinitialise complètement l'état
  }

  /// Rafraîchit le profil depuis l'API (utile après une mise à jour).
  Future<void> refreshProfile() async {
    final result = await _repo.getProfile();
    result.fold(
          (_) {}, // Ignore les erreurs silencieusement
          (user) => state = state.copyWith(user: user),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Provider global d'authentification
// ─────────────────────────────────────────────────────────────

/// Provider Riverpod exposant [AuthNotifier] et [AuthState].
/// Accessible dans toute l'application via `ref.watch(authProvider)`.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = AuthRepositoryImpl(AuthRemoteDataSource(apiClient));
  return AuthNotifier(LoginUseCase(repo), repo);
});