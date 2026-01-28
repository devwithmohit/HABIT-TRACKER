/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Habit Tracker';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Fast. Clean. Zero friction.';

  // Database
  static const String databaseName = 'habit_tracker_db';
  static const int databaseVersion = 1;

  // Hive Box Names
  static const String habitsBoxName = 'habits';
  static const String logsBoxName = 'habit_logs';
  static const String settingsBoxName = 'settings';

  // Limits
  static const int maxHabitsFreeTier = 10;
  static const int maxHabitsPremium = 100;
  static const int maxHabitNameLength = 50;
  static const int minHabitNameLength = 1;

  // Notification
  static const int defaultNotificationId = 1;
  static const String notificationChannelId = 'habit_tracker_notifications';
  static const String notificationChannelName = 'Habit Reminders';
  static const String notificationChannelDescription = 'Daily habit reminder notifications';

  // Default notification time (8 PM)
  static const int defaultNotificationHour = 20;
  static const int defaultNotificationMinute = 0;

  // Streak
  static const int streakCalculationDaysLimit = 365; // Don't calculate beyond 1 year
  static const int minStreakForReward = 7; // 7 days
  static const int longStreakThreshold = 30; // 30 days
  static const int epicStreakThreshold = 90; // 90 days
  static const int legendaryStreakThreshold = 365; // 1 year

  // UI
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const int animationDurationMs = 200;

  // Icons (default emoji for new habits)
  static const String defaultHabitIcon = '🎯';
  static const List<String> popularIcons = [
    '🎯', '💪', '📚', '🏃', '🧘', '💧', '🥗', '😴',
    '📝', '🎨', '🎵', '🏋️', '🚴', '🧠', '💼', '☕',
  ];

  // Colors (default color for new habits)
  static const String defaultHabitColor = '#6C63FF';

  // Monetization
  static const String premiumProductId = 'habit_tracker_premium';
  static const String adMobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713'; // Test ID
  static const String adMobAppIdIos = 'ca-app-pub-3940256099942544~1458002511'; // Test ID
  static const String adMobBannerIdAndroid = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String adMobBannerIdIos = 'ca-app-pub-3940256099942544/2934735716'; // Test ID

  // Premium prices (in rupees)
  static const int premiumPriceMin = 149;
  static const int premiumPriceMax = 299;

  // Date & Time
  static const List<String> weekDayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];
  static const List<String> weekDayNamesShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  // Active days presets
  static const List<int> weekdays = [1, 2, 3, 4, 5]; // Mon-Fri
  static const List<int> weekends = [6, 7]; // Sat-Sun
  static const List<int> everyday = [1, 2, 3, 4, 5, 6, 7];

  // URLs
  static const String privacyPolicyUrl = 'https://example.com/privacy';
  static const String termsOfServiceUrl = 'https://example.com/terms';
  static const String supportEmail = 'support@habittracker.com';
  static const String githubUrl = 'https://github.com/devwithmohit/HABIT-TRACKER';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableAds = true; // Disable for testing
  static const bool enableIAP = true;

  // Export
  static const String exportFilePrefix = 'habit_tracker_export';
  static const String exportDateFormat = 'yyyy-MM-dd';

  // Performance
  static const int maxLogsToDisplay = 90; // Show last 90 days in calendar
  static const int debounceDelayMs = 300; // For search/input
}
