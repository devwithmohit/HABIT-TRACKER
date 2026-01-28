import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../../domain/value_objects/streak.dart';
import '../../dto/habit_with_streak.dart';
import '../../dto/result.dart';

/// Use case: Calculate streak for a habit
class CalculateStreak {
  final HabitRepository _repository;

  CalculateStreak(this._repository);

  /// Calculate current streak for a single habit
  Future<Result<Streak>> call(String habitId) async {
    try {
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        return const Failure('Habit not found');
      }

      final logs = await _repository.getLogsForHabit(habitId);
      final streak = Streak.calculate(habit: habit, logs: logs);

      return Success(streak);
    } on Exception catch (e) {
      return Failure('Failed to calculate streak', e);
    }
  }

  /// Calculate streaks for all active habits
  Future<Result<List<HabitWithStreak>>> forAllHabits() async {
    try {
      final habits = await _repository.getActiveHabits();
      final habitsWithStreaks = <HabitWithStreak>[];

      for (final habit in habits) {
        final logs = await _repository.getLogsForHabit(habit.id);
        final streak = Streak.calculate(habit: habit, logs: logs);
        habitsWithStreaks.add(HabitWithStreak(habit: habit, streak: streak));
      }

      return Success(habitsWithStreaks);
    } on Exception catch (e) {
      return Failure('Failed to calculate streaks', e);
    }
  }

  /// Calculate streaks for habits active today
  Future<Result<List<HabitWithStreak>>> forTodayHabits() async {
    try {
      final habits = await _repository.getActiveHabits();
      final todayWeekday = DateTime.now().weekday;

      final todayHabits = habits
          .where((h) => h.activeDays.contains(todayWeekday))
          .toList();

      final habitsWithStreaks = <HabitWithStreak>[];

      for (final habit in todayHabits) {
        final logs = await _repository.getLogsForHabit(habit.id);
        final streak = Streak.calculate(habit: habit, logs: logs);
        habitsWithStreaks.add(HabitWithStreak(habit: habit, streak: streak));
      }

      return Success(habitsWithStreaks);
    } on Exception catch (e) {
      return Failure('Failed to calculate today\'s streaks', e);
    }
  }

  /// Get habits with longest streaks
  Future<Result<List<HabitWithStreak>>> topStreaks({int limit = 5}) async {
    try {
      final result = await forAllHabits();
      if (result is Failure) return result;

      final habitsWithStreaks = (result as Success<List<HabitWithStreak>>).data;

      // Sort by current streak descending
      habitsWithStreaks.sort((a, b) => b.streak.current.compareTo(a.streak.current));

      // Take top N
      final topHabits = habitsWithStreaks.take(limit).toList();

      return Success(topHabits);
    } on Exception catch (e) {
      return Failure('Failed to get top streaks', e);
    }
  }

  /// Get habits at risk (active today but not completed)
  Future<Result<List<HabitWithStreak>>> atRisk() async {
    try {
      final result = await forTodayHabits();
      if (result is Failure) return result;

      final habitsWithStreaks = (result as Success<List<HabitWithStreak>>).data;

      // Filter habits that need attention
      final atRisk = habitsWithStreaks
          .where((h) => h.needsAttention && h.streak.current > 0)
          .toList();

      // Sort by current streak descending (prioritize longer streaks)
      atRisk.sort((a, b) => b.streak.current.compareTo(a.streak.current));

      return Success(atRisk);
    } on Exception catch (e) {
      return Failure('Failed to get at-risk habits', e);
    }
  }
}
