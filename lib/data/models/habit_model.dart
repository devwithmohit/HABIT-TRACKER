import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon;

  @HiveField(3)
  late String color;

  @HiveField(4)
  late List<int> activeDays;

  @HiveField(5)
  late DateTime createdAt;

  @HiveField(6)
  late bool isArchived;

  HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.activeDays,
    required this.createdAt,
    this.isArchived = false,
  });

  /// Create model from map (for JSON serialization if needed)
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      activeDays: List<int>.from(map['activeDays'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isArchived: map['isArchived'] as bool? ?? false,
    );
  }

  /// Convert to map (for JSON serialization if needed)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'activeDays': activeDays,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  @override
  String toString() {
    return 'HabitModel(id: $id, name: $name, icon: $icon, color: $color, activeDays: $activeDays, createdAt: $createdAt, isArchived: $isArchived)';
  }
}
