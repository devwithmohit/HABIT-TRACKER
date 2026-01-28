import 'package:hive/hive.dart';

part 'user_settings_model.g.dart';

@HiveType(typeId: 2)
class UserSettingsModel extends HiveObject {
  @HiveField(0)
  late String themeMode;

  @HiveField(1)
  late bool notificationsEnabled;

  @HiveField(2)
  late String notificationTime;

  @HiveField(3)
  late bool skipWeekends;

  @HiveField(4)
  late bool isPremium;

  @HiveField(5)
  DateTime? premiumPurchasedAt;

  @HiveField(6)
  late String language;

  @HiveField(7)
  late bool isFirstLaunch;

  UserSettingsModel({
    this.themeMode = 'system',
    this.notificationsEnabled = true,
    this.notificationTime = '20:00',
    this.skipWeekends = false,
    this.isPremium = false,
    this.premiumPurchasedAt,
    this.language = 'en',
    this.isFirstLaunch = true,
  });

  /// Create model from map (for JSON serialization if needed)
  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      themeMode: map['themeMode'] as String? ?? 'system',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      notificationTime: map['notificationTime'] as String? ?? '20:00',
      skipWeekends: map['skipWeekends'] as bool? ?? false,
      isPremium: map['isPremium'] as bool? ?? false,
      premiumPurchasedAt: map['premiumPurchasedAt'] != null
          ? DateTime.parse(map['premiumPurchasedAt'] as String)
          : null,
      language: map['language'] as String? ?? 'en',
      isFirstLaunch: map['isFirstLaunch'] as bool? ?? true,
    );
  }

  /// Convert to map (for JSON serialization if needed)
  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode,
      'notificationsEnabled': notificationsEnabled,
      'notificationTime': notificationTime,
      'skipWeekends': skipWeekends,
      'isPremium': isPremium,
      'premiumPurchasedAt': premiumPurchasedAt?.toIso8601String(),
      'language': language,
      'isFirstLaunch': isFirstLaunch,
    };
  }

  @override
  String toString() {
    return 'UserSettingsModel(themeMode: $themeMode, notificationsEnabled: $notificationsEnabled, notificationTime: $notificationTime, skipWeekends: $skipWeekends, isPremium: $isPremium, premiumPurchasedAt: $premiumPurchasedAt, language: $language, isFirstLaunch: $isFirstLaunch)';
  }
}
