import 'package:hive_flutter/hive_flutter.dart';
import '../../models/habit_model.dart';
import '../../models/habit_log_model.dart';
import '../../models/user_settings_model.dart';

/// Hive database initialization and management
class HiveDatabase {
  // Box names
  static const String habitsBoxName = 'habits';
  static const String logsBoxName = 'habit_logs';
  static const String settingsBoxName = 'settings';

  // Singleton pattern
  static final HiveDatabase _instance = HiveDatabase._internal();
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();

  bool _isInitialized = false;

  /// Initialize Hive and register adapters
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize Hive for Flutter
    await Hive.initFlutter();

    // Register type adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HabitModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HabitLogModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(UserSettingsModelAdapter());
    }

    _isInitialized = true;
  }

  /// Open all required boxes
  Future<void> openBoxes() async {
    if (!_isInitialized) {
      await init();
    }

    // Open boxes if not already open
    if (!Hive.isBoxOpen(habitsBoxName)) {
      await Hive.openBox<HabitModel>(habitsBoxName);
    }
    if (!Hive.isBoxOpen(logsBoxName)) {
      await Hive.openBox<HabitLogModel>(logsBoxName);
    }
    if (!Hive.isBoxOpen(settingsBoxName)) {
      await Hive.openBox<UserSettingsModel>(settingsBoxName);
    }
  }

  /// Get habits box
  Box<HabitModel> get habitsBox {
    if (!Hive.isBoxOpen(habitsBoxName)) {
      throw StateError('Habits box is not open. Call openBoxes() first.');
    }
    return Hive.box<HabitModel>(habitsBoxName);
  }

  /// Get logs box
  Box<HabitLogModel> get logsBox {
    if (!Hive.isBoxOpen(logsBoxName)) {
      throw StateError('Logs box is not open. Call openBoxes() first.');
    }
    return Hive.box<HabitLogModel>(logsBoxName);
  }

  /// Get settings box
  Box<UserSettingsModel> get settingsBox {
    if (!Hive.isBoxOpen(settingsBoxName)) {
      throw StateError('Settings box is not open. Call openBoxes() first.');
    }
    return Hive.box<UserSettingsModel>(settingsBoxName);
  }

  /// Close all boxes
  Future<void> closeBoxes() async {
    if (Hive.isBoxOpen(habitsBoxName)) {
      await Hive.box<HabitModel>(habitsBoxName).close();
    }
    if (Hive.isBoxOpen(logsBoxName)) {
      await Hive.box<HabitLogModel>(logsBoxName).close();
    }
    if (Hive.isBoxOpen(settingsBoxName)) {
      await Hive.box<UserSettingsModel>(settingsBoxName).close();
    }
  }

  /// Delete all data (for app reset)
  Future<void> clearAllData() async {
    await habitsBox.clear();
    await logsBox.clear();
    await settingsBox.clear();
  }

  /// Delete all boxes (complete cleanup)
  Future<void> deleteAllBoxes() async {
    await closeBoxes();
    await Hive.deleteBoxFromDisk(habitsBoxName);
    await Hive.deleteBoxFromDisk(logsBoxName);
    await Hive.deleteBoxFromDisk(settingsBoxName);
  }

  /// Check if database is initialized
  bool get isInitialized => _isInitialized;

  /// Get database path
  String? get path => Hive.box(habitsBoxName).path;
}
