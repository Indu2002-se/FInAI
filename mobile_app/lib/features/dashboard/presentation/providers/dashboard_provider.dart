import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/repositories/dashboard_repository.dart';

final dashboardFutureProvider = FutureProvider.autoDispose<DashboardModel>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.getDashboard();
});
