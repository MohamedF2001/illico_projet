import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/livraison_remote_datasource.dart';
import '../../data/repositories/livraison_repository_impl.dart';
import '../../domain/entities/livraison_entity.dart';
import '../../domain/usecases/get_livraisons_usecase.dart';

// ── List State ─────────────────────────────────────────────
class LivraisonListState {
  final bool isLoading;
  final List<LivraisonEntity> items;
  final Failure? error;
  const LivraisonListState({this.isLoading = false, this.items = const [], this.error});
  LivraisonListState copyWith({bool? isLoading, List<LivraisonEntity>? items, Failure? error}) =>
      LivraisonListState(isLoading: isLoading ?? this.isLoading, items: items ?? this.items, error: error);
}

class LivraisonListNotifier extends StateNotifier<LivraisonListState> {
  final GetLivraisonsUseCase _uc;
  LivraisonListNotifier(this._uc) : super(const LivraisonListState(isLoading: true)) { load(); }

  Future<void> load({Map<String, dynamic>? filters}) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _uc.execute(filters: filters);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (items) => state = state.copyWith(isLoading: false, items: items));
  }
}

// ── Form State ─────────────────────────────────────────────
/*class LivraisonFormState {
  final bool isLoading;
  final LivraisonEntity? result;
  final Failure? error;
  final Map<String, dynamic>? estimation;
  const LivraisonFormState({this.isLoading = false, this.result, this.error, this.estimation});
  LivraisonFormState copyWith({bool? isLoading, LivraisonEntity? result, Failure? error, Map<String, dynamic>? estimation}) =>
      LivraisonFormState(isLoading: isLoading ?? this.isLoading, result: result ?? this.result, error: error, estimation: estimation ?? this.estimation);
}*/

class LivraisonFormState {
  final bool isLoading;
  final LivraisonEntity? result;
  final Failure? error;
  final Map<String, dynamic>? estimation;

  // NEW FIELDS
  final String? mode;
  final double poids;
  final bool urgent;
  final bool nuit;
  final String modePaiement;
  final String natureColis;
  final String telephoneDepart;
  final String telephoneArrivee;

  const LivraisonFormState({
    this.isLoading = false,
    this.result,
    this.error,
    this.estimation,
    this.mode,
    this.poids = 1.0,
    this.urgent = false,
    this.nuit = false,
    this.modePaiement = 'cash',
    this.natureColis = '',
    this.telephoneDepart = '',
    this.telephoneArrivee = '',
  });

  LivraisonFormState copyWith({
    bool? isLoading,
    LivraisonEntity? result,
    Failure? error,
    Map<String, dynamic>? estimation,
    String? mode,
    double? poids,
    bool? urgent,
    bool? nuit,
    String? modePaiement,
    String? natureColis,
    String? telephoneDepart,
    String? telephoneArrivee,
  }) {
    return LivraisonFormState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: error,
      estimation: estimation ?? this.estimation,
      mode: mode ?? this.mode,
      poids: poids ?? this.poids,
      urgent: urgent ?? this.urgent,
      nuit: nuit ?? this.nuit,
      modePaiement: modePaiement ?? this.modePaiement,
      natureColis: natureColis ?? this.natureColis,
      telephoneDepart: telephoneDepart ?? this.telephoneDepart,
      telephoneArrivee: telephoneArrivee ?? this.telephoneArrivee,
    );
  }
}

/*class LivraisonFormNotifier extends StateNotifier<LivraisonFormState> {
  final LivraisonRepositoryImpl _repo;
  LivraisonFormNotifier(this._repo) : super(const LivraisonFormState());

  Future<void> estimate(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _repo.estimatePrice(body);
    r.fold((f) => state = state.copyWith(isLoading: false, error: f),
           (data) => state = state.copyWith(isLoading: false, estimation: data));
  }

  Future<bool> create(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, error: null);
    final r = await _repo.create(body);
    return r.fold((f) { state = state.copyWith(isLoading: false, error: f); return false; },
                  (liv) { state = state.copyWith(isLoading: false, result: liv); return true; });
  }
}*/

