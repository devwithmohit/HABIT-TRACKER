import '../../domain/entities/habit.dart';
import '../../domain/value_objects/streak.dart';

/// Data Transfer Object combining Habit with its calculated Streak
/// Used in presentation layer to avoid multiple repository calls
class HabitWithStreak {
  final Habit habit;
  final Streak streak;

  const HabitWithStreak({
    required this.habit,
    required this.streak,
  });

  /// Check if habit needs attention today
  bool get needsAttention {
    return habit.isActiveToday() && !streak.isActiveToday;
  }

  /// Get completion percentage (current streak vs longest)
  double get streakProgress {
    if (streak.longest == 0) return 0.0;
    return (streak.current / streak.longest).clamp(0.0, 1.0);
  }

  /// Copy with updated fields
  HabitWithStreak copyWith({
    Habit? habit,
    Streak? streak,
  }) {
    return HabitWithStreak(
      habit: habit ?? this.habit,
      streak: streak ?? this.streak,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitWithStreak &&
          runtimeType == other.runtimeType &&
          habit == other.habit &&
          streak == other.streak;

  @override
  int get hashCode => habit.hashCode ^ streak.hashCode;

  @override
  String toString() {
    return 'HabitWithStreak(habit: ${habit.name}, current: ${streak.current}, longest: ${streak.longest})';
  }
}
