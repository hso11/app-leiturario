class AppDateUtils {
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  static String readingDuration(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    if (days == 0) return '1 dia';
    if (days == 1) return '1 dia';
    return '$days dias';
  }
}
