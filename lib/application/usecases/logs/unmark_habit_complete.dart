import '../../../domain/entities/habit_log.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../../domain/value_objects/streak.dart';
import '../../dto/result.dart';

/// Use case: Unmark a habit (remove completion)
class UnmarkHabitComplete {
  final HabitRepository _repository;

  UnmarkHabitComplete(this._repository);

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

      // Check if log exists
      final existingLog = await _repository.getLogForDate(
        habitId: habitId,
        date: targetDate,
      );

      if (existingLog == null) {
        return const Failure('No log found for this date');
      }

      if (!existingLog.isCompleted) {
        return const Failure('Habit is not completed for this date');
      }

      // Delete the log (or mark as incomplete)
      await _repository.deleteLog(
        habitId: habitId,
        date: targetDate,
      );

      // Recalculate streak
      final allLogs = await _repository.getLogsForHabit(habitId);
      final updatedStreak = Streak.calculate(
        habit: habit,
        logs: allLogs,
      );

      return Success(updatedStreak);
    } on Exception catch (e) {
      return Failure('Failed to unmark habit', e);
    }
  }

  /// Unmark habit for today
  Future<Result<Streak>> today(String habitId) async {
    return call(habitId: habitId, date: DateTime.now());
  }

  /// Toggle habit completion (complete if not done, unmark if done)
  Future<Result<Streak>> toggle({
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

      // Toggle completion
      await _repository.toggleHabitCompletion(
        habitId: habitId,
        date: targetDate,
      );

      // Recalculate streak
      final allLogs = await _repository.getLogsForHabit(habitId);
      final updatedStreak = Streak.calculate(
        habit: habit,
        logs: allLogs,
      );

      return Success(updatedStreak);
    } on Exception catch (e) {
      return Failure('Failed to toggle habit', e);
    }
  }

  /// Toggle habit for today
  Future<Result<Streak>> toggleToday(String habitId) async {
    return toggle(habitId: habitId, date: DateTime.now());
  }
}
