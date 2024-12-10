/// Utility functions for the application
class Utils {
  /// Format a number to a specified number of decimal places
  static String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  /// Validate if a string is a valid number
  static bool isValidNumber(String value) {
    if (value.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  /// Clamp a value between a minimum and maximum
  static double clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
