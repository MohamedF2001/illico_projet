import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/tarif_remote_datasource.dart';

class TarifListState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Failure? error;
  const TarifListState({this.isLoading = false, this.items = const [], this.error});
  TarifListState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, Failure? error}) =>
      TarifListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}
class TarifListNotifier extends StateNotifier<TarifListState> {
  final TarifRemoteDataSource _ds;
  TarifListNotifier(this._ds) : super(const TarifListState(isLoading: true)) { load(); }
  Future<void> load({Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _ds.getAll(params: params);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items));
  }
}
final tarifListProvider = StateNotifierProvider<TarifListNotifier, TarifListState>((ref) =>
    TarifListNotifier(TarifRemoteDataSource(apiClient)));
