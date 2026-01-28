import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../dto/result.dart';

/// Use case: Get all habits with optional filtering
class GetAllHabits {
  final HabitRepository _repository;

  GetAllHabits(this._repository);

  /// Get all active habits
  Future<Result<List<Habit>>> call() async {
    try {
      final habits = await _repository.getActiveHabits();
      return Success(habits);
    } on Exception catch (e) {
      return Failure('Failed to load habits', e);
    }
  }

  /// Get all habits including archived
  Future<Result<List<Habit>>> withArchived() async {
    try {
      final habits = await _repository.getAllHabits(includeArchived: true);
      return Success(habits);
    } on Exception catch (e) {
      return Failure('Failed to load habits', e);
    }
  }

  /// Get only archived habits
  Future<Result<List<Habit>>> onlyArchived() async {
    try {
      final allHabits = await _repository.getAllHabits(includeArchived: true);
      final archived = allHabits.where((h) => h.isArchived).toList();
      return Success(archived);
    } on Exception catch (e) {
      return Failure('Failed to load archived habits', e);
    }
  }

  /// Get habits active today
  Future<Result<List<Habit>>> activeToday() async {
    try {
      final habits = await _repository.getActiveHabits();
      final todayWeekday = DateTime.now().weekday;
      final activeToday = habits
          .where((h) => h.activeDays.contains(todayWeekday))
          .toList();
      return Success(activeToday);
    } on Exception catch (e) {
      return Failure('Failed to load today\'s habits', e);
    }
  }

  /// Get single habit by ID
  Future<Result<Habit>> byId(String id) async {
    try {
      final habit = await _repository.getHabitById(id);
      if (habit == null) {
        return const Failure('Habit not found');
      }
      return Success(habit);
    } on Exception catch (e) {
      return Failure('Failed to load habit', e);
    }
  }
}
