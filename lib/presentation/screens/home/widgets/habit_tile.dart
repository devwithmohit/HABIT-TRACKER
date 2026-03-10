import 'package:flutter/material.dart';
import '../../../../application/dto/habit_with_streak.dart';
import '../../../theme/app_colors.dart';
import 'streak_badge.dart';

/// Habit list tile widget
class HabitTile extends StatelessWidget {
  final HabitWithStreak habitWithStreak;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(bool)? onToggle;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const HabitTile({
    super.key,
    required this.habitWithStreak,
    this.onTap,
    this.onLongPress,
    this.onToggle,
    this.onArchive,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final habit = habitWithStreak.habit;
    final streak = habitWithStreak.streak;
    final isCompleted = streak.isActiveToday;

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Archive Habit'),
            content: Text('Archive "${habit.name}"? You can restore it later from settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Archive'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onArchive?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.archive, color: Colors.white, size: 28),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              GestureDetector(
                onTap: () => onToggle?.call(!isCompleted),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.fromHex(habit.color)
                        : Colors.transparent,
                    border: Border.all(
                      color: AppColors.fromHex(habit.color),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 16),

              // Habit icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.fromHex(habit.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    habit.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Habit name and active days
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isCompleted
                                ? Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getActiveDaysText(habit.activeDays),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Streak badge
              StreakBadge(streak: streak),
            ],
          ),
        ),
      ),
    ), // end Card
    ); // end Dismissible
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                onTap?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.orange),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                onArchive?.call();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
            'Permanently delete "${habitWithStreak.habit.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getActiveDaysText(List<int> activeDays) {
    if (activeDays.length == 7) return 'Every day';
    if (activeDays.length == 5 &&
        activeDays.contains(1) &&
        activeDays.contains(5) &&
        !activeDays.contains(6) &&
        !activeDays.contains(7)) {
      return 'Weekdays';
    }
    if (activeDays.length == 2 &&
        activeDays.contains(6) &&
        activeDays.contains(7)) {
      return 'Weekends';
    }

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return activeDays.map((day) => dayNames[day - 1]).join(', ');
  }
}
