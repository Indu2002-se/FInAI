import '../../../../app/core/network/dio_client.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> register(RegisterRequest request);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        endpoint: '/auth/login',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await dioClient.post<Map<String, dynamic>>(
        endpoint: '/auth/register',
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post<void>(
        endpoint: '/auth/logout',
      );
    } catch (e) {
      rethrow;
    }
  }
}
