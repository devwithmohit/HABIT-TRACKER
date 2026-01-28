import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/hive_database.dart';
import '../mappers/habit_mapper.dart';

/// Implementation of SettingsRepository using Hive
class SettingsRepositoryImpl implements SettingsRepository {
  final HiveDatabase _database;
  static const String _settingsKey = 'user_settings';

  SettingsRepositoryImpl(this._database);

  @override
  Future<UserSettings> getSettings() async {
    final box = _database.settingsBox;
    final model = box.get(_settingsKey);

    if (model == null) {
      // Return default settings if none exist
      final defaultSettings = UserSettings.defaultSettings();
      await updateSettings(defaultSettings);
      return defaultSettings;
    }

    return UserSettingsMapper.toEntity(model);
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    final box = _database.settingsBox;
    final model = UserSettingsMapper.toModel(settings);

    await box.put(_settingsKey, model);
  }

  @override
  Future<void> updateThemeMode(String themeMode) async {
    final settings = await getSettings();
    final updated = settings.copyWith(themeMode: themeMode);
    await updateSettings(updated);
  }

  @override
  Future<void> updateNotificationsEnabled(bool enabled) async {
    final settings = await getSettings();
    final updated = settings.copyWith(notificationsEnabled: enabled);
    await updateSettings(updated);
  }

  @override
  Future<void> updateNotificationTime(String time) async {
    final settings = await getSettings();
    final updated = settings.copyWith(notificationTime: time);
    await updateSettings(updated);
  }

  @override
  Future<void> updateSkipWeekends(bool skip) async {
    final settings = await getSettings();
    final updated = settings.copyWith(skipWeekends: skip);
    await updateSettings(updated);
  }

  @override
  Future<void> updateLanguage(String language) async {
    final settings = await getSettings();
    final updated = settings.copyWith(language: language);
    await updateSettings(updated);
  }

  @override
  Future<void> markFirstLaunchComplete() async {
    final settings = await getSettings();
    final updated = settings.copyWith(isFirstLaunch: false);
    await updateSettings(updated);
  }

  @override
  Future<void> activatePremium() async {
    final settings = await getSettings();
    final updated = settings.toPremium();
    await updateSettings(updated);
  }

  @override
  Future<bool> isPremiumActive() async {
    final settings = await getSettings();
    return settings.isPremium;
  }

  @override
  Future<void> resetToDefaults() async {
    final defaultSettings = UserSettings.defaultSettings();
    await updateSettings(defaultSettings);
  }

  @override
  Future<bool> isFirstLaunch() async {
    final settings = await getSettings();
    return settings.isFirstLaunch;
  }
}
