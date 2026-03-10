import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/habit_log.dart';
import '../../utils/date_formatter.dart';

/// Calendar view screen showing habit completion history
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;
  Map<String, List<HabitLog>> _monthLogs = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _selectedDate = DateTime.now();
    _loadMonthLogs();
  }

  Future<void> _loadMonthLogs() async {
    setState(() => _isLoading = true);

    final repository = ref.read(habitRepositoryProvider);
    final habits = await repository.getActiveHabits();

    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    final allLogs = <String, List<HabitLog>>{};
    for (final habit in habits) {
      final logs = await repository.getLogsForDateRange(
        habitId: habit.id,
        startDate: firstDay,
        endDate: lastDay,
      );
      if (logs.isNotEmpty) {
        allLogs[habit.id] = logs;
      }
    }

    if (mounted) {
      setState(() {
        _monthLogs = allLogs;
        _isLoading = false;
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      _selectedDate = null;
    });
    _loadMonthLogs();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1, 1))) {
      setState(() {
        _focusedMonth = nextMonth;
        _selectedDate = null;
      });
      _loadMonthLogs();
    }
  }

  int _getCompletionsForDay(DateTime day) {
    int count = 0;
    final normalizedDay = HabitLog.normalizeDate(day);
    for (final logs in _monthLogs.values) {
      for (final log in logs) {
        if (log.date.isAtSameMomentAs(normalizedDay) && log.isCompleted) {
          count++;
        }
      }
    }
    return count;
  }

  int _getTotalHabitsForDay(DateTime day) {
    final habitsState = ref.read(habitsProvider);
    return habitsState.habits
        .where((h) => h.habit.activeDays.contains(day.weekday))
        .length;
  }

  Color _getDayColor(DateTime day) {
    final completions = _getCompletionsForDay(day);
    final total = _getTotalHabitsForDay(day);

    if (total == 0 || completions == 0) return Colors.transparent;
    final rate = completions / total;

    if (rate >= 1.0) return Colors.green.shade600;
    if (rate >= 0.5) return Colors.green.shade300;
    return Colors.green.shade100;
  }

  List<_DayHabitInfo> _getHabitsForSelectedDate() {
    if (_selectedDate == null) return [];

    final normalizedDate = HabitLog.normalizeDate(_selectedDate!);
    final habitsState = ref.read(habitsProvider);
    final result = <_DayHabitInfo>[];

    for (final hws in habitsState.habits) {
      if (!hws.habit.activeDays.contains(_selectedDate!.weekday)) continue;

      bool completed = false;
      for (final logs in _monthLogs.values) {
        for (final log in logs) {
          if (log.habitId == hws.habit.id &&
              log.date.isAtSameMomentAs(normalizedDate) &&
              log.isCompleted) {
            completed = true;
            break;
          }
        }
        if (completed) break;
      }

      result.add(_DayHabitInfo(
        name: hws.habit.name,
        icon: hws.habit.icon,
        color: hws.habit.color,
        completed: completed,
      ));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormatter.formatMonthYear(_focusedMonth),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Weekday headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),

          // Calendar grid
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else
            _buildCalendarGrid(context, daysInMonth, firstWeekday),

          const Divider(),

          // Selected day habits list
          Expanded(child: _buildSelectedDayHabits(context)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
      BuildContext context, int daysInMonth, int firstWeekday) {
    final today = DateTime.now();
    final offset = firstWeekday - 1;
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            children: List.generate(7, (col) {
              final index = row * 7 + col;
              if (index < offset || index >= offset + daysInMonth) {
                return const Expanded(child: SizedBox(height: 44));
              }

              final day = index - offset + 1;
              final date =
                  DateTime(_focusedMonth.year, _focusedMonth.month, day);
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected = _selectedDate != null &&
                  date.year == _selectedDate!.year &&
                  date.month == _selectedDate!.month &&
                  date.day == _selectedDate!.day;
              final dayColor = _getDayColor(date);

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: dayColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2)
                          : isToday
                              ? Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5))
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: dayColor != Colors.transparent
                              ? Colors.white
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedDayHabits(BuildContext context) {
    if (_selectedDate == null) {
      return const Center(
          child: Text('Tap a date to see habit completions'));
    }

    final habits = _getHabitsForSelectedDate();
    final dateLabel = DateFormatter.getRelativeDate(_selectedDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '$dateLabel — ${habits.where((h) => h.completed).length}/${habits.length} completed',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: habits.isEmpty
              ? const Center(
                  child: Text('No habits scheduled for this day'))
              : ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                                  '0xFF${habit.color.substring(1)}'))
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(habit.icon,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      title: Text(
                        habit.name,
                        style: TextStyle(
                          decoration: habit.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      trailing: Icon(
                        habit.completed
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: habit.completed ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _DayHabitInfo {
  final String name;
  final String icon;
  final String color;
  final bool completed;

  _DayHabitInfo({
    required this.name,
    required this.icon,
    required this.color,
    required this.completed,
  });
}
