/// Keys for local storage (Hive, SharedPreferences, etc.)
class StorageKeys {
  // Settings Keys
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String notificationTime = 'notification_time';
  static const String skipWeekends = 'skip_weekends';
  static const String language = 'language';
  static const String isFirstLaunch = 'is_first_launch';

  // Premium Keys
  static const String isPremium = 'is_premium';
  static const String premiumPurchasedAt = 'premium_purchased_at';
  static const String premiumProductId = 'premium_product_id';

  // Onboarding Keys
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  static const String onboardingStep = 'onboarding_step';

  // Cache Keys
  static const String lastSyncTimestamp = 'last_sync_timestamp';
  static const String cachedHabitsCount = 'cached_habits_count';
  static const String lastBackupDate = 'last_backup_date';

  // Analytics Keys
  static const String totalHabitsCreated = 'total_habits_created';
  static const String totalCompletions = 'total_completions';
  static const String longestStreak = 'longest_streak';
  static const String appOpenCount = 'app_open_count';
  static const String lastOpenDate = 'last_open_date';

  // Feature Discovery Keys
  static const String hasSeenCalendarFeature = 'has_seen_calendar_feature';
  static const String hasSeenStreakFeature = 'has_seen_streak_feature';
  static const String hasSeenPremiumPrompt = 'has_seen_premium_prompt';

  // Debug Keys
  static const String debugMode = 'debug_mode';
  static const String showDebugInfo = 'show_debug_info';

  // Ad Keys
  static const String lastAdShownTimestamp = 'last_ad_shown_timestamp';
  static const String adImpressionCount = 'ad_impression_count';

  // Notification Keys
  static const String lastNotificationSent = 'last_notification_sent';
  static const String notificationScheduleIds = 'notification_schedule_ids';

  // Data Migration Keys
  static const String databaseVersion = 'database_version';
  static const String lastMigrationTimestamp = 'last_migration_timestamp';

  // Prevent instantiation
  StorageKeys._();
}

/// Keys for Hive boxes
class HiveBoxKeys {
  // Main boxes
  static const String habits = 'habits';
  static const String logs = 'habit_logs';
  static const String settings = 'settings';

  // Settings box keys
  static const String userSettings = 'user_settings';

  // Cache boxes
  static const String cache = 'cache';
  static const String temp = 'temp';

  // Prevent instantiation
  HiveBoxKeys._();
}

/// Type IDs for Hive adapters
class HiveTypeIds {
  static const int habitModel = 0;
  static const int habitLogModel = 1;
  static const int userSettingsModel = 2;

  // Reserve 3-9 for future models
  static const int futureModel1 = 3;
  static const int futureModel2 = 4;

  // Prevent instantiation
  HiveTypeIds._();
}
