import '../../../domain/repositories/habit_repository.dart';
import '../../../domain/value_objects/streak.dart';
import '../../dto/habit_with_streak.dart';
import '../../dto/result.dart';

/// Use case: Check which habits are due today
class CheckHabitDueToday {
  final HabitRepository _repository;

  CheckHabitDueToday(this._repository);

  /// Check if a specific habit is due today
  Future<Result<bool>> call(String habitId) async {
    try {
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        return const Failure('Habit not found');
      }

      final isDue = habit.isActiveToday();
      return Success(isDue);
    } on Exception catch (e) {
      return Failure('Failed to check if habit is due', e);
    }
  }

  /// Get all habits due today
  Future<Result<List<HabitWithStreak>>> allDueToday() async {
    try {
      final habits = await _repository.getActiveHabits();
      final todayWeekday = DateTime.now().weekday;

      final dueHabits = habits
          .where((h) => h.activeDays.contains(todayWeekday))
          .toList();

      // Calculate streaks for due habits
      final habitsWithStreaks = <HabitWithStreak>[];

      for (final habit in dueHabits) {
        final logs = await _repository.getLogsForHabit(habit.id);
        final streak = Streak.calculate(habit: habit, logs: logs);
        habitsWithStreaks.add(HabitWithStreak(habit: habit, streak: streak));
      }

      return Success(habitsWithStreaks);
    } on Exception catch (e) {
      return Failure('Failed to get habits due today', e);
    }
  }

  /// Get incomplete habits due today
  Future<Result<List<HabitWithStreak>>> incompleteDueToday() async {
    try {
      final result = await allDueToday();
      if (result is Failure) return result;

      final dueHabits = (result as Success<List<HabitWithStreak>>).data;

      // Filter out already completed habits
      final incomplete = dueHabits
          .where((h) => !h.streak.isActiveToday)
          .toList();

      return Success(incomplete);
    } on Exception catch (e) {
      return Failure('Failed to get incomplete habits', e);
    }
  }

  /// Get completed habits for today
  Future<Result<List<HabitWithStreak>>> completedToday() async {
    try {
      final result = await allDueToday();
      if (result is Failure) return result;

      final dueHabits = (result as Success<List<HabitWithStreak>>).data;

      // Filter completed habits
      final completed = dueHabits
          .where((h) => h.streak.isActiveToday)
          .toList();

      return Success(completed);
    } on Exception catch (e) {
      return Failure('Failed to get completed habits', e);
    }
  }

  /// Get today's completion statistics
  Future<Result<TodayStats>> getTodayStats() async {
    try {
      final allResult = await allDueToday();
      if (allResult is Failure) {
        final failure = allResult as Failure<List<HabitWithStreak>>;
        return Failure(failure.message, failure.exception);
      }

      final dueHabits = (allResult as Success<List<HabitWithStreak>>).data;

      final total = dueHabits.length;
      final completed = dueHabits.where((h) => h.streak.isActiveToday).length;
      final remaining = total - completed;
      final completionRate = total > 0 ? (completed / total) * 100 : 0.0;

      return Success(TodayStats(
        totalDue: total,
        completed: completed,
        remaining: remaining,
        completionRate: completionRate,
      ));
    } on Exception catch (e) {
      return Failure('Failed to get today\'s stats', e);
    }
  }
}

/// Today's statistics
class TodayStats {
  final int totalDue;
  final int completed;
  final int remaining;
  final double completionRate;

  const TodayStats({
    required this.totalDue,
    required this.completed,
    required this.remaining,
    required this.completionRate,
  });

  bool get allComplete => remaining == 0 && totalDue > 0;
  bool get noneComplete => completed == 0;
  bool get partialComplete => completed > 0 && remaining > 0;
}
