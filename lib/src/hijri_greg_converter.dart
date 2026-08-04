import 'hijri_greg_date.dart';

/// Utility class for converting between Hijri and Gregorian calendars.
/// Uses astronomical calculations based on the Umm al-Qura calendar system.
class HijriGregConverter {
  static const int _hijriEpoch = 1948440; // Julian day of Hijri epoch (July 16, 622 CE)

  // Simple caches to reduce repeated computation. Keys are Julian day numbers.
  static final Map<int, HijriGregDate> _gregToHijriCache = {};
  static final Map<int, DateTime> _hijriToGregCache = {};
  static const int _cacheLimit = 500;

  static void _addToGregCache(int julian, HijriGregDate value) {
    if (_gregToHijriCache.length > _cacheLimit) {
      _gregToHijriCache.remove(_gregToHijriCache.keys.first);
    }
    _gregToHijriCache[julian] = value;
  }

  static void _addToHijriCache(int julian, DateTime value) {
    if (_hijriToGregCache.length > _cacheLimit) {
      _hijriToGregCache.remove(_hijriToGregCache.keys.first);
    }
    _hijriToGregCache[julian] = value;
  }

  /// Converts a Gregorian DateTime to HijriGregDate
  static HijriGregDate gregorianToHijri(DateTime gregorianDate, {int hijriAdjustment = 0}) {
    int baseJulian = _gregorianToJulian(gregorianDate);
    int julianDay = baseJulian + hijriAdjustment;

    if (_gregToHijriCache.containsKey(julianDay)) {
      return _gregToHijriCache[julianDay]!;
    }

    final result = _julianToHijri(julianDay);
    _addToGregCache(julianDay, result);
    return result;
  }

  /// Converts a HijriGregDate to Gregorian DateTime
  static DateTime hijriToGregorian(HijriGregDate hijriDate, {int hijriAdjustment = 0}) {
    int julian = _hijriToJulian(hijriDate) - hijriAdjustment;
    if (_hijriToGregCache.containsKey(julian)) {
      return _hijriToGregCache[julian]!;
    }
    final result = _julianToGregorian(julian);
    _addToHijriCache(julian, result);
    return result;
  }

  /// Converts Gregorian date to Julian day number
  static int _gregorianToJulian(DateTime date) {
    int year = date.year;
    int month = date.month;
    int day = date.day;

    if (month <= 2) {
      year--;
      month += 12;
    }

    int a = year ~/ 100;
    int b = 2 - a + (a ~/ 4);

    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524;
  }

  /// Converts Julian day number to Gregorian date
  static DateTime _julianToGregorian(int julianDay) {
    int a = julianDay + 32044;
    int b = (4 * a + 3) ~/ 146097;
    int c = a - (146097 * b) ~/ 4;
    int d = (4 * c + 3) ~/ 1461;
    int e = c - (1461 * d) ~/ 4;
    int m = (5 * e + 2) ~/ 153;

    int day = e - (153 * m + 2) ~/ 5 + 1;
    int month = m + 3 - 12 * (m ~/ 10);
    int year = 100 * b + d - 4800 + m ~/ 10;

    return DateTime(year, month, day);
  }

  /// Converts Julian day number to Hijri date using more accurate algorithm
  static HijriGregDate _julianToHijri(int julianDay) {
    // Calculate days since Hijri epoch
    int daysSinceEpoch = julianDay - _hijriEpoch;

    // Estimate Hijri year using average year length
    int hijriYear = (daysSinceEpoch * 33 ~/ 10631) + 1;

    // Adjust year to be more accurate
    int yearStartJulian = _hijriYearStartJulian(hijriYear);
    while (yearStartJulian > julianDay) {
      hijriYear--;
      yearStartJulian = _hijriYearStartJulian(hijriYear);
    }
    while (yearStartJulian + _hijriYearLength(hijriYear) <= julianDay) {
      hijriYear++;
      yearStartJulian = _hijriYearStartJulian(hijriYear);
    }

    // Calculate day of year - corrected calculation
    int dayOfYear = julianDay - yearStartJulian + 1;

    // Find month and day
    int month = 1;
    int dayInMonth = dayOfYear;

    while (month <= 12) {
      int monthLength = _hijriMonthLength(hijriYear, month);
      if (dayInMonth <= monthLength) {
        break;
      }
      dayInMonth -= monthLength;
      month++;
    }

    // Ensure we have valid day value
    if (dayInMonth < 1) {
      dayInMonth = 1;
    }
    if (dayInMonth > 30) {
      dayInMonth = 30;
    }

    return HijriGregDate(day: dayInMonth, month: month, year: hijriYear);
  }

  /// Converts Hijri date to Julian day number
  static int _hijriToJulian(HijriGregDate hijriDate) {
    int yearStart = _hijriYearStartJulian(hijriDate.year);
    int dayOfYear = 0;

    // Add days for complete months
    for (int i = 1; i < hijriDate.month; i++) {
      dayOfYear += _hijriMonthLength(hijriDate.year, i);
    }

    // Add days in the current month
    dayOfYear += hijriDate.day - 1;

    return yearStart + dayOfYear;
  }

  /// Calculate Julian day for start of Hijri year using O(1) formula
  static int _hijriYearStartJulian(int hijriYear) {
    if (hijriYear <= 1) return _hijriEpoch;

    final int completedYears = hijriYear - 1;
    // Each 30-year cycle has exactly 10631 days (19 × 354 + 11 × 355)
    final int completeCycles = completedYears ~/ 30;
    final int remainingYears = completedYears % 30;

    int totalDays = completeCycles * 10631;

    // Add days for remaining years
    totalDays += remainingYears * 354;

    // Add leap days for remaining years
    const leapYears = [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29];
    for (int ly in leapYears) {
      if (remainingYears >= ly) {
        totalDays++;
      }
    }

    return _hijriEpoch + totalDays;
  }

  /// Get the length of a Hijri year
  static int _hijriYearLength(int year) {
    return _isHijriLeapYear(year) ? 355 : 354;
  }

  /// Returns the length of a Hijri month
  static int _hijriMonthLength(int year, int month) {
    if (month <= 0 || month > 12) return 30;

    // Standard Islamic calendar month lengths
    const List<int> monthLengths = [30, 29, 30, 29, 30, 29, 30, 29, 30, 29, 30, 29];

    int length = monthLengths[month - 1];

    // In leap years, the 12th month (Dhul-Hijjah) has 30 days instead of 29
    if (month == 12 && _isHijriLeapYear(year)) {
      length = 30;
    }

    return length;
  }

  /// Checks if a Hijri year is a leap year using the 30-year cycle
  static bool _isHijriLeapYear(int year) {
    if (year <= 0) return false;

    // The 30-year cycle where leap years occur in years: 2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29
    const leapYears = [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29];
    int yearInCycle = ((year - 1) % 30) + 1;
    return leapYears.contains(yearInCycle);
  }

  /// Gets the number of days in a Hijri month
  static int getHijriMonthLength(int year, int month) {
    return _hijriMonthLength(year, month);
  }

  /// Checks if a Hijri year is a leap year (public method)
  static bool isHijriLeapYear(int year) {
    return _isHijriLeapYear(year);
  }
}
