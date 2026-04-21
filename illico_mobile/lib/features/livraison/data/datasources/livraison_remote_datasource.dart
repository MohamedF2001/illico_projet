import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/livraison_model.dart';

class LivraisonRemoteDataSource {
  final ApiClient _api;
  LivraisonRemoteDataSource(this._api);

  Future<Either<Failure, Map<String, dynamic>>> estimatePrice(Map<String, dynamic> body) async {
    try {
      final r = await _api.dio.post('/livraisons/estimation-prix', data: body);
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, LivraisonModel>> create(Map<String, dynamic> body) async {
    try {
      final r = await _api.dio.post('/livraisons', data: body);
      return Right(LivraisonModel.fromJson(r.data['data'] as Map<String, dynamic>));
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, List<LivraisonModel>>> getAll({Map<String, dynamic>? filters}) async {
    try {
      final r = await _api.dio.get('/livraisons', queryParameters: filters);
      final list = (r.data['data'] as List).map((e) => LivraisonModel.fromJson(e as Map<String, dynamic>)).toList();
      return Right(list);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, LivraisonModel>> getById(String id) async {
    try {
      final r = await _api.dio.get('/livraisons/$id');
      return Right(LivraisonModel.fromJson(r.data['data'] as Map<String, dynamic>));
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, Map<String, dynamic>>> validateOtp(String id, String otp) async {
    try {
      final r = await _api.dio.post('/livraisons/$id/valider-otp', data: {'otp': otp});
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, void>> delete(String id) async {
    try { await _api.dio.delete('/livraisons/$id'); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, LivraisonModel>> updateStatut(String id, String statut) async {
    try {
      final r = await _api.dio.put('/livraisons/$id/statut', data: {'statut': statut});
      return Right(LivraisonModel.fromJson({'_id': id, 'statut': r.data['data']['statut'], 'pointDepart': {'adresse': '', 'coordinates': [0.0, 0.0]}, 'pointArrivee': {'adresse': '', 'coordinates': [0.0, 0.0]}, 'mode': 'express', 'prixEstime': 0}));
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, LivraisonModel>> assignLivreur(String id, String livreurId) async {
    try {
      final r = await _api.dio.put('/livraisons/$id/affecter', data: {'livreurId': livreurId});
      return Right(LivraisonModel.fromJson(r.data['data']['livraison'] as Map<String, dynamic>));
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, Map<String, dynamic>>> uploadPreuve(String id, dynamic file, bool isWeb) async {
    try {
      final fd = FormData();
      if (isWeb) {
        fd.files.add(MapEntry('preuve', MultipartFile.fromBytes(file as List<int>, filename: 'preuve.png')));
      } else {
        fd.files.add(MapEntry('preuve', await MultipartFile.fromFile(file as String, filename: 'preuve.jpg')));
      }
      final r = await _api.dio.post('/livraisons/$id/preuve', data: fd);
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
