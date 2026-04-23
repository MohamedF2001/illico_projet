import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/livraison_remote_datasource.dart';
import '../../data/repositories/livraison_repository_impl.dart';
import '../../domain/entities/livraison_entity.dart';
import '../../domain/usecases/get_livraisons_usecase.dart';
import '../../domain/usecases/create_livraison_usecase.dart';

// ── List State ─────────────────────────────────────────────
class LivraisonListState {
  final bool isLoading;
  final List<LivraisonEntity> items;
  final Failure? error;
  const LivraisonListState({this.isLoading = false, this.items = const [], this.error});
  LivraisonListState copyWith({bool? isLoading, List<LivraisonEntity>? items, Failure? error}) =>
      LivraisonListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}

class LivraisonListNotifier extends StateNotifier<LivraisonListState> {
  final GetLivraisonsUseCase _uc;
  LivraisonListNotifier(this._uc) : super(const LivraisonListState(isLoading: true)) { load(); }

  Future<void> load({Map<String, dynamic>? filters}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _uc.execute(filters: filters);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items));
  }
}

// ── Form State ─────────────────────────────────────────────
class LivraisonFormState {
  final bool isLoading;
  final LivraisonEntity? result;
  final Failure? error;
  final Map<String, dynamic>? estimation;
  const LivraisonFormState({this.isLoading = false, this.result, this.error, this.estimation});
  LivraisonFormState copyWith({bool? isLoading, LivraisonEntity? result, Failure? error, Map<String, dynamic>? estimation}) =>
      LivraisonFormState(isLoading: isLoading ?? this.isLoading, result: result ?? this.result, error: error, estimation: estimation ?? this.estimation);
}

class LivraisonFormNotifier extends StateNotifier<LivraisonFormState> {
  final LivraisonRepositoryImpl _repo;
  LivraisonFormNotifier(this._repo) : super(const LivraisonFormState());

  Future<void> estimate(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _repo.estimatePrice(body);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (data) => state = state.copyWith(isLoading: false, estimation: data));
  }

  Future<bool> create(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _repo.create(body);
    return r.fold((f) { state = state.copyWith(isLoading: false, error: f); return false; },
                  (liv) { state = state.copyWith(isLoading: false, result: liv); return true; });
  }
}

// ── Providers ─────────────────────────────────────────────
LivraisonRepositoryImpl _buildRepo() => LivraisonRepositoryImpl(LivraisonRemoteDataSource(apiClient));

final livraisonListProvider = StateNotifierProvider<LivraisonListNotifier, LivraisonListState>((ref) =>
    LivraisonListNotifier(GetLivraisonsUseCase(_buildRepo())));

final livraisonFormProvider = StateNotifierProvider<LivraisonFormNotifier, LivraisonFormState>((ref) =>
    LivraisonFormNotifier(_buildRepo()));
