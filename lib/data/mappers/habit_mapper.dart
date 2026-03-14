import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/entities/user_settings.dart';
import '../models/habit_model.dart';
import '../models/habit_log_model.dart';
import '../models/user_settings_model.dart';

/// Mapper for Habit entity <-> HabitModel conversion
class HabitMapper {
  /// Convert domain entity to Hive model
  static HabitModel toModel(Habit entity) {
    return HabitModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      activeDays: List<int>.from(entity.activeDays),
      createdAt: entity.createdAt,
      isArchived: entity.isArchived,
      sortOrder: entity.sortOrder,
    );
  }

  /// Convert Hive model to domain entity
  static Habit toEntity(HabitModel model) {
    return Habit(
      id: model.id,
      name: model.name,
      icon: model.icon,
      color: model.color,
      activeDays: List<int>.from(model.activeDays),
      createdAt: model.createdAt,
      isArchived: model.isArchived,
      sortOrder: model.sortOrder,
    );
  }

  /// Convert list of models to entities
  static List<Habit> toEntityList(List<HabitModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convert list of entities to models
  static List<HabitModel> toModelList(List<Habit> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}

/// Mapper for HabitLog entity <-> HabitLogModel conversion
class HabitLogMapper {
  /// Convert domain entity to Hive model
  static HabitLogModel toModel(HabitLog entity) {
    return HabitLogModel(
      habitId: entity.habitId,
      date: entity.date,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
    );
  }

  /// Convert Hive model to domain entity
  static HabitLog toEntity(HabitLogModel model) {
    return HabitLog(
      habitId: model.habitId,
      date: model.date,
      isCompleted: model.isCompleted,
      completedAt: model.completedAt,
    );
  }

  /// Convert list of models to entities
  static List<HabitLog> toEntityList(List<HabitLogModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convert list of entities to models
  static List<HabitLogModel> toModelList(List<HabitLog> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}

/// Mapper for UserSettings entity <-> UserSettingsModel conversion
class UserSettingsMapper {
  /// Convert domain entity to Hive model
  static UserSettingsModel toModel(UserSettings entity) {
    return UserSettingsModel(
      themeMode: entity.themeMode,
      notificationsEnabled: entity.notificationsEnabled,
      notificationTime: entity.notificationTime,
      skipWeekends: entity.skipWeekends,
      isPremium: entity.isPremium,
      premiumPurchasedAt: entity.premiumPurchasedAt,
      language: entity.language,
      isFirstLaunch: entity.isFirstLaunch,
    );
  }

  /// Convert Hive model to domain entity
  static UserSettings toEntity(UserSettingsModel model) {
    return UserSettings(
      themeMode: model.themeMode,
      notificationsEnabled: model.notificationsEnabled,
      notificationTime: model.notificationTime,
      skipWeekends: model.skipWeekends,
      isPremium: model.isPremium,
      premiumPurchasedAt: model.premiumPurchasedAt,
      language: model.language,
      isFirstLaunch: model.isFirstLaunch,
    );
  }
}
