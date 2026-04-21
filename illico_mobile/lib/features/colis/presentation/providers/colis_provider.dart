import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/colis_remote_datasource.dart';

class ColisListState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Failure? error;
  const ColisListState({this.isLoading = false, this.items = const [], this.error});
  ColisListState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, Failure? error}) =>
      ColisListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}
class ColisListNotifier extends StateNotifier<ColisListState> {
  final ColisRemoteDataSource _ds;
  ColisListNotifier(this._ds) : super(const ColisListState(isLoading: true)) { load(); }
  Future<void> load({Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _ds.getAll(params: params);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items));
  }
}
final colisListProvider = StateNotifierProvider<ColisListNotifier, ColisListState>((ref) =>
    ColisListNotifier(ColisRemoteDataSource(apiClient)));
