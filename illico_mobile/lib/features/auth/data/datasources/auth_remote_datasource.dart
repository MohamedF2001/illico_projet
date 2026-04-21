import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _api;
  AuthRemoteDataSource(this._api);

  Future<Either<Failure, Map<String, dynamic>>> _login(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _api.dio.post(path, data: body);
      return Right(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      return Left(ApiClient.handleDioError(e));
    } catch (_) {
      return const Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> loginAdmin({
    required String email,
    required String motDePasse,
  }) => _login('/auth/admin/login', {'email': email, 'motDePasse': motDePasse});

  Future<Either<Failure, Map<String, dynamic>>> loginClient({
    required String telephone,
    required String codePin,
  }) => _login('/auth/client/login', {
    'telephone': telephone,
    'codePin': codePin,
  });

  Future<Either<Failure, Map<String, dynamic>>> loginLivreur({
    required String telephone,
    required String motDePasse,
  }) => _login('/auth/livreur/login', {
    'telephone': telephone,
    'motDePasse': motDePasse,
  });

  Future<Either<Failure, Map<String, dynamic>>> loginPoint({
    required String telephone,
    required String motDePasse,
  }) => _login('/auth/point/login', {
    'telephone': telephone,
    'motDePasse': motDePasse,
  });

  Future<Either<Failure, Map<String, dynamic>>> initClientRegister({
    required String telephone,
  }) async {
    try {
      final res = await _api.dio.post(
        '/auth/client/register?action=init',
        data: {'telephone': telephone},
      );
      return Right(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      return Left(ApiClient.handleDioError(e));
    } catch (_) {
      return const Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, UserModel>> registerClient(
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _api.dio.post('/auth/client/register', data: body);
      return Right(
        UserModel.fromJson(res.data['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(ApiClient.handleDioError(e));
    } catch (_) {
      return const Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, UserModel>> registerLivreur(
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _api.dio.post('/auth/livreur/register', data: body);
      return Right(
        UserModel.fromJson(res.data['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(ApiClient.handleDioError(e));
    } catch (_) {
      return const Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, UserModel>> registerAdmin(
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _api.dio.post('/auth/admin/register', data: body);
      return Right(
        UserModel.fromJson(res.data['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(ApiClient.handleDioError(e));
    } catch (_) {
      return const Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, UserModel>> registerPoint(
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _api.dio.post('/auth/point/register', data: body);
      return Right(
        UserModel.fromJson(res.data['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(ApiClient.handleDioError(e));
    } catch (_) {
      return const Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, UserModel>> getProfile() async {
    try {
      final res = await _api.dio.get('/auth/profile');
      return Right(
        UserModel.fromJson(res.data['data'] as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Left(ApiClient.handleDioError(e));
    } catch (_) {
      return const Left(Failure.unexpectedError());
    }
  }

  Future<Either<Failure, String>> uploadProfilePhoto(
    dynamic fileData,
    bool isWeb,
  ) async {
    try {
      final formData = FormData();
      if (isWeb) {
        formData.files.add(
          MapEntry(
            'photo',
            MultipartFile.fromBytes(
              fileData as List<int>,
              filename: 'photo.png',
            ),
          ),
        );
      } else {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(
              fileData as String,
              filename: 'photo.jpg',
            ),
          ),
        );
      }
      final res = await _api.dio.post('/auth/profile/photo', data: formData);
      return Right(res.data['data']['photoProfil'] as String);
    } on DioException catch (e) {
      return Left(ApiClient.handleDioError(e));
    } catch (_) {
      return const Left(Failure.unexpectedError());
    }
  }
}
