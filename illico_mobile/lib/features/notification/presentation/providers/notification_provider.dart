import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/notification_remote_datasource.dart';

class NotificationListState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Failure? error;
  const NotificationListState({this.isLoading = false, this.items = const [], this.error});
  NotificationListState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, Failure? error}) =>
      NotificationListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}
class NotificationListNotifier extends StateNotifier<NotificationListState> {
  final NotificationRemoteDataSource _ds;
  NotificationListNotifier(this._ds) : super(const NotificationListState(isLoading: true)) { load(); }
  Future<void> load({Map<String, dynamic>? params}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _ds.getAll(params: params);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items));
  }
}
final notificationListProvider = StateNotifierProvider<NotificationListNotifier, NotificationListState>((ref) =>
    NotificationListNotifier(NotificationRemoteDataSource(apiClient)));
