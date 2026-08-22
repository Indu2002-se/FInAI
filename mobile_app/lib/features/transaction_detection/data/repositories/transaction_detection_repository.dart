import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/core/network/dio_client.dart';
import '../models/detected_transaction.dart';
import '../models/detection_settings.dart';

final transactionDetectionRepositoryProvider = Provider<TransactionDetectionRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return TransactionDetectionRepository(dioClient: dioClient);
});

class TransactionDetectionRepository {
  final DioClient dioClient;

  TransactionDetectionRepository({required this.dioClient});

  Future<List<DetectedTransactionModel>> getPendingTransactions() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected/pending',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => DetectedTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<DetectedTransactionModel>> getAllDetectedTransactions() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected',
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => DetectedTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DetectedTransactionModel> getDetectedTransactionById(int id) async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected/',
    );
    return DetectedTransactionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DetectedTransactionModel> recordDetectedTransaction(DetectedTransactionModel item) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected',
      data: item.toJson(),
    );
    return DetectedTransactionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<DetectedTransactionModel>> recordBatchDetectedTransactions(
      List<DetectedTransactionModel> items) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected/batch',
      data: {
        'transactions': items.map((e) => e.toJson()).toList(),
      },
    );
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((e) => DetectedTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DetectedTransactionModel> updateDetectedTransaction(
      int id, DetectedTransactionModel item) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected/',
      data: item.toJson(),
    );
    return DetectedTransactionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DetectedTransactionModel> confirmTransaction(
      int id, ConfirmTransactionPayload payload) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected//confirm',
      data: payload.toJson(),
    );
    return DetectedTransactionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DetectedTransactionModel> ignoreTransaction(int id) async {
    final response = await dioClient.post<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected//ignore',
    );
    return DetectedTransactionModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DetectionSettingsModel> getSettings() async {
    final response = await dioClient.get<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected/settings',
    );
    return DetectionSettingsModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DetectionSettingsModel> updateSettings(DetectionSettingsModel settings) async {
    final response = await dioClient.put<Map<String, dynamic>>(
      endpoint: '/v1/transactions/detected/settings',
      data: settings.toJson(),
    );
    return DetectionSettingsModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
