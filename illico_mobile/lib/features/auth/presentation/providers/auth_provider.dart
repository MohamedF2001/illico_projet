import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';

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
  final AuthRepositoryImpl _repo;
  AuthNotifier(this._login, this._repo) : super(const AuthState()) { _restoreSession(); }

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

  Future<bool> login({required String role, String? email, String? telephone, String? motDePasse, String? codePin}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _login.execute(
      role: role, email: email, telephone: telephone,
      motDePasse: motDePasse, codePin: codePin,
    );
    return await result.fold(
      (f) async { state = state.copyWith(isLoading: false, error: f); return false; },
      (data) async {
        final token = data['token'] as String;
        final userJson = data['user'] as Map<String, dynamic>;
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

  Future<void> refreshProfile() async {
    final result = await _repo.getProfile();
    result.fold((_) {}, (u) => state = state.copyWith(user: u));
  }
}

// ── Provider ──────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = AuthRepositoryImpl(AuthRemoteDataSource(apiClient));
  return AuthNotifier(LoginUseCase(repo), repo);
});
