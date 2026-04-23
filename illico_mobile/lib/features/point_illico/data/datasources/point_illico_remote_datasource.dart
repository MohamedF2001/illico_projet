import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';

class PointIllicoRemoteDataSource {
  final ApiClient _api;
  PointIllicoRemoteDataSource(this._api);

  Future<Either<Failure, List<Map<String, dynamic>>>> getAll({bool? actif}) async {
    try { final r = await _api.dio.get('/points', queryParameters: actif != null ? {'actif': actif} : null);
      return Right((r.data['data'] as List).cast<Map<String, dynamic>>()); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getColis({String? statut}) async {
    try { final r = await _api.dio.get('/points/mes-colis', queryParameters: statut != null ? {'statut': statut} : null);
      return Right((r.data['data'] as List).cast<Map<String, dynamic>>()); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, Map<String, dynamic>>> receiveColis(String livraisonId, String otpRetrait) async {
    try { final r = await _api.dio.post('/points/colis/reception', data: {'livraisonId': livraisonId, 'otpRetrait': otpRetrait});
      return Right(r.data['data'] as Map<String, dynamic>); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, Map<String, dynamic>>> retrieveColis(String id, String otp, {String? signatureUrl}) async {
    try { final r = await _api.dio.post('/points/colis/$id/retrait',
          data: {'otpRetrait': otp, if (signatureUrl != null) 'signatureUrl': signatureUrl});
      return Right(r.data['data'] as Map<String, dynamic>); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, Map<String, dynamic>>> getStats() async {
    try { final r = await _api.dio.get('/points/stats'); return Right(r.data['data'] as Map<String, dynamic>); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }

  Future<Either<Failure, void>> toggleActivation(String id, bool actif) async {
    try { await _api.dio.put('/points/$id/activation', data: {'actif': actif}); return const Right(null); }
    on DioException catch (e) { return Left(ApiClient.handleDioError(e)); } catch (_) { return const Left(Failure.unexpectedError()); }
  }
}
