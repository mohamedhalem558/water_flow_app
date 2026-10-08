/// Formatters for water monitoring telemetry data, numbers, and dates.
class AppFormatters {
  /// Format flow rate with 1 decimal place (e.g. "18.4")
  static String formatFlow(double flowRate) {
    return flowRate.toStringAsFixed(1);
  }

  /// Format volume in liters with comma separator and 1 decimal place
  /// e.g. 1250.4 -> "1,250.4"
  static String formatVolume(double liters) {
    if (liters >= 100000) {
      return (liters / 1000).toStringAsFixed(2) + ' kL';
    }
    final parts = liters.toStringAsFixed(1).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      if (i > 0 && (integerPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(integerPart[i]);
    }
    return '${buffer.toString()}.$decimalPart';
  }

  /// Format cubic meters from liters
  static String formatCubicMeters(double liters) {
    final m3 = liters / 1000.0;
    return '${m3.toStringAsFixed(2)} m³';
  }

  /// Format duration nicely (e.g. "12m 45s" or "1h 15m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Format date and time (e.g. "Oct 08, 2026 • 14:35")
  static String formatDateTime(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final day = dt.day.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');

    return '$month $day, $year • $hour:$minute';
  }

  /// Format time only with seconds (e.g. "14:35:12")
  static String formatTimeWithSeconds(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Format time only (e.g. "14:35")
  static String formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format date only (e.g. "Oct 08")
  static String formatDateShort(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  /// Format weekday short (e.g. "Mon", "Tue")
  static String formatWeekday(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dt.weekday - 1];
  }
}
