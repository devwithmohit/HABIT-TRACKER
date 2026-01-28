import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/local/hive_database.dart';
import '../mappers/habit_mapper.dart';

/// Implementation of HabitRepository using Hive
class HabitRepositoryImpl implements HabitRepository {
  final HiveDatabase _database;

  HabitRepositoryImpl(this._database);

  @override
  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final box = _database.habitsBox;
    final models = box.values.toList();

    if (!includeArchived) {
      final activeModels = models.where((m) => !m.isArchived).toList();
      return HabitMapper.toEntityList(activeModels);
    }

    return HabitMapper.toEntityList(models);
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final box = _database.habitsBox;
    final model = box.get(id);

    if (model == null) return null;

    return HabitMapper.toEntity(model);
  }

  @override
  Future<List<Habit>> getActiveHabits() async {
    return getAllHabits(includeArchived: false);
  }

  @override
  Future<void> createHabit(Habit habit) async {
    final box = _database.habitsBox;
    final model = HabitMapper.toModel(habit);

    await box.put(habit.id, model);
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final box = _database.habitsBox;
    final model = HabitMapper.toModel(habit);

    await box.put(habit.id, model);
  }

  @override
  Future<void> deleteHabit(String id) async {
    final box = _database.habitsBox;
    await box.delete(id);

    // Also delete all logs for this habit
    final logsBox = _database.logsBox;
    final keysToDelete = logsBox.keys
        .where((key) => (key as String).startsWith('${id}_'))
        .toList();

    for (final key in keysToDelete) {
      await logsBox.delete(key);
    }
  }

  @override
  Future<void> archiveHabit(String id, bool isArchived) async {
    final habit = await getHabitById(id);
    if (habit == null) return;

    final updatedHabit = habit.copyWith(isArchived: isArchived);
    await updateHabit(updatedHabit);
  }

  @override
  Future<List<HabitLog>> getLogsForHabit(String habitId) async {
    final box = _database.logsBox;
    final models = box.values.where((log) => log.habitId == habitId).toList();

    return HabitLogMapper.toEntityList(models);
  }

  @override
  Future<List<HabitLog>> getLogsForDateRange({
    required String habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final box = _database.logsBox;
    final normalizedStart = HabitLog.normalizeDate(startDate);
    final normalizedEnd = HabitLog.normalizeDate(endDate);

    final models = box.values
        .where((log) =>
            log.habitId == habitId &&
            !log.date.isBefore(normalizedStart) &&
            !log.date.isAfter(normalizedEnd))
        .toList();

    return HabitLogMapper.toEntityList(models);
  }

  @override
  Future<HabitLog?> getLogForDate({
    required String habitId,
    required DateTime date,
  }) async {
    final box = _database.logsBox;
    final normalizedDate = HabitLog.normalizeDate(date);
    final key = _createLogKey(habitId, normalizedDate);

    final model = box.get(key);
    if (model == null) return null;

    return HabitLogMapper.toEntity(model);
  }

  @override
  Future<void> saveLog(HabitLog log) async {
    final box = _database.logsBox;
    final model = HabitLogMapper.toModel(log);
    final key = _createLogKey(log.habitId, log.date);

    await box.put(key, model);
  }

  @override
  Future<void> deleteLog({
    required String habitId,
    required DateTime date,
  }) async {
    final box = _database.logsBox;
    final normalizedDate = HabitLog.normalizeDate(date);
    final key = _createLogKey(habitId, normalizedDate);

    await box.delete(key);
  }

  @override
  Future<void> toggleHabitCompletion({
    required String habitId,
    required DateTime date,
  }) async {
    final normalizedDate = HabitLog.normalizeDate(date);
    final existingLog = await getLogForDate(
      habitId: habitId,
      date: normalizedDate,
    );

    if (existingLog == null) {
      // Create new completed log
      final newLog = HabitLog.completed(
        habitId: habitId,
        date: normalizedDate,
      );
      await saveLog(newLog);
    } else {
      // Toggle existing log
      final toggledLog = existingLog.toggleCompletion();
      await saveLog(toggledLog);
    }
  }

  @override
  Future<int> getCompletionCount(String habitId) async {
    final logs = await getLogsForHabit(habitId);
    return logs.where((log) => log.isCompleted).length;
  }

  @override
  Future<bool> isHabitCompletedOnDate({
    required String habitId,
    required DateTime date,
  }) async {
    final log = await getLogForDate(habitId: habitId, date: date);
    return log?.isCompleted ?? false;
  }

  @override
  Future<List<HabitLog>> getTodayLogs() async {
    final box = _database.logsBox;
    final today = HabitLog.normalizeDate(DateTime.now());

    final models = box.values.where((log) => log.date.isAtSameMomentAs(today)).toList();

    return HabitLogMapper.toEntityList(models);
  }

  @override
  Future<void> clearAllData() async {
    await _database.clearAllData();
  }

  /// Create composite key for log storage (habitId_YYYY-MM-DD)
  String _createLogKey(String habitId, DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return '${habitId}_$dateStr';
  }
}
