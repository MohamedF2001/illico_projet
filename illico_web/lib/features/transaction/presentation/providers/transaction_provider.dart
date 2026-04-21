import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/transaction_remote_datasource.dart';

class TransactionListState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Failure? error;
  const TransactionListState({this.isLoading = false, this.items = const [], this.error});
  TransactionListState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, Failure? error}) =>
      TransactionListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}
class TransactionListNotifier extends StateNotifier<TransactionListState> {
  final TransactionRemoteDataSource _ds;
  TransactionListNotifier(this._ds) : super(const TransactionListState(isLoading: true)) { load(); }
  Future<void> load({Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _ds.getAll(params: params);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items));
  }
}
final transactionListProvider = StateNotifierProvider<TransactionListNotifier, TransactionListState>((ref) =>
    TransactionListNotifier(TransactionRemoteDataSource(apiClient)));
