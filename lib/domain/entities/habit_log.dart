/// Daily completion record for a habit
class HabitLog {
  final String habitId;
  final DateTime date; // Date only (normalized to midnight)
  final bool isCompleted;
  final DateTime? completedAt; // Exact timestamp when marked complete

  const HabitLog({
    required this.habitId,
    required this.date,
    required this.isCompleted,
    this.completedAt,
  });

  /// Create a normalized date (midnight UTC)
  static DateTime normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Create a log for today
  factory HabitLog.today({
    required String habitId,
    required bool isCompleted,
    DateTime? completedAt,
  }) {
    return HabitLog(
      habitId: habitId,
      date: normalizeDate(DateTime.now()),
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }

  /// Create a completed log
  factory HabitLog.completed({
    required String habitId,
    required DateTime date,
  }) {
    return HabitLog(
      habitId: habitId,
      date: normalizeDate(date),
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// Create an incomplete log
  factory HabitLog.incomplete({
    required String habitId,
    required DateTime date,
  }) {
    return HabitLog(
      habitId: habitId,
      date: normalizeDate(date),
      isCompleted: false,
      completedAt: null,
    );
  }

  /// Create a copy with updated fields
  HabitLog copyWith({
    String? habitId,
    DateTime? date,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return HabitLog(
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Toggle completion status
  HabitLog toggleCompletion() {
    return HabitLog(
      habitId: habitId,
      date: date,
      isCompleted: !isCompleted,
      completedAt: !isCompleted ? DateTime.now() : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLog &&
          runtimeType == other.runtimeType &&
          habitId == other.habitId &&
          date == other.date &&
          isCompleted == other.isCompleted &&
          completedAt == other.completedAt;

  @override
  int get hashCode =>
      habitId.hashCode ^
      date.hashCode ^
      isCompleted.hashCode ^
      completedAt.hashCode;

  @override
  String toString() {
    return 'HabitLog(habitId: $habitId, date: $date, isCompleted: $isCompleted, completedAt: $completedAt)';
  }
}
