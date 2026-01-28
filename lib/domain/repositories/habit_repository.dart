import '../entities/habit.dart';
import '../entities/habit_log.dart';

/// Repository interface for habit operations
/// Implementation will be in data layer using Hive
abstract class HabitRepository {
  /// Get all habits (including archived if specified)
  Future<List<Habit>> getAllHabits({bool includeArchived = false});

  /// Get a single habit by ID
  Future<Habit?> getHabitById(String id);

  /// Get active (non-archived) habits
  Future<List<Habit>> getActiveHabits();

  /// Create a new habit
  Future<void> createHabit(Habit habit);

  /// Update an existing habit
  Future<void> updateHabit(Habit habit);

  /// Delete a habit permanently
  Future<void> deleteHabit(String id);

  /// Archive/unarchive a habit
  Future<void> archiveHabit(String id, bool isArchived);

  /// Get all logs for a specific habit
  Future<List<HabitLog>> getLogsForHabit(String habitId);

  /// Get logs for a specific date range
  Future<List<HabitLog>> getLogsForDateRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get log for a specific habit and date
  Future<HabitLog?> getLogForDate({
    required String habitId,
    required DateTime date,
  });

  /// Save/update a habit log
  Future<void> saveLog(HabitLog log);

  /// Delete a habit log
  Future<void> deleteLog({
    required String habitId,
    required DateTime date,
  });

  /// Toggle habit completion for today
  Future<void> toggleHabitCompletion({
    required String habitId,
    required DateTime date,
  });

  /// Get completion count for a habit
  Future<int> getCompletionCount(String habitId);

  /// Check if habit is completed on a specific date
  Future<bool> isHabitCompletedOnDate({
    required String habitId,
    required DateTime date,
  });

  /// Get all logs for today
  Future<List<HabitLog>> getTodayLogs();

  /// Delete all data (for app reset)
  Future<void> clearAllData();
}
