import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';

final wizardRepositoryProvider = Provider<WizardRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return WizardRepository(dioClient: dioClient);
});

class WizardRepository {
  final DioClient dioClient;

  WizardRepository({required this.dioClient});

  /// Saves the wizard profile to the backend.
  /// Uses POST /v1/wizard (mapped to /api/v1/wizard by base URL).
  Future<void> saveWizard(Map<String, dynamic> payload) async {
    await dioClient.post<dynamic>(
      endpoint: '/v1/wizard',
      data: payload,
    );
  }

  /// Triggers full AI analysis using the saved wizard data.
  Future<void> triggerAiAnalysis() async {
    await dioClient.post<dynamic>(
      endpoint: '/v1/ai/analyze',
    );
  }
}
