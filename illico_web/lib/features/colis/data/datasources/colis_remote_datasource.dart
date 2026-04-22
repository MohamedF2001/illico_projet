import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
class ColisRemoteDataSource {
  final ApiClient _api;
  ColisRemoteDataSource(this._api);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAll({Map<String, dynamic>? params}) async {
    try {
      final r = await _api.dio.get('/colis', queryParameters: params);
      final raw = r.data['data'];
      if (raw is List) return Right(raw.cast<Map<String, dynamic>>());
      return Right([]);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> getById(String id) async {
    try {
      final r = await _api.dio.get('/colis/$id');
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> create(Map<String, dynamic> body) async {
    try {
      final r = await _api.dio.post('/colis', data: body);
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> update(String id, Map<String, dynamic> body) async {
    try {
      final r = await _api.dio.put('/colis/$id', data: body);
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
