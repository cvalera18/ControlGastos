import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('d \'de\' MMMM yyyy', 'es').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm', 'es').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy', 'es').format(date);
  }

  static String formatMonthShort(DateTime date) {
    return DateFormat('MMM yyyy', 'es').format(date);
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('d MMM', 'es').format(date);
  }

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    if (diff < 7) return 'Hace $diff días';
    return formatDate(date);
  }

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);
}
