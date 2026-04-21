import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';

class NotificationRemoteDataSource {
  final ApiClient _api;
  NotificationRemoteDataSource(this._api);

  Future<Either<Failure, List<Map<String, dynamic>>>> getAll({Map<String, dynamic>? params}) async {
    try {
      final r = await _api.dio.get('/notifications', queryParameters: params);
      final raw = r.data['data'];
      if (raw is List) return Right(raw.cast<Map<String, dynamic>>());
      return Right([]);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, void>> markAsRead(String id) async {
    try { await _api.dio.put('/notifications/$id/lu'); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
