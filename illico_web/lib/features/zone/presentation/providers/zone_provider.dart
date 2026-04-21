import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/zone_remote_datasource.dart';
import '../../domain/entities/zone_entity.dart';

class ZoneListState {
  final bool isLoading;
  final List<ZoneEntity> items;
  final Failure? error;
  const ZoneListState({this.isLoading = false, this.items = const [], this.error});
  ZoneListState copyWith({bool? isLoading, List<ZoneEntity>? items, Failure? error}) =>
      ZoneListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}
class ZoneListNotifier extends StateNotifier<ZoneListState> {
  final ZoneRemoteDataSource _ds;
  ZoneListNotifier(this._ds) : super(const ZoneListState(isLoading: true)) { load(); }
  Future<void> load({bool? actif}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _ds.getAll(actif: actif);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items.cast<ZoneEntity>()));
  }
}
final zoneListProvider = StateNotifierProvider<ZoneListNotifier, ZoneListState>((ref) =>
    ZoneListNotifier(ZoneRemoteDataSource(apiClient)));
