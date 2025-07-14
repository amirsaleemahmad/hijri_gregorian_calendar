import 'package:hijri_gregorian_calendar/src/hijri_converter.dart';

import '../hijri_gregorian_calendar.dart';

/// Represents a Hijri date with day, month, and year components.
class HijriDate {
  final int day;
  final int month;
  final int year;

  /// Creates a new HijriDate instance.
  ///
  /// [day] must be between 1 and 30
  /// [month] must be between 1 and 12
  /// [year] must be positive
  HijriDate({
    required this.day,
    required this.month,
    required this.year,
  }) : assert(day >= 1 && day <= 30, 'Day must be between 1 and 30'),
       assert(month >= 1 && month <= 12, 'Month must be between 1 and 12'),
       assert(year > 0, 'Year must be positive');

  /// Creates a HijriDate from the current date
  factory HijriDate.now() {
    return HijriConverter.gregorianToHijri(DateTime.now());
  }

  /// Hijri month names in Arabic
  static const List<String> monthNamesArabic = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الثانية',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
  ];

  /// Hijri month names in English
  static const List<String> monthNamesEnglish = [
    'Muharram', 'Safar', 'Rabi\' al-awwal', 'Rabi\' al-thani', 'Jumada al-awwal', 'Jumada al-thani',
    'Rajab', 'Sha\'ban', 'Ramadan', 'Shawwal', 'Dhu al-Qi\'dah', 'Dhu al-Hijjah'
  ];

  /// Gets the month name in Arabic
  String get monthNameArabic => monthNamesArabic[month - 1];

  /// Gets the month name in English
  String get monthNameEnglish => monthNamesEnglish[month - 1];

  /// Converts this HijriDate to a Gregorian DateTime
  DateTime toGregorian() {
    return HijriConverter.hijriToGregorian(this);
  }

  /// Returns a formatted string representation of the date
  String format({bool useArabicNames = false}) {
    final monthName = useArabicNames ? monthNameArabic : monthNameEnglish;
    return '$day $monthName $year';
  }

  @override
  String toString() => '$day/$month/$year H';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HijriDate &&
        other.day == day &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode => day.hashCode ^ month.hashCode ^ year.hashCode;
}
