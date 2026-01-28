import '../../../domain/repositories/habit_repository.dart';
import '../../dto/result.dart';

/// Use case: Delete a habit permanently
class DeleteHabit {
  final HabitRepository _repository;

  DeleteHabit(this._repository);

  Future<Result<void>> call(String habitId) async {
    try {
      // Check if habit exists
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        return const Failure('Habit not found');
      }

      // Delete habit and all its logs
      await _repository.deleteHabit(habitId);

      return const Success(null);
    } on Exception catch (e) {
      return Failure('Failed to delete habit', e);
    }
  }

  /// Archive habit instead of deleting
  Future<Result<void>> archive(String habitId) async {
    try {
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        return const Failure('Habit not found');
      }

      await _repository.archiveHabit(habitId, true);

      return const Success(null);
    } on Exception catch (e) {
      return Failure('Failed to archive habit', e);
    }
  }

  /// Unarchive habit
  Future<Result<void>> unarchive(String habitId) async {
    try {
      final habit = await _repository.getHabitById(habitId);
      if (habit == null) {
        return const Failure('Habit not found');
      }

      await _repository.archiveHabit(habitId, false);

      return const Success(null);
    } on Exception catch (e) {
      return Failure('Failed to unarchive habit', e);
    }
  }
}
