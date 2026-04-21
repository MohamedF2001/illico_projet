import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/vehicule_model.dart';

class VehiculeRemoteDataSource {
  final ApiClient _api;
  VehiculeRemoteDataSource(this._api);

  Future<Either<Failure, List<VehiculeModel>>> getAll({bool? actif}) async {
    try {
      final res = await _api.dio.get('/vehicules', queryParameters: actif != null ? {'actif': actif} : null);
      final list = (res.data['data'] as List).map((e) => VehiculeModel.fromJson(e as Map<String, dynamic>)).toList();
      return Right(list);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, VehiculeModel>> getById(String id) async {
    try {
      final res = await _api.dio.get('/vehicules/$id');
      return Right(VehiculeModel.fromJson(res.data['data'] as Map<String, dynamic>));
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, VehiculeModel>> create(Map<String, dynamic> body) async {
    try {
      final res = await _api.dio.post('/vehicules', data: body);
      return Right(VehiculeModel.fromJson(res.data['data'] as Map<String, dynamic>));
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, VehiculeModel>> update(String id, Map<String, dynamic> body) async {
    try {
      final res = await _api.dio.put('/vehicules/$id', data: body);
      return Right(VehiculeModel.fromJson(res.data['data'] as Map<String, dynamic>));
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _api.dio.delete('/vehicules/$id');
      return const Right(null);
    } on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
