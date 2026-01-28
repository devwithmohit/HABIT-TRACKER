import '../entities/habit.dart';
import '../entities/habit_log.dart';

/// Value object for calculating and managing habit streaks
class Streak {
  final int current;
  final int longest;
  final DateTime? lastCompletedDate;
  final bool isActiveToday;

  const Streak({
    required this.current,
    required this.longest,
    this.lastCompletedDate,
    this.isActiveToday = false,
  });

  /// Empty streak for new habits
  factory Streak.empty() {
    return const Streak(
      current: 0,
      longest: 0,
      lastCompletedDate: null,
      isActiveToday: false,
    );
  }

  /// Calculate streak from habit logs
  /// Respects habit's active days (e.g., skip weekends if not configured)
  static Streak calculate({
    required Habit habit,
    required List<HabitLog> logs,
  }) {
    if (logs.isEmpty) {
      return Streak.empty();
    }

    // Sort logs by date descending (newest first)
    final sortedLogs = List<HabitLog>.from(logs)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Filter only completed logs
    final completedLogs =
        sortedLogs.where((log) => log.isCompleted).toList();

    if (completedLogs.isEmpty) {
      return Streak.empty();
    }

    final today = HabitLog.normalizeDate(DateTime.now());
    final lastCompleted = completedLogs.first.date;

    // Check if completed today
    final isActiveToday = lastCompleted.isAtSameMomentAs(today);

    // Calculate current streak
    int currentStreak = 0;
    DateTime checkDate = today;

    // Start from today if completed, otherwise yesterday
    if (!isActiveToday) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    // Count backwards from most recent completion
    while (true) {
      // Skip days not in habit's active days
      if (!habit.isActiveOnDay(checkDate.weekday)) {
        checkDate = checkDate.subtract(const Duration(days: 1));
        continue;
      }

      // Check if this date has a completion
      final hasCompletion = completedLogs.any(
        (log) => log.date.isAtSameMomentAs(checkDate),
      );

      if (hasCompletion) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }

      // Safety: don't go back more than 1 year
      if (checkDate.isBefore(today.subtract(const Duration(days: 365)))) {
        break;
      }
    }

    // Calculate longest streak (historical)
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? previousDate;

    for (final log in completedLogs.reversed) {
      if (previousDate == null) {
        tempStreak = 1;
      } else {
        final daysBetween = log.date.difference(previousDate).inDays;

        // Check if dates are consecutive considering active days
        if (_areConsecutiveActiveDays(
          previousDate,
          log.date,
          habit.activeDays,
        )) {
          tempStreak++;
        } else {
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
      }
      previousDate = log.date;
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // Longest streak should be at least as long as current
    longestStreak = longestStreak > currentStreak ? longestStreak : currentStreak;

    return Streak(
      current: currentStreak,
      longest: longestStreak,
      lastCompletedDate: lastCompleted,
      isActiveToday: isActiveToday,
    );
  }

  /// Check if two dates are consecutive considering only active days
  static bool _areConsecutiveActiveDays(
    DateTime date1,
    DateTime date2,
    List<int> activeDays,
  ) {
    DateTime checkDate = date1.add(const Duration(days: 1));

    // Allow up to 7 days gap (full week) to find next active day
    for (int i = 0; i < 7; i++) {
      if (checkDate.isAtSameMomentAs(date2)) {
        return true;
      }

      // Skip to next active day
      if (!activeDays.contains(checkDate.weekday)) {
        checkDate = checkDate.add(const Duration(days: 1));
        continue;
      } else {
        // Found an active day but it's not date2
        return false;
      }
    }

    return false;
  }

  /// Check if streak is at risk (not completed today and it's an active day)
  bool isAtRisk(Habit habit) {
    return !isActiveToday &&
           habit.isActiveToday() &&
           current > 0;
  }

  /// Get motivational status
  String getStatus() {
    if (current == 0) return 'Start your streak!';
    if (current >= 365) return 'Legendary! 🔥';
    if (current >= 180) return 'Half year strong! 💪';
    if (current >= 90) return 'Quarter year! 🎯';
    if (current >= 30) return 'Month streak! 🚀';
    if (current >= 7) return 'Week streak! ⭐';
    if (current >= 3) return 'Building momentum! 👍';
    return 'Keep going! 💫';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Streak &&
          runtimeType == other.runtimeType &&
          current == other.current &&
          longest == other.longest &&
          lastCompletedDate == other.lastCompletedDate &&
          isActiveToday == other.isActiveToday;

  @override
  int get hashCode =>
      current.hashCode ^
      longest.hashCode ^
      lastCompletedDate.hashCode ^
      isActiveToday.hashCode;

  @override
  String toString() {
    return 'Streak(current: $current, longest: $longest, lastCompletedDate: $lastCompletedDate, isActiveToday: $isActiveToday)';
  }
}
