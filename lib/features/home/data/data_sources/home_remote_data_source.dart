import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/home/data/models/home_tip_model.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource(this._api);

  final ApiService _api;

  Future<DailyStreakModel> getDailyStreak() async {
    final env = await _api.get<DailyStreakModel>(
      ApiEndpoints.dailyStreaks,
      dataFromJson: (raw) => DailyStreakModel.fromJson(raw),
    );
    return env.data ?? const DailyStreakModel(days: 0);
  }

  Future<List<HomeTipModel>> getTips() async {
    final env = await _api.get<List<HomeTipModel>>(
      ApiEndpoints.tips,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => HomeTipModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<TaskApiModel>> getUpcomingTasks() async {
    final env = await _api.get<List<TaskApiModel>>(
      ApiEndpoints.tasks,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        final tasks = list
            .whereType<Map>()
            .map((e) => TaskApiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        final now = DateTime.now();
        tasks.sort((a, b) {
          final aTime = a.deadline ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.deadline ?? DateTime.fromMillisecondsSinceEpoch(0);
          return aTime.compareTo(bTime);
        });
        return tasks.where((task) {
          final deadline = task.deadline;
          final completed = task.completed ?? false;
          if (deadline == null) return false;
          return !completed && !deadline.isBefore(now);
        }).toList();
      },
    );
    return env.data ?? const [];
  }
}
