import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/zone_model.dart';

class ZoneRemoteDataSource {
  final ApiClient _api;
  ZoneRemoteDataSource(this._api);
  Future<Either<Failure, List<ZoneModel>>> getAll({bool? actif}) async {
    try { final r = await _api.dio.get('/zones', queryParameters: actif != null ? {'actif': actif} : null);
      return Right((r.data['data'] as List).map((e) => ZoneModel.fromJson(e as Map<String, dynamic>)).toList()); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); }
    catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, ZoneModel>> create(Map<String, dynamic> body) async {
    try { final r = await _api.dio.post('/zones', data: body); return Right(ZoneModel.fromJson(r.data['data'] as Map<String, dynamic>)); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, ZoneModel>> update(String id, Map<String, dynamic> body) async {
    try { final r = await _api.dio.put('/zones/$id', data: body); return Right(ZoneModel.fromJson(r.data['data'] as Map<String, dynamic>)); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
  Future<Either<Failure, void>> delete(String id) async {
    try { await _api.dio.delete('/zones/$id'); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
