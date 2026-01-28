import 'package:flutter/material.dart';

/// Calendar view screen showing habit completion history
/// Note: Full implementation requires:
/// - Calendar widget (table_calendar package)
/// - Heatmap visualization
/// - Date selection
/// - Habit filtering
/// - Riverpod provider integration
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          // Month/Year header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    // Previous month
                  },
                ),
                Text(
                  'January 2026',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    // Next month
                  },
                ),
              ],
            ),
          ),

          // Calendar grid (placeholder)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Center(
                  child: Text(
                    'Calendar view will go here\n\n'
                    'Use table_calendar package\n'
                    'Show completion dots/colors',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),

          // Habit list for selected date
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Today\'s Habits',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Divider(height: 1),
                  const Expanded(
                    child: Center(
                      child: Text('Habit list for selected date'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
