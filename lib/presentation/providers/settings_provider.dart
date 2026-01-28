import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// State for user settings
class SettingsState {
  final UserSettings settings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    UserSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Settings state notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository)
      : super(SettingsState(settings: UserSettings.defaultSettings())) {
    loadSettings();
  }

  /// Load settings from repository
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final settings = await _repository.getSettings();
      state = state.copyWith(settings: settings, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load settings: $e',
      );
    }
  }

  /// Update theme mode
  Future<void> updateThemeMode(String themeMode) async {
    try {
      await _repository.updateThemeMode(themeMode);
      state = state.copyWith(
        settings: state.settings.copyWith(themeMode: themeMode),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to update theme: $e');
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    try {
      await _repository.updateNotificationsEnabled(enabled);
      state = state.copyWith(
        settings: state.settings.copyWith(notificationsEnabled: enabled),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to update notifications: $e');
    }
  }

  /// Update notification time
  Future<void> updateNotificationTime(String time) async {
    try {
      await _repository.updateNotificationTime(time);
      state = state.copyWith(
        settings: state.settings.copyWith(notificationTime: time),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to update notification time: $e');
    }
  }

  /// Toggle skip weekends
  Future<void> toggleSkipWeekends(bool skip) async {
    try {
      await _repository.updateSkipWeekends(skip);
      state = state.copyWith(
        settings: state.settings.copyWith(skipWeekends: skip),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to update skip weekends: $e');
    }
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    try {
      await _repository.updateLanguage(language);
      state = state.copyWith(
        settings: state.settings.copyWith(language: language),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to update language: $e');
    }
  }

  /// Activate premium
  Future<void> activatePremium() async {
    try {
      await _repository.activatePremium();
      state = state.copyWith(
        settings: state.settings.toPremium(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to activate premium: $e');
    }
  }

  /// Mark first launch complete
  Future<void> completeFirstLaunch() async {
    try {
      await _repository.markFirstLaunchComplete();
      state = state.copyWith(
        settings: state.settings.copyWith(isFirstLaunch: false),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to complete first launch: $e');
    }
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    try {
      await _repository.resetToDefaults();
      await loadSettings();
    } catch (e) {
      state = state.copyWith(error: 'Failed to reset settings: $e');
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Check if premium is active
  bool get isPremium => state.settings.isPremium;

  /// Check if this is first launch
  bool get isFirstLaunch => state.settings.isFirstLaunch;

  /// Get current theme mode
  String get themeMode => state.settings.themeMode;
}

/// Provider for settings notifier
/// Note: Requires DI setup
// final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
//   return SettingsNotifier(ref.read(settingsRepositoryProvider));
// });
