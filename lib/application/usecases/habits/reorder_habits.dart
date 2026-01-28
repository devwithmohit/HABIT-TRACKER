import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../dto/result.dart';

/// Use case: Reorder habits (change display order)
/// Note: This requires adding an 'order' field to Habit entity in the future
/// For now, this is a placeholder that returns habits sorted by creation date
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

      // Build ordered list
      final orderedHabits = <Habit>[];
      for (final id in orderedIds) {
        final habit = habitMap[id];
        if (habit != null) {
          orderedHabits.add(habit);
        }
      }

      // TODO: In future, update each habit with new order index
      // For now, just return the ordered list
      // When implementing, add 'order' field to Habit entity

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
