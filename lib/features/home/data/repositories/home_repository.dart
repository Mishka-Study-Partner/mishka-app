import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/home/data/models/home_tip_model.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';

class HomeRepository {
  HomeRepository({HomeRemoteDataSource? remote})
      : _remote = remote ?? HomeRemoteDataSource(ApiService());

  final HomeRemoteDataSource _remote;

  Future<DailyStreakModel> getDailyStreak() => _remote.getDailyStreak();

  Future<DailyStreakModel?> pingDailyStreak() => _remote.pingDailyStreak();

  Future<DailyStreakModel> freezeStreakDay({required String date}) =>
      _remote.freezeStreakDay(date: date);

  Future<List<HomeTipModel>> getTips() => _remote.getTips();

  Future<List<TaskApiModel>> getUpcomingTasks() => _remote.getUpcomingTasks();
}
