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
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'An error occurred while processing data: $e',
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
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'An error occurred while processing data: $e',
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
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'An error occurred while processing data: $e',
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
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'An error occurred while processing data: $e',
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
          message: 'Request timeout. Please check your network connection.',
          originalException: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Cannot connect to backend server. Please check your network or server URL.',
          originalException: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        String message = 'An error occurred';
        String? code;

        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;

          if (data.containsKey('validationErrors') &&
              data['validationErrors'] is Map<String, dynamic>) {
            final validationMap =
                data['validationErrors'] as Map<String, dynamic>;
            final fieldErrors = validationMap.entries
                .map((e) => '${e.value}')
                .join(', ');
            if (fieldErrors.isNotEmpty) {
              message = fieldErrors;
            } else {
              message = data['message']?.toString() ?? message;
            }
          } else if (data.containsKey('message') && data['message'] != null) {
            message = data['message'].toString();
          } else if (data.containsKey('error') && data['error'] != null) {
            message = data['error'].toString();
          }

          code = data['code']?.toString();
        } else if (error.response?.data is String &&
            (error.response!.data as String).isNotEmpty) {
          message = error.response!.data as String;
        }

        switch (statusCode) {
          case 400:
          case 409:
          case 422:
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
      default:
        if (error.error != null) {
          return NetworkException(
            message: 'Network error: ${error.error}',
            originalException: error,
          );
        }
        return UnknownException(
          message: error.message ?? 'An unexpected error occurred',
          originalException: error,
        );
    }
  }
}
