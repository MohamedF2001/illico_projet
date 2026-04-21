import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';

class LivreurRemoteDataSource {
  final ApiClient _api;
  LivreurRemoteDataSource(this._api);

  Future<Either<Failure, List<Map<String, dynamic>>>> getAll({Map<String, dynamic>? params}) async {
    try { final r = await _api.dio.get('/livreurs', queryParameters: params);
      return Right((r.data['data'] as List).cast<Map<String, dynamic>>()); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getMissions() async {
    try { final r = await _api.dio.get('/livreurs/missions');
      return Right((r.data['data'] as List).cast<Map<String, dynamic>>()); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, Map<String, dynamic>>> getStats() async {
    try { final r = await _api.dio.get('/livreurs/stats'); return Right(r.data['data'] as Map<String, dynamic>); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, void>> updateStatut(String statut) async {
    try { await _api.dio.put('/livreurs/statut', data: {'statut': statut}); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, void>> updatePosition(List<double> coords) async {
    try { await _api.dio.post('/livreurs/position', data: {'coordinates': coords}); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, void>> validate(String id, bool valide) async {
    try { await _api.dio.put('/livreurs/$id/valider', data: {'valide': valide}); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, void>> reverseCash(String id, double montant) async {
    try { await _api.dio.put('/livreurs/$id/reverse-cash', data: {'montant': montant}); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
