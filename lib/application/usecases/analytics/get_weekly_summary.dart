import '../../../domain/repositories/habit_repository.dart';
import '../../dto/result.dart';

/// Weekly summary statistics
class WeeklySummary {
  final int totalHabits;
  final int totalCompletions;
  final int possibleCompletions;
  final double completionRate;
  final Map<int, int> dailyCompletions; // day of week -> count
  final int bestDay;
  final int worstDay;
  final List<String> perfectHabits; // Habits completed all days

  const WeeklySummary({
    required this.totalHabits,
    required this.totalCompletions,
    required this.possibleCompletions,
    required this.completionRate,
    required this.dailyCompletions,
    required this.bestDay,
    required this.worstDay,
    required this.perfectHabits,
  });

  /// Get day name from weekday number
  String getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String get bestDayName => getDayName(bestDay);
  String get worstDayName => getDayName(worstDay);
}

/// Use case: Get weekly summary statistics
class GetWeeklySummary {
  final HabitRepository _repository;

  GetWeeklySummary(this._repository);

  Future<Result<WeeklySummary>> call() async {
    try {
      final now = DateTime.now();

      // Calculate current week (Monday to Sunday)
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Get all active habits
      final habits = await _repository.getActiveHabits();

      if (habits.isEmpty) {
        return const Success(WeeklySummary(
          totalHabits: 0,
          totalCompletions: 0,
          possibleCompletions: 0,
          completionRate: 0.0,
          dailyCompletions: {},
          bestDay: 1,
          worstDay: 1,
          perfectHabits: [],
        ));
      }

      // Calculate statistics
      int totalCompletions = 0;
      int possibleCompletions = 0;
      final dailyCompletions = <int, int>{};
      final habitCompletionCount = <String, int>{};

      for (final habit in habits) {
        habitCompletionCount[habit.id] = 0;

        // Get logs for this week
        final logs = await _repository.getLogsForDateRange(
          habitId: habit.id,
          startDate: startOfWeek,
          endDate: endOfWeek,
        );

        // Count completions per day
        for (var day = startOfWeek;
            day.isBefore(endOfWeek.add(const Duration(days: 1)));
            day = day.add(const Duration(days: 1))) {

          if (!habit.isActiveOnDay(day.weekday)) continue;

          possibleCompletions++;

          final log = logs.where((l) =>
            l.date.year == day.year &&
            l.date.month == day.month &&
            l.date.day == day.day
          ).firstOrNull;

          if (log?.isCompleted ?? false) {
            totalCompletions++;
            habitCompletionCount[habit.id] =
                (habitCompletionCount[habit.id] ?? 0) + 1;

            dailyCompletions[day.weekday] =
                (dailyCompletions[day.weekday] ?? 0) + 1;
          }
        }
      }

      // Find perfect habits (completed all active days this week)
      final perfectHabits = <String>[];
      for (final habit in habits) {
        final activeDaysThisWeek = List.generate(7, (i) => i + 1)
            .where((day) => habit.isActiveOnDay(day))
            .length;

        if (habitCompletionCount[habit.id] == activeDaysThisWeek &&
            activeDaysThisWeek > 0) {
          perfectHabits.add(habit.name);
        }
      }

      // Find best and worst days
      int bestDay = 1;
      int worstDay = 1;
      int maxCompletions = 0;
      int minCompletions = possibleCompletions;

      for (var i = 1; i <= 7; i++) {
        final count = dailyCompletions[i] ?? 0;
        if (count > maxCompletions) {
          maxCompletions = count;
          bestDay = i;
        }
        if (count < minCompletions) {
          minCompletions = count;
          worstDay = i;
        }
      }

      final completionRate = possibleCompletions > 0
          ? (totalCompletions / possibleCompletions) * 100
          : 0.0;

      return Success(WeeklySummary(
        totalHabits: habits.length,
        totalCompletions: totalCompletions,
        possibleCompletions: possibleCompletions,
        completionRate: completionRate,
        dailyCompletions: dailyCompletions,
        bestDay: bestDay,
        worstDay: worstDay,
        perfectHabits: perfectHabits,
      ));
    } on Exception catch (e) {
      return Failure('Failed to generate weekly summary', e);
    }
  }

  /// Get summary for a specific week
  Future<Result<WeeklySummary>> forWeek(DateTime weekStart) async {
    // TODO: Implement custom week range
    return call();
  }
}
