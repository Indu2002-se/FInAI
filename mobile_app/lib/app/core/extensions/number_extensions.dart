import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  /// Format as currency
  String toCurrency({String locale = 'en_US', String symbol = '\$'}) {
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(this);
  }

  /// Format as percentage
  String toPercentage({int decimalPlaces = 2}) {
    return '${toStringAsFixed(decimalPlaces)}%';
  }

  /// Format with thousand separators
  String toFormattedString({int decimalPlaces = 2}) {
    final formatter = NumberFormat('###,##0.##', 'en_US');
    return formatter.format(this);
  }

  /// Convert to shortened format (e.g., 1.2K, 1.5M)
  String toShortFormat() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toStringAsFixed(2);
  }

  /// Check if number is positive
  bool get isPositive => this > 0;

  /// Check if number is negative
  bool get isNegative => this < 0;

  /// Check if number is zero
  bool get isZero => this == 0;

  /// Absolute value
  double get abs => this < 0 ? -this : this;
}

extension IntExtensions on int {
  /// Format as currency
  String toCurrency({String locale = 'en_US', String symbol = '\$'}) {
    final formatter = NumberFormat.currency(locale: locale, symbol: symbol);
    return formatter.format(this);
  }

  /// Format as percentage
  String toPercentage() {
    return '$this%';
  }

  /// Format with thousand separators
  String toFormattedString() {
    final formatter = NumberFormat('###,##0', 'en_US');
    return formatter.format(this);
  }

  /// Convert to shortened format
  String toShortFormat() {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }

  /// Check if number is positive
  bool get isPositive => this > 0;

  /// Check if number is negative
  bool get isNegative => this < 0;

  /// Check if number is zero
  bool get isZero => this == 0;

  /// Check if number is even
  bool get isEven => this % 2 == 0;

  /// Check if number is odd
  bool get isOdd => this % 2 != 0;

  /// Absolute value
  int get abs => this < 0 ? -this : this;
}

extension NullableDoubleExtensions on double? {
  /// Check if null or zero
  bool get isNullOrZero {
    return this == null || this == 0;
  }

  /// Format as currency
  String toCurrency({String locale = 'en_US', String symbol = '\$'}) {
    if (this == null) return symbol + '0.00';
    return this!.toCurrency(locale: locale, symbol: symbol);
  }

  /// Format with thousand separators
  String toFormattedString({int decimalPlaces = 2}) {
    if (this == null) return '0.00';
    return this!.toFormattedString();
  }
}

extension NullableIntExtensions on int? {
  /// Check if null or zero
  bool get isNullOrZero {
    return this == null || this == 0;
  }

  /// Format as currency
  String toCurrency({String locale = 'en_US', String symbol = '\$'}) {
    if (this == null) return symbol + '0';
    return this!.toCurrency(locale: locale, symbol: symbol);
  }

  /// Format with thousand separators
  String toFormattedString() {
    if (this == null) return '0';
    return this!.toFormattedString();
  }
}
