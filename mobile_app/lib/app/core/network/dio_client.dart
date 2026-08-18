import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';
import '../storage/secure_storage_service.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return DioClient(secureStorage: secureStorage);
});

class DioClient {
  final SecureStorageService secureStorage;
  late final Dio _dio;

  DioClient({required this.secureStorage}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        contentType: AppConstants.contentType,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await secureStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to add authorization header',
        ),
      );
    }
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      // Token expired or invalid
      await secureStorage.clearToken();
      // TODO: Navigate to login
    }
    handler.next(error);
  }

  Future<T> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleException(e);
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  Future<T> post<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleException(e);
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  Future<T> put<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleException(e);
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  Future<T> delete<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete<T>(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data as T;
    } on DioException catch (e) {
      throw _handleException(e);
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred',
        originalException: e,
      );
    }
  }

  AppException _handleException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TimeoutException(
          message: 'Request timeout. Please try again.',
          originalException: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.data?['message'] ?? 'An error occurred';
        final code = error.response?.data?['code'];

        switch (statusCode) {
          case 400:
            return BadRequestException(
              message: message,
              code: code,
              originalException: error,
            );
          case 401:
            return UnauthorizedException(
              message: message,
              code: code,
              originalException: error,
            );
          case 403:
            return ForbiddenException(
              message: message,
              code: code,
              originalException: error,
            );
          case 404:
            return NotFoundException(
              message: message,
              code: code,
              originalException: error,
            );
          case 500:
          case 502:
          case 503:
            return ServerException(
              message: message,
              code: code,
              originalException: error,
            );
          default:
            return UnknownException(
              message: message,
              code: code,
              originalException: error,
            );
        }

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request cancelled',
          originalException: error,
        );

      case DioExceptionType.unknown:
        if (error.error is Exception) {
          return NetworkException(
            message: 'Network error: ${error.message}',
            originalException: error,
          );
        }
        return UnknownException(
          message: 'An unexpected error occurred',
          originalException: error,
        );

      default:
        return UnknownException(
          message: 'An unexpected error occurred',
          originalException: error,
        );
    }
  }
}
