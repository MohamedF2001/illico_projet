import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
class TransactionRemoteDataSource {
  final ApiClient _api;
  TransactionRemoteDataSource(this._api);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAll({Map<String, dynamic>? params}) async {
    try {
      final r = await _api.dio.get('/transactions', queryParameters: params);
      final raw = r.data['data'];
      if (raw is List) return Right(raw.cast<Map<String, dynamic>>());
      return Right([]);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> getById(String id) async {
    try {
      final r = await _api.dio.get('/transactions/$id');
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> create(Map<String, dynamic> body) async {
    try {
      final r = await _api.dio.post('/transactions', data: body);
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, Map<String, dynamic>>> update(String id, Map<String, dynamic> body) async {
    try {
      final r = await _api.dio.put('/transactions/$id', data: body);
      return Right(r.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
