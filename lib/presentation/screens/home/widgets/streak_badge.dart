import 'package:flutter/material.dart';
import '../../../../domain/value_objects/streak.dart';
import '../../../theme/app_colors.dart';

/// Streak badge widget showing current streak
class StreakBadge extends StatelessWidget {
  final Streak streak;
  final bool showLongest;
  final bool compact;

  const StreakBadge({
    super.key,
    required this.streak,
    this.showLongest = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildDefault(context);
  }

  Widget _buildDefault(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.getStreakColor(streak.current).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getStreakColor(streak.current).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 18,
            color: AppColors.getStreakColor(streak.current),
          ),
          const SizedBox(width: 4),
          Text(
            '${streak.current}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.getStreakColor(streak.current),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_fire_department,
          size: 16,
          color: AppColors.getStreakColor(streak.current),
        ),
        const SizedBox(width: 2),
        Text(
          '${streak.current}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.getStreakColor(streak.current),
          ),
        ),
      ],
    );
  }
}

/// Detailed streak card showing current and longest streaks
class StreakCard extends StatelessWidget {
  final Streak streak;

  const StreakCard({
    super.key,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current streak
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 48,
                  color: AppColors.getStreakColor(streak.current),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${streak.current} days',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.getStreakColor(streak.current),
                          ),
                    ),
                    Text(
                      'Current Streak',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Divider
            const Divider(),

            const SizedBox(height: 16),

            // Longest streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.emoji_events,
                  label: 'Longest',
                  value: '${streak.longest}',
                  color: AppColors.warning,
                ),
                _buildStatItem(
                  context,
                  icon: Icons.today,
                  label: 'Status',
                  value: streak.isActiveToday ? 'Done' : 'Pending',
                  color: streak.isActiveToday ? AppColors.success : AppColors.info,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Motivational message
            Text(
              streak.getStatus(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.getStreakColor(streak.current),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
