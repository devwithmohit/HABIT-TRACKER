import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/dto/result.dart';
import '../../../application/usecases/analytics/get_weekly_summary.dart';
import '../../../core/di/injection.dart';

/// Statistics screen showing weekly bar chart, monthly rate, and per-habit analytics
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  WeeklySummary? _weeklySummary;
  bool _isLoading = true;
  String? _error;

  // Per-habit stats
  List<_HabitStat> _habitStats = [];

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load weekly summary
      final weeklyUseCase = ref.read(getWeeklySummaryProvider);
      final result = await weeklyUseCase();

      if (result.isSuccess) {
        _weeklySummary = (result as Success<WeeklySummary>).data;
      } else {
        _error = result.errorOrNull ?? 'Failed to load statistics';
      }

      // Load per-habit stats
      final repository = ref.read(habitRepositoryProvider);
      final habits = await repository.getActiveHabits();
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final stats = <_HabitStat>[];
      for (final habit in habits) {
        final logs = await repository.getLogsForDateRange(
          habitId: habit.id,
          startDate: thirtyDaysAgo,
          endDate: now,
        );

        final completedLogs = logs.where((l) => l.isCompleted).length;

        // Count active days in last 30 days
        int activeDaysCount = 0;
        for (var d = thirtyDaysAgo;
            d.isBefore(now.add(const Duration(days: 1)));
            d = d.add(const Duration(days: 1))) {
          if (habit.isActiveOnDay(d.weekday)) activeDaysCount++;
        }

        final rate =
            activeDaysCount > 0 ? (completedLogs / activeDaysCount) * 100 : 0.0;

        stats.add(_HabitStat(
          name: habit.name,
          icon: habit.icon,
          color: habit.color,
          completions: completedLogs,
          activeDays: activeDaysCount,
          rate: rate,
        ));
      }

      // Sort by rate descending
      stats.sort((a, b) => b.rate.compareTo(a.rate));

      if (mounted) {
        setState(() {
          _habitStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStatistics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStatistics,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_weeklySummary != null) ...[
                        _buildOverviewCard(context),
                        const SizedBox(height: 16),
                        _buildWeeklyBarChart(context),
                        const SizedBox(height: 16),
                        _buildBestWorstDay(context),
                        const SizedBox(height: 16),
                      ],
                      _buildHabitStatsSection(context),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    final summary = _weeklySummary!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Week',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                    context, '${summary.completionRate.toStringAsFixed(0)}%',
                    'Completion'),
                _buildStatColumn(context, '${summary.totalCompletions}',
                    'Completed'),
                _buildStatColumn(context, '${summary.possibleCompletions}',
                    'Target'),
                _buildStatColumn(
                    context, '${summary.totalHabits}', 'Habits'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context) {
    final summary = _weeklySummary!;
    final maxVal = summary.dailyCompletions.values.fold<int>(
        1, (prev, el) => el > prev ? el : prev);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Completions',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            SizedBox(
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final day = index + 1; // 1=Mon .. 7=Sun
                  final count = summary.dailyCompletions[day] ?? 0;
                  final height = maxVal > 0 ? (count / maxVal) * 120 : 0.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('$count',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: height.clamp(4, 120).toDouble(),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(count > 0 ? 1.0 : 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(summary.getDayName(day),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestWorstDay(BuildContext context) {
    final summary = _weeklySummary!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                  const SizedBox(height: 8),
                  Text('Best Day',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(summary.bestDayName,
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            Container(width: 1, height: 60, color: Colors.grey.shade300),
            Expanded(
              child: Column(
                children: [
                  const Icon(Icons.trending_down,
                      color: Colors.redAccent, size: 32),
                  const SizedBox(height: 8),
                  Text('Needs Work',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(summary.worstDayName,
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitStatsSection(BuildContext context) {
    if (_habitStats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: Text('No habits to analyze')),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text('Per-Habit Performance (30 days)',
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        ...List.generate(_habitStats.length, (index) {
          final stat = _habitStats[index];
          final color = _parseColor(stat.color);

          return Card(
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                    child:
                        Text(stat.icon, style: const TextStyle(fontSize: 22))),
              ),
              title: Text(stat.name),
              subtitle: Text(
                  '${stat.completions}/${stat.activeDays} days completed'),
              trailing: SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${stat.rate.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: stat.rate >= 80
                              ? Colors.green
                              : stat.rate >= 50
                                  ? Colors.orange
                                  : Colors.red,
                        )),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stat.rate / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: stat.rate >= 80
                            ? Colors.green
                            : stat.rate >= 50
                                ? Colors.orange
                                : Colors.red,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_weeklySummary != null && _weeklySummary!.perfectHabits.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text('Perfect This Week!',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.green.shade700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._weeklySummary!.perfectHabits.map(
                      (name) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('⭐ $name'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final buffer = StringBuffer();
      if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
      buffer.write(hexColor.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}

class _HabitStat {
  final String name;
  final String icon;
  final String color;
  final int completions;
  final int activeDays;
  final double rate;

  _HabitStat({
    required this.name,
    required this.icon,
    required this.color,
    required this.completions,
    required this.activeDays,
    required this.rate,
  });
}
