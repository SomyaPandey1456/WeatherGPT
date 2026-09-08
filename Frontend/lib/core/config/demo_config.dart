class DemoConfig {
  /// Dynamic currentDate based on device's local clock
  static DateTime get currentDate => DateTime.now();

  static String get todayStr {
    final now = DateTime.now();
    return '${_monthName(now.month)} ${now.day}, ${now.year}';
  }

  static String get tomorrowStr {
    final tom = DateTime.now().add(const Duration(days: 1));
    return '${_monthName(tom.month)} ${tom.day}, ${tom.year}';
  }

  static String get yesterdayStr {
    final yest = DateTime.now().subtract(const Duration(days: 1));
    return '${_monthName(yest.month)} ${yest.day}, ${yest.year}';
  }

  static String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }
}
