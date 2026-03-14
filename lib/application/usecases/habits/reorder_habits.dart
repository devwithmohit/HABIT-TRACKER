import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../dto/result.dart';

/// Use case: Reorder habits (change display order)
class ReorderHabits {
  final HabitRepository _repository;

  ReorderHabits(this._repository);

  /// Reorder habits based on provided IDs list
  /// IDs should be in desired display order
  Future<Result<List<Habit>>> call(List<String> orderedIds) async {
    try {
      if (orderedIds.isEmpty) {
        return const Failure('No habits to reorder');
      }

      // Get all habits
      final allHabits = await _repository.getAllHabits();

      // Create a map for quick lookup
      final habitMap = {for (var h in allHabits) h.id: h};

      // Build ordered list and persist sort order
      final orderedHabits = <Habit>[];
      for (int i = 0; i < orderedIds.length; i++) {
        final habit = habitMap[orderedIds[i]];
        if (habit != null) {
          final updated = habit.copyWith(sortOrder: i);
          await _repository.updateHabit(updated);
          orderedHabits.add(updated);
        }
      }

      return Success(orderedHabits);
    } on Exception catch (e) {
      return Failure('Failed to reorder habits', e);
    }
  }

  /// Sort habits by creation date
  Future<Result<List<Habit>>> sortByCreationDate({bool ascending = true}) async {
    try {
      final habits = await _repository.getActiveHabits();
      habits.sort((a, b) {
        final comparison = a.createdAt.compareTo(b.createdAt);
        return ascending ? comparison : -comparison;
      });
      return Success(habits);
    } on Exception catch (e) {
      return Failure('Failed to sort habits', e);
    }
  }

  /// Sort habits by name
  Future<Result<List<Habit>>> sortByName({bool ascending = true}) async {
    try {
      final habits = await _repository.getActiveHabits();
      habits.sort((a, b) {
        final comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return ascending ? comparison : -comparison;
      });
      return Success(habits);
    } on Exception catch (e) {
      return Failure('Failed to sort habits', e);
    }
  }
}
