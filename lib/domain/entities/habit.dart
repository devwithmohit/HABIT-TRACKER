/// Core habit entity - pure Dart, no external dependencies
class Habit {
  final String id;
  final String name;
  final String icon;
  final String color;
  final List<int> activeDays; // 1=Monday, 7=Sunday
  final DateTime createdAt;
  final bool isArchived;

  const Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.activeDays,
    required this.createdAt,
    this.isArchived = false,
  });

  /// Check if habit is active on a specific day of week
  bool isActiveOnDay(int dayOfWeek) {
    return activeDays.contains(dayOfWeek);
  }

  /// Check if habit should be tracked today
  bool isActiveToday() {
    return isActiveOnDay(DateTime.now().weekday);
  }

  /// Create a copy with updated fields
  Habit copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    List<int>? activeDays,
    DateTime? createdAt,
    bool? isArchived,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      activeDays: activeDays ?? this.activeDays,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Habit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          color == other.color &&
          activeDays.length == other.activeDays.length &&
          activeDays.every((day) => other.activeDays.contains(day)) &&
          createdAt == other.createdAt &&
          isArchived == other.isArchived;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      color.hashCode ^
      activeDays.hashCode ^
      createdAt.hashCode ^
      isArchived.hashCode;

  @override
  String toString() {
    return 'Habit(id: $id, name: $name, icon: $icon, color: $color, activeDays: $activeDays, createdAt: $createdAt, isArchived: $isArchived)';
  }
}
