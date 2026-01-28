import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatter {
  // Common date formats
  static final DateFormat _dayMonthYear = DateFormat('dd MMM yyyy');
  static final DateFormat _monthDay = DateFormat('MMM dd');
  static final DateFormat _dayOfWeek = DateFormat('EEEE');
  static final DateFormat _shortDayOfWeek = DateFormat('EEE');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _time = DateFormat('HH:mm');
  static final DateFormat _time12 = DateFormat('hh:mm a');

  /// Format date as "15 Jan 2026"
  static String formatDayMonthYear(DateTime date) {
    return _dayMonthYear.format(date);
  }

  /// Format date as "Jan 15"
  static String formatMonthDay(DateTime date) {
    return _monthDay.format(date);
  }

  /// Format date as "Monday"
  static String formatDayOfWeek(DateTime date) {
    return _dayOfWeek.format(date);
  }

  /// Format date as "Mon"
  static String formatShortDayOfWeek(DateTime date) {
    return _shortDayOfWeek.format(date);
  }

  /// Format date as "January 2026"
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  /// Format time as "14:30"
  static String formatTime(DateTime time) {
    return _time.format(time);
  }

  /// Format time as "02:30 PM"
  static String formatTime12Hour(DateTime time) {
    return _time12.format(time);
  }

  /// Get relative date string (Today, Yesterday, Tomorrow, or date)
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1 && difference < 7) return formatDayOfWeek(date);

    return formatMonthDay(date);
  }

  /// Get short relative date (Today, Tmr, Yest, or short date)
  static String getShortRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final difference = targetDate.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tmr';
    if (difference == -1) return 'Yest';

    return formatShortDayOfWeek(date);
  }

  /// Get time ago string (5m ago, 2h ago, 3d ago)
  static String getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  /// Check if date is in current week (Monday to Sunday)
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is in current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Get start of day (midnight)
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get day name from weekday number (1-7, Monday-Sunday)
  static String getDayName(int weekday, {bool short = false}) {
    const fullNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const shortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (weekday < 1 || weekday > 7) return '';

    return short ? shortNames[weekday - 1] : fullNames[weekday - 1];
  }

  /// Get list of dates for current week
  static List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  /// Get list of dates for a specific month
  static List<DateTime> getMonthDates(int year, int month) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    return List.generate(lastDay.day, (index) {
      return DateTime(year, month, index + 1);
    });
  }
}
