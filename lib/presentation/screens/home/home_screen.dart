import 'package:flutter/material.dart';
import 'widgets/habit_tile.dart';

/// Home screen showing habit list
/// Note: This is a basic structure. Full implementation requires:
/// - Riverpod provider integration
/// - Pull to refresh
/// - Empty state
/// - Loading state
/// - Error handling
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
              // Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Today's progress card
          _buildProgressCard(context),

          // Habit list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              children: [
                // HabitTile widgets will go here
                // Using provider: ref.watch(habitsProvider)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Add your first habit!',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add habit screen
          // Navigator.pushNamed(context, '/add-habit');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
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
          _buildStat(context, '0', 'Completed'),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStat(context, '0', 'Total'),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildStat(context, '0%', 'Rate'),
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
