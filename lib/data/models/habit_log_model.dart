import 'package:hive/hive.dart';

part 'habit_log_model.g.dart';

@HiveType(typeId: 1)
class HabitLogModel extends HiveObject {
  @HiveField(0)
  late String habitId;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late bool isCompleted;

  @HiveField(3)
  DateTime? completedAt;

  HabitLogModel({
    required this.habitId,
    required this.date,
    required this.isCompleted,
    this.completedAt,
  });

  /// Create model from map (for JSON serialization if needed)
  factory HabitLogModel.fromMap(Map<String, dynamic> map) {
    return HabitLogModel(
      habitId: map['habitId'] as String,
      date: DateTime.parse(map['date'] as String),
      isCompleted: map['isCompleted'] as bool,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
    );
  }

  /// Convert to map (for JSON serialization if needed)
  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  /// Create composite key for storage (habitId_date)
  String get compositeKey {
    final dateStr = date.toIso8601String().split('T')[0];
    return '${habitId}_$dateStr';
  }

  @override
  String toString() {
    return 'HabitLogModel(habitId: $habitId, date: $date, isCompleted: $isCompleted, completedAt: $completedAt)';
  }
}
