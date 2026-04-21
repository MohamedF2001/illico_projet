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
  VehiculeListNotifier(this._uc) : super(const VehiculeListState(isLoading: true)) { load(); }

  Future<void> load({bool? actif}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _uc.execute(actif: actif);
    r.fold(
      (f) => state = state.copyWith(isLoading: false, error: f),
      (items) => state = state.copyWith(isLoading: false, items: items),
    );
  }
}

final vehiculeListProvider = StateNotifierProvider<VehiculeListNotifier, VehiculeListState>((ref) {
  final repo = VehiculeRepositoryImpl(VehiculeRemoteDataSource(apiClient));
  return VehiculeListNotifier(GetVehiculesUseCase(repo));
});
