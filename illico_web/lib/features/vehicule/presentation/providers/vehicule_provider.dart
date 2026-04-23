import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/vehicule_remote_datasource.dart';
import '../../data/repositories/vehicule_repository_impl.dart';
import '../../domain/entities/vehicule_entity.dart';
import '../../domain/usecases/get_vehicules_usecase.dart';

class VehiculeListState {
  final bool isLoading;
  final List<VehiculeEntity> items;
  final Failure? error;
  const VehiculeListState({this.isLoading = false, this.items = const [], this.error});
  VehiculeListState copyWith({bool? isLoading, List<VehiculeEntity>? items, Failure? error}) =>
      VehiculeListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}

class VehiculeListNotifier extends StateNotifier<VehiculeListState> {
  final GetVehiculesUseCase _uc;
  final VehiculeRemoteDataSource _ds;
  VehiculeListNotifier(this._uc, this._ds) : super(const VehiculeListState(isLoading: true)) { load(); }

  Future<void> load({bool? actif}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _uc.execute(actif: actif);
    r.fold(
      (f) => state = state.copyWith(isLoading: false, error: f),
      (items) => state = state.copyWith(isLoading: false, items: items),
    );
  }

  Future<void> delete(String id) async {
    final res = await _ds.delete(id);
    res.fold((_) {}, (_) => load());
  }
}

final vehiculeListProvider = StateNotifierProvider<VehiculeListNotifier, VehiculeListState>((ref) {
  final ds = VehiculeRemoteDataSource(apiClient);
  final repo = VehiculeRepositoryImpl(ds);
  return VehiculeListNotifier(GetVehiculesUseCase(repo), ds);
});
