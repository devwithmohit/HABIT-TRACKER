import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/dto/habit_with_streak.dart';
import '../../application/dto/result.dart';
import '../../application/usecases/habits/create_habit.dart';
import '../../application/usecases/habits/delete_habit.dart';
import '../../application/usecases/habits/get_all_habits.dart';
import '../../application/usecases/habits/update_habit.dart';
import '../../application/usecases/analytics/calculate_streak.dart';
import '../../domain/entities/habit.dart';

/// State for habits with loading/error handling
class HabitsState {
  final List<HabitWithStreak> habits;
  final bool isLoading;
  final String? error;

  const HabitsState({
    this.habits = const [],
    this.isLoading = false,
    this.error,
  });

  HabitsState copyWith({
    List<HabitWithStreak>? habits,
    bool? isLoading,
    String? error,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Habits state notifier
class HabitsNotifier extends StateNotifier<HabitsState> {
  final GetAllHabits _getAllHabits;
  final CreateHabit _createHabit;
  final UpdateHabit _updateHabit;
  final DeleteHabit _deleteHabit;
  final CalculateStreak _calculateStreak;

  HabitsNotifier(
    this._getAllHabits,
    this._createHabit,
    this._updateHabit,
    this._deleteHabit,
    this._calculateStreak,
  ) : super(const HabitsState());

  /// Load all active habits with streaks
  Future<void> loadHabits() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _calculateStreak.forAllHabits();

    state = result.map(
      (habits) => state.copyWith(habits: habits, isLoading: false),
    ) as HabitsState? ?? state.copyWith(
      isLoading: false,
      error: result.errorOrNull ?? 'Failed to load habits',
    );
  }

  /// Load only habits active today
  Future<void> loadTodayHabits() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _calculateStreak.forTodayHabits();

    state = result.map(
      (habits) => state.copyWith(habits: habits, isLoading: false),
    ) as HabitsState? ?? state.copyWith(
      isLoading: false,
      error: result.errorOrNull ?? 'Failed to load today\'s habits',
    );
  }

  /// Create a new habit
  Future<bool> createHabit({
    required String id,
    required String name,
    required String icon,
    required String color,
    required List<int> activeDays,
  }) async {
    final result = await _createHabit(
      id: id,
      name: name,
      icon: icon,
      color: color,
      activeDays: activeDays,
    );

    if (result.isSuccess) {
      await loadHabits();
      return true;
    } else {
      state = state.copyWith(error: result.errorOrNull);
      return false;
    }
  }

  /// Update an existing habit
  Future<bool> updateHabit(Habit habit) async {
    final result = await _updateHabit(habit);

    if (result.isSuccess) {
      await loadHabits();
      return true;
    } else {
      state = state.copyWith(error: result.errorOrNull);
      return false;
    }
  }

  /// Delete a habit
  Future<bool> deleteHabit(String habitId) async {
    final result = await _deleteHabit(habitId);

    if (result.isSuccess) {
      await loadHabits();
      return true;
    } else {
      state = state.copyWith(error: result.errorOrNull);
      return false;
    }
  }

  /// Archive a habit
  Future<bool> archiveHabit(String habitId) async {
    final result = await _deleteHabit.archive(habitId);

    if (result.isSuccess) {
      await loadHabits();
      return true;
    } else {
      state = state.copyWith(error: result.errorOrNull);
      return false;
    }
  }

  /// Refresh habits (pull to refresh)
  Future<void> refresh() => loadHabits();

  /// Get habit by ID
  HabitWithStreak? getHabitById(String id) {
    try {
      return state.habits.firstWhere((h) => h.habit.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for habits notifier
/// Note: This requires dependency injection setup in core/di
/// For now, this is a placeholder showing the structure
// final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
//   return HabitsNotifier(
//     ref.read(getAllHabitsProvider),
//     ref.read(createHabitProvider),
//     ref.read(updateHabitProvider),
//     ref.read(deleteHabitProvider),
//     ref.read(calculateStreakProvider),
//   );
// });
