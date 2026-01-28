import '../../../domain/entities/habit_log.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../../domain/value_objects/streak.dart';
import '../../dto/result.dart';

/// Use case: Mark a habit as complete for a specific date
class MarkHabitComplete {
  final HabitRepository _repository;

  MarkHabitComplete(this._repository);

  Future<Result<Streak>> call({
    required String habitId,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();

      // Check if habit exists
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        return const Failure('Habit not found');
      }

      // Check if already completed
      final existingLog = await _repository.getLogForDate(
        habitId: habitId,
        date: targetDate,
      );

      if (existingLog?.isCompleted ?? false) {
        return const Failure('Habit already completed for this date');
      }

      // Create completion log
      final log = HabitLog.completed(
        habitId: habitId,
        date: targetDate,
      );

      await _repository.saveLog(log);

      // Recalculate streak
      final allLogs = await _repository.getLogsForHabit(habitId);
      final updatedStreak = Streak.calculate(
        habit: habit,
        logs: allLogs,
      );

      return Success(updatedStreak);
    } on Exception catch (e) {
      return Failure('Failed to mark habit complete', e);
    }
  }

  /// Mark habit complete for today
  Future<Result<Streak>> today(String habitId) async {
    return call(habitId: habitId, date: DateTime.now());
  }

  /// Batch complete multiple habits for today
  Future<Result<List<Streak>>> batchToday(List<String> habitIds) async {
    try {
      final streaks = <Streak>[];

      for (final habitId in habitIds) {
        final result = await today(habitId);
        if (result is Success<Streak>) {
          streaks.add(result.data);
        }
      }

      return Success(streaks);
    } on Exception catch (e) {
      return Failure('Failed to complete habits', e);
    }
  }
}
