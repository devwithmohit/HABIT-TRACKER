import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_log.dart';
import '../../domain/repositories/habit_repository.dart';

/// Service for exporting habit data to CSV format
class ExportService {
  final HabitRepository _repository;

  ExportService(this._repository);

  /// Export all habit data to a CSV file and return the file path
  Future<String?> exportToCsv() async {
    try {
      if (kIsWeb) return null; // File system not available on web

      final habits = await _repository.getAllHabits(includeArchived: true);
      final buffer = StringBuffer();

      // Header
      buffer.writeln(
          'Habit Name,Icon,Color,Active Days,Archived,Created At,Date,Completed,Completed At');

      for (final habit in habits) {
        final logs = await _repository.getLogsForHabit(habit.id);

        if (logs.isEmpty) {
          // Write habit with no logs
          buffer.writeln(_habitRow(habit, null));
        } else {
          for (final log in logs) {
            buffer.writeln(_habitRow(habit, log));
          }
        }
      }

      // Write to file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/habit_tracker_export_$timestamp.csv');
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      if (kDebugMode) print('Export error: $e');
      return null;
    }
  }

  /// Export summary statistics to a text-based report
  Future<String?> exportReport() async {
    try {
      if (kIsWeb) return null;

      final habits = await _repository.getActiveHabits();
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final buffer = StringBuffer();

      buffer.writeln('=== Habit Tracker Report ===');
      buffer.writeln('Generated: ${DateFormat.yMMMd().add_jm().format(now)}');
      buffer.writeln('');
      buffer.writeln('Total Active Habits: ${habits.length}');
      buffer.writeln('');

      for (final habit in habits) {
        final logs = await _repository.getLogsForDateRange(
          habitId: habit.id,
          startDate: thirtyDaysAgo,
          endDate: now,
        );
        final completed = logs.where((l) => l.isCompleted).length;

        int activeDays = 0;
        for (var d = thirtyDaysAgo;
            d.isBefore(now.add(const Duration(days: 1)));
            d = d.add(const Duration(days: 1))) {
          if (habit.isActiveOnDay(d.weekday)) activeDays++;
        }

        final rate =
            activeDays > 0 ? (completed / activeDays * 100).toStringAsFixed(1) : '0.0';

        buffer.writeln('${habit.icon} ${habit.name}');
        buffer.writeln('  Completed: $completed/$activeDays days (${rate}%)');
        buffer.writeln(
            '  Active on: ${_formatActiveDays(habit.activeDays)}');
        buffer.writeln('');
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file =
          File('${directory.path}/habit_tracker_report_$timestamp.txt');
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      if (kDebugMode) print('Report export error: $e');
      return null;
    }
  }

  String _habitRow(Habit habit, HabitLog? log) {
    final activeDays = _formatActiveDays(habit.activeDays);
    final dateStr = log != null
        ? DateFormat('yyyy-MM-dd').format(log.date)
        : '';
    final completedStr = log != null ? (log.isCompleted ? 'Yes' : 'No') : '';
    final completedAtStr = log?.completedAt != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(log!.completedAt!)
        : '';

    return '"${_escapeCsv(habit.name)}","${habit.icon}","${habit.color}",'
        '"$activeDays","${habit.isArchived ? 'Yes' : 'No'}",'
        '"${DateFormat('yyyy-MM-dd').format(habit.createdAt)}",'
        '"$dateStr","$completedStr","$completedAtStr"';
  }

  String _escapeCsv(String value) {
    return value.replaceAll('"', '""');
  }

  String _formatActiveDays(List<int> days) {
    if (days.length == 7) return 'Every day';
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => dayNames[d - 1]).join(', ');
  }
}
