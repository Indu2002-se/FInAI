import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProfileRepository(dioClient: dioClient);
});

class ProfileRepository {
  final DioClient dioClient;

  ProfileRepository({required this.dioClient});

  Future<UserProfileModel> getProfile() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/profile',
    );
    final data = response['data'] as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }

  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      endpoint: '/v1/profile',
      data: profile.toJson(),
    );
    final data = response['data'] as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }

  Future<UserProfileModel> completeOnboarding(UserProfileModel profile) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/profile/onboarding',
      data: profile.toJson(),
    );
    final data = response['data'] as Map<String, dynamic>;
    return UserProfileModel.fromJson(data);
  }
}
