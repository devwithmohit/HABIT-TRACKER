import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../../providers/habits_provider.dart';
import 'widgets/habit_tile.dart';
import '../settings/settings_screen.dart';
import '../add_habit/add_habit_screen.dart';

/// Home screen showing habit list
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsState = ref.watch(habitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context, ref, habitsState),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddHabitScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, HabitsState habitsState) {
    if (habitsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (habitsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(habitsState.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(habitsProvider.notifier).loadHabits(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (habitsState.habits.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Today's progress card
        _buildProgressCard(context, habitsState.habits),

        // Habit list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: habitsState.habits.length,
            itemBuilder: (context, index) {
              final habitWithStreak = habitsState.habits[index];
              return HabitTile(
                habitWithStreak: habitWithStreak,
                onTap: () {
                  // Navigate to habit detail
                },
                onToggle: (isComplete) async {
                  // Show immediate feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isComplete
                          ? '✓ ${habitWithStreak.habit.name} completed!'
                          : '○ ${habitWithStreak.habit.name} unmarked'
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // Update the habit log
                  if (isComplete) {
                    await ref.read(habitLogsProvider.notifier).markComplete(
                          habitWithStreak.habit.id,
                          DateTime.now(),
                        );
                  } else {
                    await ref.read(habitLogsProvider.notifier).unmarkToday(
                          habitWithStreak.habit.id,
                        );
                  }

                  // Refresh the habits list to show updated state
                  ref.read(habitsProvider.notifier).loadHabits();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first habit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, List habitsWithStreak) {
    final total = habitsWithStreak.length;
    final completed = 0; // TODO: Calculate from today's logs
    final rate = total > 0 ? (completed / total * 100).toInt() : 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(context, completed.toString(), 'Completed'),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStat(context, total.toString(), 'Total'),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStat(context, '$rate%', 'Rate'),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
