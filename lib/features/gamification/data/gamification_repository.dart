import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/gamification/data/data_sources/gamification_remote_data_source.dart';
import 'package:mishka_app/features/gamification/data/gamification_dashboard_model.dart';
import 'package:mishka_app/features/gamification/data/models/gamification_collect_result.dart';
import 'package:mishka_app/features/gamification/presentation/screens/gamification_monthly_screen.dart';

class GamificationRepository {
  GamificationRepository({GamificationRemoteDataSource? remote})
      : _remote = remote ?? GamificationRemoteDataSource(ApiService());

  final GamificationRemoteDataSource _remote;

  Future<GamificationDashboardModel> loadWeeklyDashboard() async {
    try {
      return await _remote.getDashboard();
    } catch (_) {
      return GamificationDashboardModel.empty();
    }
  }

  Future<GamificationCollectResult> collectBadge({
    required String badgeCode,
    required String sourceType,
    required String sourceId,
    required String idempotencyKey,
    Map<String, dynamic>? metadata,
  }) {
    return _remote.collectBadge(
      badgeCode: badgeCode,
      sourceType: sourceType,
      sourceId: sourceId,
      idempotencyKey: idempotencyKey,
      metadata: metadata,
    );
  }

  Future<GamificationStreakMonthlyData> loadStreakMonthly(DateTime month) async {
    try {
      return await _remote.getStreakMonthly(month);
    } catch (_) {
      return GamificationStreakMonthlyData.empty(month);
    }
  }

  Future<GamificationProgressMonthlyData> loadProgressMonthly({
    required GamificationMonthlySection section,
    required DateTime month,
  }) async {
    try {
      return await _remote.getProgressMonthly(section: section, month: month);
    } catch (_) {
      return GamificationProgressMonthlyData.empty(month);
    }
  }

  Future<GamificationAiToolsMonthlyData> loadAiToolsMonthly(DateTime month) async {
    try {
      return await _remote.getAiToolsMonthly(month);
    } catch (_) {
      return GamificationAiToolsMonthlyData.empty(month);
    }
  }
}
