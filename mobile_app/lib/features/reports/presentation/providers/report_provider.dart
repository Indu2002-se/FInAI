import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_model.dart';
import '../../data/repositories/report_repository.dart';

final monthlyReportProvider = FutureProvider.autoDispose.family<MonthlyReportModel, String?>((ref, month) async {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.getMonthlyReport(month: month);
});
