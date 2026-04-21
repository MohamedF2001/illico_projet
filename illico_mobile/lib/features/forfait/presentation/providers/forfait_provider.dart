import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/forfait_remote_datasource.dart';

class ForfaitListState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Failure? error;
  const ForfaitListState({this.isLoading = false, this.items = const [], this.error});
  ForfaitListState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, Failure? error}) =>
      ForfaitListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}
class ForfaitListNotifier extends StateNotifier<ForfaitListState> {
  final ForfaitRemoteDataSource _ds;
  ForfaitListNotifier(this._ds) : super(const ForfaitListState(isLoading: true)) { load(); }
  Future<void> load({Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _ds.getAll(params: params);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items));
  }
}
final forfaitListProvider = StateNotifierProvider<ForfaitListNotifier, ForfaitListState>((ref) =>
    ForfaitListNotifier(ForfaitRemoteDataSource(apiClient)));
