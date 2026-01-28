import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../dto/result.dart';

/// Use case: Update an existing habit
class UpdateHabit {
  final HabitRepository _repository;

  UpdateHabit(this._repository);

  Future<Result<Habit>> call(Habit habit) async {
    try {
      // Validate inputs
      if (habit.name.trim().isEmpty) {
        return const Failure('Habit name cannot be empty');
      }

      if (habit.activeDays.isEmpty) {
        return const Failure('Please select at least one active day');
      }

      // Check if habit exists
      final existingHabit = await _repository.getHabitById(habit.id);
      if (existingHabit == null) {
        return const Failure('Habit not found');
      }

      // Update repository
      await _repository.updateHabit(habit);

      return Success(habit);
    } on Exception catch (e) {
      return Failure('Failed to update habit', e);
    }
  }

  /// Update specific fields without loading full habit
  Future<Result<Habit>> updateFields({
    required String habitId,
    String? name,
    String? icon,
    String? color,
    List<int>? activeDays,
    bool? isArchived,
  }) async {
    try {
      final existingHabit = await _repository.getHabitById(habitId);
      if (existingHabit == null) {
        return const Failure('Habit not found');
      }

      final updatedHabit = existingHabit.copyWith(
        name: name,
        icon: icon,
        color: color,
        activeDays: activeDays,
        isArchived: isArchived,
      );

      return call(updatedHabit);
    } on Exception catch (e) {
      return Failure('Failed to update habit fields', e);
    }
  }
}
