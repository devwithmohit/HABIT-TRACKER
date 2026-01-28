import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/hive_database.dart';
import '../../data/repositories/habit_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../application/usecases/habits/create_habit.dart';
import '../../application/usecases/habits/update_habit.dart';
import '../../application/usecases/habits/delete_habit.dart';
import '../../application/usecases/habits/get_all_habits.dart';
import '../../application/usecases/habits/reorder_habits.dart';
import '../../application/usecases/logs/mark_habit_complete.dart';
import '../../application/usecases/logs/unmark_habit_complete.dart';
import '../../application/usecases/logs/get_habit_logs.dart';
import '../../application/usecases/analytics/calculate_streak.dart';
import '../../application/usecases/analytics/get_weekly_summary.dart';
import '../../application/usecases/analytics/check_habit_due_today.dart';
import '../../presentation/providers/habits_provider.dart';
import '../../presentation/providers/habit_logs_provider.dart';
import '../../presentation/providers/settings_provider.dart';
import '../notifications/notification_service.dart';
import '../monetization/ad_service.dart';
import '../monetization/purchase_service.dart';

// =============================================================================
// DATA LAYER PROVIDERS
// =============================================================================

/// Hive database provider (Singleton)
final hiveDatabaseProvider = Provider<HiveDatabase>((ref) {
  return HiveDatabase();
});

/// Habit repository provider
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final database = ref.watch(hiveDatabaseProvider);
  return HabitRepositoryImpl(database);
});

/// Settings repository provider
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final database = ref.watch(hiveDatabaseProvider);
  return SettingsRepositoryImpl(database);
});

// =============================================================================
// USE CASE PROVIDERS (APPLICATION LAYER)
// =============================================================================

// Habit use cases
final createHabitProvider = Provider<CreateHabit>((ref) {
  return CreateHabit(ref.watch(habitRepositoryProvider));
});

final updateHabitProvider = Provider<UpdateHabit>((ref) {
  return UpdateHabit(ref.watch(habitRepositoryProvider));
});

final deleteHabitProvider = Provider<DeleteHabit>((ref) {
  return DeleteHabit(ref.watch(habitRepositoryProvider));
});

final getAllHabitsProvider = Provider<GetAllHabits>((ref) {
  return GetAllHabits(ref.watch(habitRepositoryProvider));
});

final reorderHabitsProvider = Provider<ReorderHabits>((ref) {
  return ReorderHabits(ref.watch(habitRepositoryProvider));
});

// Log use cases
final markHabitCompleteProvider = Provider<MarkHabitComplete>((ref) {
  return MarkHabitComplete(ref.watch(habitRepositoryProvider));
});

final unmarkHabitCompleteProvider = Provider<UnmarkHabitComplete>((ref) {
  return UnmarkHabitComplete(ref.watch(habitRepositoryProvider));
});

final getHabitLogsProvider = Provider<GetHabitLogs>((ref) {
  return GetHabitLogs(ref.watch(habitRepositoryProvider));
});

// Analytics use cases
final calculateStreakProvider = Provider<CalculateStreak>((ref) {
  return CalculateStreak(ref.watch(habitRepositoryProvider));
});

final getWeeklySummaryProvider = Provider<GetWeeklySummary>((ref) {
  return GetWeeklySummary(ref.watch(habitRepositoryProvider));
});

final checkHabitDueTodayProvider = Provider<CheckHabitDueToday>((ref) {
  return CheckHabitDueToday(ref.watch(habitRepositoryProvider));
});

// =============================================================================
// PRESENTATION LAYER PROVIDERS (STATE MANAGEMENT)
// =============================================================================

/// Habits state provider
final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitsState>((ref) {
  return HabitsNotifier(
    ref.watch(getAllHabitsProvider),
    ref.watch(createHabitProvider),
    ref.watch(updateHabitProvider),
    ref.watch(deleteHabitProvider),
    ref.watch(calculateStreakProvider),
  );
});

/// Habit logs state provider
final habitLogsProvider =
    StateNotifierProvider<HabitLogsNotifier, HabitLogsState>((ref) {
  return HabitLogsNotifier(
    ref.watch(getHabitLogsProvider),
    ref.watch(markHabitCompleteProvider),
    ref.watch(unmarkHabitCompleteProvider),
  );
});

/// Settings state provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

// =============================================================================
// CORE SERVICE PROVIDERS
// =============================================================================

/// Notification service provider (Singleton)
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Ad service provider (Singleton)
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

/// Purchase service provider (Singleton)
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

// =============================================================================
// CONVENIENCE PROVIDERS
// =============================================================================

/// Check if user has premium access
final hasPremiumProvider = FutureProvider<bool>((ref) async {
  // Check settings first
  final settings = ref.watch(settingsProvider);
  if (settings.settings.isPremium) return true;

  // Fallback to IAP check
  final purchaseService = ref.watch(purchaseServiceProvider);
  return await purchaseService.hasPremium();
});

/// Get today's habits provider
final todayHabitsProvider = FutureProvider((ref) async {
  final useCase = ref.watch(checkHabitDueTodayProvider);
  return await useCase.allDueToday();
});

/// Get weekly summary provider
final weeklySummaryProvider = FutureProvider((ref) async {
  final useCase = ref.watch(getWeeklySummaryProvider);
  return await useCase();
});

// =============================================================================
// INITIALIZATION
// =============================================================================

/// Initialize all core services
/// Call this in main.dart before runApp()
Future<void> initializeServices(ProviderContainer container) async {
  try {
    // Initialize Hive database
    final hiveDb = container.read(hiveDatabaseProvider);
    await hiveDb.init();
    await hiveDb.openBoxes();

    // Initialize notification service (may not work on web)
    try {
      final notificationService = container.read(notificationServiceProvider);
      await notificationService.initialize();
    } catch (e) {
      // Notifications not supported on web - continue
      print('⚠️ Notification service not available: $e');
    }

    // Initialize ad service (not supported on web)
    if (!kIsWeb) {
      try {
        final adService = container.read(adServiceProvider);
        await adService.initialize();
      } catch (e) {
        print('⚠️ Ad service initialization failed: $e');
      }
    }

    // Initialize purchase service (not supported on web)
    if (!kIsWeb) {
      try {
        final purchaseService = container.read(purchaseServiceProvider);
        await purchaseService.initialize();
      } catch (e) {
        print('⚠️ IAP service initialization failed: $e');
      }
    } else {
      // Web platform - skip IAP
      print('⚠️ Purchase service not available on web platform');
    }

    // Load initial settings
    await container.read(settingsProvider.notifier).loadSettings();

    // Load habits
    await container.read(habitsProvider.notifier).loadHabits();
  } catch (e) {
    print('❌ Critical initialization error: $e');
    rethrow;
  }
}
