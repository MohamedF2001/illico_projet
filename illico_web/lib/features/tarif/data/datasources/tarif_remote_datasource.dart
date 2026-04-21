import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';

class TarifRemoteDataSource {
  final ApiClient _api;
  TarifRemoteDataSource(this._api);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAll({Map<String, dynamic>? params}) async {
    try { final r = await _api.dio.get('/tarifs', queryParameters: params);
      return Right((r.data['data'] as List).cast<Map<String, dynamic>>()); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> calculate(Map<String, dynamic> body) async {
    try { final r = await _api.dio.post('/tarifs/calcul', data: body);
      return Right(r.data['data'] as Map<String, dynamic>); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> create(Map<String, dynamic> body) async {
    try { final r = await _api.dio.post('/tarifs', data: body);
      return Right(r.data['data'] as Map<String, dynamic>); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> update(String id, Map<String, dynamic> body) async {
    try { final r = await _api.dio.put('/tarifs/$id', data: body);
      return Right(r.data['data'] as Map<String, dynamic>); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, void>> delete(String id) async {
    try { await _api.dio.delete('/tarifs/$id'); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
