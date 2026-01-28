import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/dto/result.dart';
import '../../application/usecases/logs/get_habit_logs.dart';
import '../../application/usecases/logs/mark_habit_complete.dart';
import '../../application/usecases/logs/unmark_habit_complete.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/value_objects/streak.dart';

/// State for habit logs
class HabitLogsState {
  final Map<String, List<HabitLog>> logsByHabit; // habitId -> logs
  final bool isLoading;
  final String? error;

  const HabitLogsState({
    this.logsByHabit = const {},
    this.isLoading = false,
    this.error,
  });

  HabitLogsState copyWith({
    Map<String, List<HabitLog>>? logsByHabit,
    bool? isLoading,
    String? error,
  }) {
    return HabitLogsState(
      logsByHabit: logsByHabit ?? this.logsByHabit,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get logs for a specific habit
  List<HabitLog> getLogsForHabit(String habitId) {
    return logsByHabit[habitId] ?? [];
  }

  /// Check if habit is completed today
  bool isCompletedToday(String habitId) {
    final logs = getLogsForHabit(habitId);
    final today = HabitLog.normalizeDate(DateTime.now());

    return logs.any((log) =>
      log.date.isAtSameMomentAs(today) && log.isCompleted
    );
  }
}

/// Habit logs state notifier
class HabitLogsNotifier extends StateNotifier<HabitLogsState> {
  final GetHabitLogs _getHabitLogs;
  final MarkHabitComplete _markHabitComplete;
  final UnmarkHabitComplete _unmarkHabitComplete;

  HabitLogsNotifier(
    this._getHabitLogs,
    this._markHabitComplete,
    this._unmarkHabitComplete,
  ) : super(const HabitLogsState());

  /// Load logs for a specific habit
  Future<void> loadLogsForHabit(String habitId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getHabitLogs(habitId);

    if (result.isSuccess) {
      final logs = (result as Success<List<HabitLog>>).data;
      final updatedLogs = Map<String, List<HabitLog>>.from(state.logsByHabit);
      updatedLogs[habitId] = logs;

      state = state.copyWith(
        logsByHabit: updatedLogs,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorOrNull,
      );
    }
  }

  /// Load logs for current week for a habit
  Future<void> loadWeekLogsForHabit(String habitId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getHabitLogs.forCurrentWeek(habitId);

    if (result.isSuccess) {
      final logs = (result as Success<List<HabitLog>>).data;
      final updatedLogs = Map<String, List<HabitLog>>.from(state.logsByHabit);
      updatedLogs[habitId] = logs;

      state = state.copyWith(
        logsByHabit: updatedLogs,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorOrNull,
      );
    }
  }

  /// Toggle habit completion for today
  Future<Streak?> toggleHabitToday(String habitId) async {
    final result = await _unmarkHabitComplete.toggleToday(habitId);

    if (result.isSuccess) {
      // Reload logs for this habit
      await loadLogsForHabit(habitId);
      return (result as Success<Streak>).data;
    } else {
      state = state.copyWith(error: result.errorOrNull);
      return null;
    }
  }

  /// Mark habit complete for today
  Future<Streak?> markCompleteToday(String habitId) async {
    final result = await _markHabitComplete.today(habitId);

    if (result.isSuccess) {
      await loadLogsForHabit(habitId);
      return (result as Success<Streak>).data;
    } else {
      state = state.copyWith(error: result.errorOrNull);
      return null;
    }
  }

  /// Unmark habit for today
  Future<Streak?> unmarkToday(String habitId) async {
    final result = await _unmarkHabitComplete.today(habitId);

    if (result.isSuccess) {
      await loadLogsForHabit(habitId);
      return (result as Success<Streak>).data;
    } else {
      state = state.copyWith(error: result.errorOrNull);
      return null;
    }
  }

  /// Mark habit complete for specific date
  Future<Streak?> markComplete(String habitId, DateTime date) async {
    final result = await _markHabitComplete(habitId: habitId, date: date);

    if (result.isSuccess) {
      await loadLogsForHabit(habitId);
      return (result as Success<Streak>).data;
    } else {
      state = state.copyWith(error: result.errorOrNull);
      return null;
    }
  }

  /// Load all today's logs
  Future<void> loadTodayLogs() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getHabitLogs.allForToday();

    if (result.isSuccess) {
      final logs = (result as Success<List<HabitLog>>).data;

      // Group logs by habit ID
      final groupedLogs = <String, List<HabitLog>>{};
      for (final log in logs) {
        if (!groupedLogs.containsKey(log.habitId)) {
          groupedLogs[log.habitId] = [];
        }
        groupedLogs[log.habitId]!.add(log);
      }

      state = state.copyWith(
        logsByHabit: groupedLogs,
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.errorOrNull,
      );
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for habit logs notifier
/// Note: Requires DI setup
// final habitLogsProvider = StateNotifierProvider<HabitLogsNotifier, HabitLogsState>((ref) {
//   return HabitLogsNotifier(
//     ref.read(getHabitLogsProvider),
//     ref.read(markHabitCompleteProvider),
//     ref.read(unmarkHabitCompleteProvider),
//   );
// });
