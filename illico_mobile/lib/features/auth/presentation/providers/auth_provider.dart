import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// ── State ─────────────────────────────────────────────────
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? token;
  final Failure? error;
  const AuthState({this.isLoading = false, this.user, this.token, this.error});
  bool get isLoggedIn => token != null && user != null;
  AuthState copyWith({bool? isLoading, UserEntity? user, String? token, Failure? error, bool clearUser = false}) => AuthState(
    isLoading: isLoading ?? this.isLoading,
    user: clearUser ? null : (user ?? this.user),
    token: clearUser ? null : (token ?? this.token),
    error: error,
  );
}

// ── Notifier ──────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final AuthRepositoryImpl _repo;
  AuthNotifier(this._login, this._register, this._repo)
      : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;
    state = state.copyWith(token: token, isLoading: true);
    final result = await _repo.getProfile();
    result.fold(
      (f) async { await prefs.remove('token'); state = AuthState(); },
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<bool> login({
    required String role,
    String? email,
    String? telephone,
    String? motDePasse,
    String? codePin,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _login.execute(
      role: role, email: email, telephone: telephone,
      motDePasse: motDePasse, codePin: codePin,
    );
    return await result.fold(
      (f) async { state = state.copyWith(isLoading: false, error: f); return false; },
      (data) async {
        final token = data['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        final userResult = await _repo.getProfile();
        userResult.fold(
          (_) {},
          (u) => state = state.copyWith(isLoading: false, user: u, token: token),
        );
        return true;
      },
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    state = AuthState();
  }

  Future<bool> initRegisterClient({required String telephone}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.initClientRegister(telephone: telephone);
    return result.fold(
      (f) {
        state = state.copyWith(isLoading: false, error: f);
        return false;
      },
      (data) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> register({
    required String role,
    required Map<String, dynamic> body,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _register.execute(role: role, body: body);
    return result.fold(
      (f) {
        state = state.copyWith(isLoading: false, error: f);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<void> refreshProfile() async {
    final result = await _repo.getProfile();
    result.fold((_) {}, (u) => state = state.copyWith(user: u));
  }

  Future<bool> updateProfile(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.updateProfile(body: body);
    return result.fold(
      (f) {
        state = state.copyWith(isLoading: false, error: f);
        return false;
      },
      (u) {
        state = state.copyWith(isLoading: false, user: u);
        return true;
      },
    );
  }

  Future<bool> updatePhoto(dynamic fileData, {bool isWeb = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.uploadProfilePhoto(fileData: fileData, isWeb: isWeb);
    return result.fold(
      (f) {
        state = state.copyWith(isLoading: false, error: f);
        return false;
      },
      (photoUrl) {
        if (state.user != null) {
          // Note: On pourrait aussi appeler refreshProfile ici pour être sûr
          state = state.copyWith(
            isLoading: false,
            // On ne peut pas facilement copier l'entité immuable ici sans un copyWith sur UserEntity,
            // mais refreshProfile est plus propre.
          );
          refreshProfile();
        }
        return true;
      },
    );
  }
}

// ── Provider ──────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = AuthRepositoryImpl(AuthRemoteDataSource(apiClient));
  return AuthNotifier(LoginUseCase(repo), RegisterUseCase(repo), repo);
});
