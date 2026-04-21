import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/point_illico_remote_datasource.dart';

class ColisPointState {
  final bool isLoading;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? stats;
  final Failure? error;
  const ColisPointState({this.isLoading = false, this.items = const [], this.stats, this.error});
  ColisPointState copyWith({bool? isLoading, List<Map<String, dynamic>>? items, Map<String, dynamic>? stats, Failure? error}) =>
      ColisPointState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items,
          stats: stats ?? this.stats, error: error);
}

class ColisPointNotifier extends StateNotifier<ColisPointState> {
  final PointIllicoRemoteDataSource _ds;
  ColisPointNotifier(this._ds) : super(const ColisPointState(isLoading: true)) { loadAll(); }

  Future<void> loadAll({String? statut}) async {
    state = state.copyWith(isLoading: true, error: null);
    final [cr, sr] = await Future.wait([_ds.getColis(statut: statut), _ds.getStats()]);
    cr.fold((f) => state = state.copyWith(isLoading: false, error: f),
            (items) => state = state.copyWith(isLoading: false, items: items as List<Map<String, dynamic>>));
    sr.fold((_) {}, (s) => state = state.copyWith(stats: s as Map<String, dynamic>));
  }
}

final colisPointProvider = StateNotifierProvider<ColisPointNotifier, ColisPointState>((ref) =>
    ColisPointNotifier(PointIllicoRemoteDataSource(apiClient)));
