import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Format date as 'MMM dd, yyyy' (e.g., Jan 15, 2024)
  String toFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  /// Format date as 'MM/dd/yyyy'
  String toShortDate() {
    return DateFormat('MM/dd/yyyy').format(this);
  }

  /// Format date as 'EEEE, MMMM dd, yyyy' (e.g., Monday, January 15, 2024)
  String toLongDate() {
    return DateFormat('EEEE, MMMM dd, yyyy').format(this);
  }

  /// Format time as 'hh:mm a' (e.g., 02:30 PM)
  String toFormattedTime() {
    return DateFormat('hh:mm a').format(this);
  }

  /// Format date and time
  String toFormattedDateTime() {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(this);
  }

  /// Get relative time (e.g., '2 hours ago', 'yesterday')
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes minute${minutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }

  /// Check if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Get the start of the day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  /// Get the end of the day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  /// Get the start of the month
  DateTime get startOfMonth {
    return DateTime(year, month);
  }

  /// Get the end of the month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0, 23, 59, 59, 999);
  }

  /// Get the start of the year
  DateTime get startOfYear {
    return DateTime(year);
  }

  /// Get the end of the year
  DateTime get endOfYear {
    return DateTime(year, 12, 31, 23, 59, 59, 999);
  }

  /// Check if date is between two dates
  bool isBetween(DateTime start, DateTime end) {
    return (isAfter(start) || isAtSameMomentAs(start)) &&
        (isBefore(end) || isAtSameMomentAs(end));
  }

  /// Get days difference
  int daysDifference(DateTime other) {
    return difference(other).inDays;
  }

  /// Format for API (ISO 8601)
  String toIso8601String() {
    return toIso8601String();
  }
}

extension NullableDateTimeExtensions on DateTime? {
  /// Check if null or past
  bool get isNullOrPast {
    return this == null || this!.isPast;
  }

  /// Format date safely
  String toFormattedDate() {
    if (this == null) return 'N/A';
    return this!.toFormattedDate();
  }

  /// Format time safely
  String toFormattedTime() {
    if (this == null) return 'N/A';
    return this!.toFormattedTime();
  }

  /// Get relative time safely
  String toRelativeTime() {
    if (this == null) return 'N/A';
    return this!.toRelativeTime();
  }
}
