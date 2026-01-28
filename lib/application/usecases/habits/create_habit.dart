import '../../../domain/entities/habit.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../dto/result.dart';

/// Use case: Create a new habit
class CreateHabit {
  final HabitRepository _repository;

  CreateHabit(this._repository);

  Future<Result<Habit>> call({
    required String id,
    required String name,
    required String icon,
    required String color,
    required List<int> activeDays,
  }) async {
    try {
      // Validate inputs
      if (name.trim().isEmpty) {
        return const Failure('Habit name cannot be empty');
      }

      if (activeDays.isEmpty) {
        return const Failure('Please select at least one active day');
      }

      if (activeDays.any((day) => day < 1 || day > 7)) {
        return const Failure('Invalid active days');
      }

      // Create habit entity
      final habit = Habit(
        id: id,
        name: name.trim(),
        icon: icon,
        color: color,
        activeDays: activeDays,
        createdAt: DateTime.now(),
        isArchived: false,
      );

      // Save to repository
      await _repository.createHabit(habit);

      return Success(habit);
    } on Exception catch (e) {
      return Failure('Failed to create habit', e);
    }
  }
}
