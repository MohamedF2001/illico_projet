import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../errors/failures.dart';
import 'package:fpdart/fpdart.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');
        }
        return handler.next(error);
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      error: true,
    ));
  }

  static Failure handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const Failure.networkError();
    }
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;
    if (statusCode == 401) return const Failure.unauthorized();
    if (statusCode == 404) return const Failure.notFound();
    if (statusCode == 400 || statusCode == 422) {
      final errors = e.response?.data?['errors'];
      if (errors != null) {
        return Failure.validationError(errors: {'detail': errors.toString()});
      }
      return Failure.serverError(message: message ?? 'Données invalides.');
    }
    return Failure.serverError(message: message ?? 'Erreur serveur.');
  }
}

final apiClient = ApiClient();
