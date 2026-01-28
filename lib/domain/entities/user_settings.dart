/// User preferences and app settings
class UserSettings {
  final String themeMode; // 'light', 'dark', 'amoled', 'system'
  final bool notificationsEnabled;
  final String notificationTime; // HH:mm format
  final bool skipWeekends;
  final bool isPremium;
  final DateTime? premiumPurchasedAt;
  final String language; // 'en', 'hi', etc.
  final bool isFirstLaunch;

  const UserSettings({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.notificationTime = '20:00',
    this.skipWeekends = false,
    this.isPremium = false,
    this.premiumPurchasedAt,
    this.language = 'en',
    this.isFirstLaunch = true,
  });

  /// Default settings for new users
  factory UserSettings.defaultSettings() {
    return const UserSettings();
  }

  /// Create premium settings
  UserSettings toPremium() {
    return copyWith(
      isPremium: true,
      premiumPurchasedAt: DateTime.now(),
    );
  }

  /// Check if premium features are available
  bool get hasPremiumAccess => isPremium;

  /// Get notification time as TimeOfDay components
  Map<String, int> get notificationTimeComponents {
    final parts = notificationTime.split(':');
    return {
      'hour': int.parse(parts[0]),
      'minute': int.parse(parts[1]),
    };
  }

  /// Create a copy with updated fields
  UserSettings copyWith({
    String? themeMode,
    bool? notificationsEnabled,
    String? notificationTime,
    bool? skipWeekends,
    bool? isPremium,
    DateTime? premiumPurchasedAt,
    String? language,
    bool? isFirstLaunch,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
      skipWeekends: skipWeekends ?? this.skipWeekends,
      isPremium: isPremium ?? this.isPremium,
      premiumPurchasedAt: premiumPurchasedAt ?? this.premiumPurchasedAt,
      language: language ?? this.language,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettings &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          notificationsEnabled == other.notificationsEnabled &&
          notificationTime == other.notificationTime &&
          skipWeekends == other.skipWeekends &&
          isPremium == other.isPremium &&
          premiumPurchasedAt == other.premiumPurchasedAt &&
          language == other.language &&
          isFirstLaunch == other.isFirstLaunch;

  @override
  int get hashCode =>
      themeMode.hashCode ^
      notificationsEnabled.hashCode ^
      notificationTime.hashCode ^
      skipWeekends.hashCode ^
      isPremium.hashCode ^
      premiumPurchasedAt.hashCode ^
      language.hashCode ^
      isFirstLaunch.hashCode;

  @override
  String toString() {
    return 'UserSettings(themeMode: $themeMode, notificationsEnabled: $notificationsEnabled, notificationTime: $notificationTime, skipWeekends: $skipWeekends, isPremium: $isPremium, premiumPurchasedAt: $premiumPurchasedAt, language: $language, isFirstLaunch: $isFirstLaunch)';
  }
}
