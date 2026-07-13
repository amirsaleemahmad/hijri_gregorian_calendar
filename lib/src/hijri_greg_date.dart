import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

/// Represents a Hijri (Islamic) date with day, month, and year components.
///
/// Provides conversion to Gregorian, formatting in English/Arabic,
/// and comparison operators.
class HijriGregDate implements Comparable<HijriGregDate> {
  /// Day of the month (1–30).
  final int day;

  /// Month of the year (1–12).
  final int month;

  /// Hijri year (must be positive).
  final int year;

  /// Creates a new [HijriGregDate].
  ///
  /// Throws [AssertionError] in debug mode if values are out of range.
  HijriGregDate({required this.day, required this.month, required this.year})
    : assert(day >= 1 && day <= 30, 'Day must be between 1 and 30'),
      assert(month >= 1 && month <= 12, 'Month must be between 1 and 12'),
      assert(year > 0, 'Year must be positive');

  /// Creates a [HijriGregDate] representing today.
  factory HijriGregDate.now({int hijriAdjustment = 0}) {
    return HijriGregConverter.gregorianToHijri(DateTime.now(), hijriAdjustment: hijriAdjustment);
  }

  /// Creates a [HijriGregDate] from a Gregorian [DateTime].
  factory HijriGregDate.fromGregorian(DateTime date, {int hijriAdjustment = 0}) {
    return HijriGregConverter.gregorianToHijri(date, hijriAdjustment: hijriAdjustment);
  }

  // ---------------------------------------------------------------------------
  // Month names
  // ---------------------------------------------------------------------------

  /// Hijri month names in Arabic.
  static const List<String> monthNamesArabic = ['محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الثانية', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'];

  /// Hijri month names in English.
  static const List<String> monthNamesEnglish = [
    'Muharram',
    'Safar',
    'Rabi\' al-Awwal',
    'Rabi\' al-Thani',
    'Jumada al-Ula',
    'Jumada al-Thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah',
  ];

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Month name in Arabic.
  String get monthNameArabic => monthNamesArabic[month - 1];

  /// Month name in English.
  String get monthNameEnglish => monthNamesEnglish[month - 1];

  /// Number of days in this month.
  int get daysInMonth => HijriGregConverter.getHijriMonthLength(year, month);

  /// Whether [year] is a Hijri leap year.
  bool get isLeapYear => HijriGregConverter.isHijriLeapYear(year);

  // ---------------------------------------------------------------------------
  // Conversion & formatting
  // ---------------------------------------------------------------------------

  /// Converts this Hijri date to a Gregorian [DateTime].
  DateTime toGregorian({int hijriAdjustment = 0}) => HijriGregConverter.hijriToGregorian(this, hijriAdjustment: hijriAdjustment);

  /// Returns the Islamic holiday name if this date corresponds to a major holiday,
  /// otherwise returns null.
  String? getIslamicHoliday() {
    if (month == 1 && day == 1) return 'Islamic New Year';
    if (month == 1 && day == 10) return 'Ashura';
    if (month == 3 && day == 12) return 'Mawlid al-Nabi';
    if (month == 9 && day == 1) return 'Ramadan Start';
    if (month == 12 && day == 9) return 'Arafah Day';
    if (month == 12 && day == 10) return 'Eid al-Adha';
    if (month == 10 && day == 1) return 'Eid al-Fitr';
    return null;
  }

  /// Returns a human-readable representation.
  ///
  /// ```dart
  /// HijriGregDate(day: 15, month: 9, year: 1445).format(); // "15 Ramadan 1445"
  /// ```
  String format({bool useArabicNames = false}) {
    final monthName = useArabicNames ? monthNameArabic : monthNameEnglish;
    return '$day $monthName $year';
  }

  /// Returns a new [HijriGregDate] with optionally replaced fields.
  HijriGregDate copyWith({int? day, int? month, int? year}) {
    return HijriGregDate(day: day ?? this.day, month: month ?? this.month, year: year ?? this.year);
  }

  // ---------------------------------------------------------------------------
  // Comparison & equality
  // ---------------------------------------------------------------------------

  @override
  int compareTo(HijriGregDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  /// Whether this date is before [other].
  bool isBefore(HijriGregDate other) => compareTo(other) < 0;

  /// Whether this date is after [other].
  bool isAfter(HijriGregDate other) => compareTo(other) > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HijriGregDate && other.day == day && other.month == month && other.year == year;
  }

  @override
  int get hashCode => Object.hash(day, month, year);

  @override
  String toString() => '$day/$month/$year H';
}
