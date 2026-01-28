import '../entities/user_settings.dart';

/// Repository interface for user settings
/// Implementation will be in data layer using Hive
abstract class SettingsRepository {
  /// Get current user settings
  Future<UserSettings> getSettings();

  /// Update user settings
  Future<void> updateSettings(UserSettings settings);

  /// Update specific setting fields
  Future<void> updateThemeMode(String themeMode);

  Future<void> updateNotificationsEnabled(bool enabled);

  Future<void> updateNotificationTime(String time);

  Future<void> updateSkipWeekends(bool skip);

  Future<void> updateLanguage(String language);

  Future<void> markFirstLaunchComplete();

  /// Premium status management
  Future<void> activatePremium();

  Future<bool> isPremiumActive();

  /// Reset settings to default
  Future<void> resetToDefaults();

  /// Check if this is first app launch
  Future<bool> isFirstLaunch();
}