class LivraisonFormNotifier extends StateNotifier<LivraisonFormState> {
  final LivraisonRepositoryImpl _repo;

  Timer? _debounce;

  LivraisonFormNotifier(this._repo)
      : super(const LivraisonFormState());

  // ─────────────── SETTERS ───────────────

  void setMode(String mode) {
    state = state.copyWith(mode: mode);
    _triggerEstimate();
  }

  void setPoids(double p) {
    state = state.copyWith(poids: p);
    _triggerEstimate();
  }

  void setUrgent(bool v) {
    state = state.copyWith(urgent: v);
    _triggerEstimate();
  }

  void setNuit(bool v) {
    state = state.copyWith(nuit: v);
    _triggerEstimate();
  }

  void setPaiement(String v) {
    state = state.copyWith(modePaiement: v);
  }

  void setNatureColis(String v) {
    state = state.copyWith(natureColis: v);
  }

  void setTelephones({String? depart, String? arrivee}) {
    state = state.copyWith(
      telephoneDepart: depart ?? state.telephoneDepart,
      telephoneArrivee: arrivee ?? state.telephoneArrivee,
    );
  }

  void setData({
    required String vehicule,
    required List<double> coordDepart,
    required List<double> coordArrivee,
  }) {
    _vehicule = vehicule;
    _coordDepart = coordDepart;
    _coordArrivee = coordArrivee;
    _triggerEstimate();
  }

  // ─────────────── INTERNAL DATA ───────────────
  String? _vehicule;
  List<double>? _coordDepart;
  List<double>? _coordArrivee;

  // ─────────────── LIVE ESTIMATION ───────────────
  void _triggerEstimate() {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (_vehicule == null ||
          _coordDepart == null ||
          _coordArrivee == null) return;

      state = state.copyWith(isLoading: true);

      final r = await _repo.estimatePrice({
        'vehicule': _vehicule,
        'coordDepart': _coordDepart,
        'coordArrivee': _coordArrivee,
        'mode': state.mode,
        'poids': state.poids,
        'urgent': state.urgent,
        'nuit': state.nuit,
        'pointIllico': state.mode == 'point_illico' ? 'true' : null,
      });

      r.fold(
            (f) => state = state.copyWith(isLoading: false, error: f),
            (data) => state = state.copyWith(
          isLoading: false,
          estimation: data,
        ),
      );
    });
  }

  // ─────────────── CREATE ───────────────
  Future<bool> create(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true);

    final r = await _repo.create(body);

    return r.fold(
          (f) {
        state = state.copyWith(isLoading: false, error: f);
        return false;
      },
          (liv) {
        state = state.copyWith(isLoading: false, result: liv);
        return true;
      },
    );
  }

  Future<void> createLivraison() async {
    if (_vehicule == null || _coordDepart == null || _coordArrivee == null) return;

    state = state.copyWith(isLoading: true);

    final r = await _repo.create({
      'pointDepart': {
        'adresse': 'Départ', // ou stocke dans state si tu veux mieux
        'coordinates': _coordDepart,
      },
      'pointArrivee': {
        'adresse': 'Arrivée',
        'coordinates': _coordArrivee,
      },
      'vehicule': _vehicule,
      'mode': state.mode,
      'poids': state.poids,
      'modePaiement': state.modePaiement,
      'urgent': state.urgent,
      'nuit': state.nuit,
    });

    r.fold(
          (f) => state = state.copyWith(isLoading: false, error: f),
          (liv) => state = state.copyWith(isLoading: false, result: liv),
    );
  }
}

// ── Providers ─────────────────────────────────────────────
LivraisonRepositoryImpl _buildRepo() => LivraisonRepositoryImpl(LivraisonRemoteDataSource(apiClient));

final livraisonListProvider = StateNotifierProvider<LivraisonListNotifier, LivraisonListState>((ref) =>
    LivraisonListNotifier(GetLivraisonsUseCase(_buildRepo())));

final livraisonFormProvider = StateNotifierProvider<LivraisonFormNotifier, LivraisonFormState>((ref) =>
    LivraisonFormNotifier(_buildRepo()));
