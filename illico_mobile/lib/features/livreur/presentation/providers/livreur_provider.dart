import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/livreur_remote_datasource.dart';
import '../../../livraison/data/datasources/livraison_remote_datasource.dart';
import '../../../livraison/data/repositories/livraison_repository_impl.dart';
import '../../../livraison/domain/entities/livraison_entity.dart';

class LivreurListState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Failure? error;
  const LivreurListState({this.isLoading = false, this.items = const [], this.error});
  LivreurListState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, Failure? error}) =>
      LivreurListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}

class LivreurListNotifier extends StateNotifier<LivreurListState> {
  final LivreurRemoteDataSource _ds;
  LivreurListNotifier(this._ds) : super(const LivreurListState(isLoading: true)) { load(); }
  Future<void> load({Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _ds.getAll(params: params);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items));
  }
}

class MissionsState {
  final bool isLoading;
  final List<Map<String, dynamic>> missions;
  final Map<String, dynamic>? stats;
  final String statut;
  final Failure? error;
  const MissionsState({this.isLoading = false, this.missions = const [], this.stats, this.statut = 'hors_ligne', this.error});
  MissionsState copyWith({bool? isLoading, List<Map<String, dynamic>>? missions, Map<String, dynamic>? stats, String? statut, Failure? error}) =>
      MissionsState(isLoading: isLoading ?? this.isLoading, missions: missions ?? this.missions,
          stats: stats ?? this.stats, statut: statut ?? this.statut, error: error);
}

class MissionsNotifier extends StateNotifier<MissionsState> {
  final LivreurRemoteDataSource ds;
  MissionsNotifier(this.ds) : super(const MissionsState(isLoading: true)) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, error: null);
    final [mr, sr] = await Future.wait([ds.getMissions(), ds.getStats()]);
    mr.fold(
        (f) => state = state.copyWith(isLoading: false, error: f),
        (m) => state = state.copyWith(
            isLoading: false, missions: m as List<Map<String, dynamic>>));
    sr.fold(
        (_) {}, (s) => state = state.copyWith(stats: s as Map<String, dynamic>));
  }

  Future<void> toggleStatut() async {
    final newStatut = state.statut == 'en_ligne' ? 'hors_ligne' : 'en_ligne';
    final r = await ds.updateStatut(newStatut);
    r.fold((f) {}, (_) => state = state.copyWith(statut: newStatut));
  }

  Future<void> updatePosition(List<double> coords) async {
    await ds.updatePosition(coords);
  }
}

final livreurListProvider = StateNotifierProvider<LivreurListNotifier, LivreurListState>((ref) =>
    LivreurListNotifier(LivreurRemoteDataSource(apiClient)));

final missionsProvider = StateNotifierProvider<MissionsNotifier, MissionsState>((ref) =>
    MissionsNotifier(LivreurRemoteDataSource(apiClient)));

// ── Available Deliveries ───────────────────────────────────

class AvailableDeliveriesState {
  final bool isLoading;
  final List<LivraisonEntity> items;
  final Failure? error;

  const AvailableDeliveriesState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });

  AvailableDeliveriesState copyWith({
    bool? isLoading,
    List<LivraisonEntity>? items,
    Failure? error,
  }) {
    return AvailableDeliveriesState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
    );
  }
}

class AvailableDeliveriesNotifier extends StateNotifier<AvailableDeliveriesState> {
  final LivraisonRepositoryImpl _repo;

  AvailableDeliveriesNotifier(this._repo) : super(const AvailableDeliveriesState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _repo.getAvailable();
    r.fold(
      (f) => state = state.copyWith(isLoading: false, error: f),
      (items) => state = state.copyWith(isLoading: false, items: items),
    );
  }

  Future<bool> accept(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _repo.accepter(id);
    return r.fold(
      (f) {
        state = state.copyWith(isLoading: false, error: f);
        return false;
      },
      (_) {
        load();
        return true;
      },
    );
  }
}

final availableDeliveriesProvider =
    StateNotifierProvider<AvailableDeliveriesNotifier, AvailableDeliveriesState>((ref) {
  final ds = LivraisonRemoteDataSource(apiClient);
  final repo = LivraisonRepositoryImpl(ds);
  return AvailableDeliveriesNotifier(repo);
});
