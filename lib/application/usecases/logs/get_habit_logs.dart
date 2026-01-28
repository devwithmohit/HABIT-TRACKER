import '../../../domain/entities/habit_log.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../dto/result.dart';

/// Use case: Get habit logs with various filters
class GetHabitLogs {
  final HabitRepository _repository;

  GetHabitLogs(this._repository);

  /// Get all logs for a habit
  Future<Result<List<HabitLog>>> call(String habitId) async {
    try {
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        return const Failure('Habit not found');
      }

      final logs = await _repository.getLogsForHabit(habitId);

      // Sort by date descending (newest first)
      logs.sort((a, b) => b.date.compareTo(a.date));

      return Success(logs);
    } on Exception catch (e) {
      return Failure('Failed to load habit logs', e);
    }
  }

  /// Get logs for a specific date range
  Future<Result<List<HabitLog>>> forDateRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        return const Failure('Habit not found');
      }

      final logs = await _repository.getLogsForDateRange(
        habitId: habitId,
        startDate: startDate,
        endDate: endDate,
      );

      logs.sort((a, b) => b.date.compareTo(a.date));

      return Success(logs);
    } on Exception catch (e) {
      return Failure('Failed to load logs for date range', e);
    }
  }

  /// Get logs for current month
  Future<Result<List<HabitLog>>> forCurrentMonth(String habitId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return forDateRange(
      habitId: habitId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  /// Get logs for current week (Monday to Sunday)
  Future<Result<List<HabitLog>>> forCurrentWeek(String habitId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return forDateRange(
      habitId: habitId,
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
  }

  /// Get only completed logs
  Future<Result<List<HabitLog>>> completedOnly(String habitId) async {
    try {
      final result = await call(habitId);
      if (result is Failure) return result;

      final logs = (result as Success<List<HabitLog>>).data;
      final completed = logs.where((log) => log.isCompleted).toList();

      return Success(completed);
    } on Exception catch (e) {
      return Failure('Failed to load completed logs', e);
    }
  }

  /// Get log for today
  Future<Result<HabitLog?>> forToday(String habitId) async {
    try {
      final log = await _repository.getLogForDate(
        habitId: habitId,
        date: DateTime.now(),
      );

      return Success(log);
    } on Exception catch (e) {
      return Failure('Failed to load today\'s log', e);
    }
  }

  /// Get all today's logs (across all habits)
  Future<Result<List<HabitLog>>> allForToday() async {
    try {
      final logs = await _repository.getTodayLogs();
      return Success(logs);
    } on Exception catch (e) {
      return Failure('Failed to load today\'s logs', e);
    }
  }
}
