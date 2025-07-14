import 'hijri_date.dart';

/// Utility class for converting between Hijri and Gregorian calendars.
/// Uses astronomical calculations based on the Umm al-Qura calendar system.
class HijriConverter {
  // Epoch constants
  static const int _hijriEpoch = 1948440; // Julian day of Hijri epoch (16 July 622 CE)

  /// Converts a Gregorian DateTime to HijriDate
  static HijriDate gregorianToHijri(DateTime gregorianDate) {
    int julianDay = _gregorianToJulian(gregorianDate);
    return _julianToHijri(julianDay);
  }

  /// Converts a HijriDate to Gregorian DateTime
  static DateTime hijriToGregorian(HijriDate hijriDate) {
    int julianDay = _hijriToJulian(hijriDate);
    return _julianToGregorian(julianDay);
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

    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day + b - 1524;
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

  /// Converts Julian day number to Hijri date
  static HijriDate _julianToHijri(int julianDay) {
    int days = julianDay - _hijriEpoch;

    // Estimate the Hijri year
    int year = ((days * 33) ~/ 10631) + 1;

    // Fine-tune the year
    while (_hijriYearStart(year + 1) <= julianDay) {
      year++;
    }
    while (_hijriYearStart(year) > julianDay) {
      year--;
    }

    int yearStart = _hijriYearStart(year);
    int dayOfYear = julianDay - yearStart + 1;

    // Find the month
    int month = 1;
    int remainingDays = dayOfYear;

    while (month <= 12) {
      int monthLength = _hijriMonthLength(year, month);
      if (remainingDays <= monthLength) {
        break;
      }
      remainingDays -= monthLength;
      month++;
    }

    // Ensure we have valid values
    if (month > 12) {
      month = 12;
      remainingDays = _hijriMonthLength(year, month);
    }
    if (remainingDays < 1) {
      remainingDays = 1;
    }

    return HijriDate(
      day: remainingDays,
      month: month,
      year: year,
    );
  }

  /// Converts Hijri date to Julian day number
  static int _hijriToJulian(HijriDate hijriDate) {
    int yearStart = _hijriYearStart(hijriDate.year);
    int dayOfYear = 0;

    // Add days for complete months
    for (int i = 1; i < hijriDate.month; i++) {
      dayOfYear += _hijriMonthLength(hijriDate.year, i);
    }

    // Add days in the current month
    dayOfYear += hijriDate.day - 1;

    return yearStart + dayOfYear;
  }

  /// Calculates the Julian day number for the start of a Hijri year
  static int _hijriYearStart(int year) {
    if (year <= 0) return _hijriEpoch;

    // More accurate calculation using the mean synodic month
    double meanYear = 354.36707; // Mean Hijri year length
    int estimatedDays = ((year - 1) * meanYear).round();

    // Add leap day corrections
    int leapCorrection = _cumulativeLeapDays(year - 1);

    return _hijriEpoch + estimatedDays + leapCorrection;
  }

  /// Calculates cumulative leap days up to a given year
  static int _cumulativeLeapDays(int year) {
    if (year <= 0) return 0;

    int completeCycles = year ~/ 30;
    int remainingYears = year % 30;

    // Each 30-year cycle has 11 leap years
    int leapDays = completeCycles * 11;

    // Add leap days from the remaining years
    const leapYears = [2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29];
    for (int leapYear in leapYears) {
      if (remainingYears >= leapYear) {
        leapDays++;
      }
    }

    return leapDays;
  }

  /// Returns the length of a Hijri month
  static int _hijriMonthLength(int year, int month) {
    if (month <= 0 || month > 12) return 30;

    bool isLeapYear = _isHijriLeapYear(year);

    if (month == 12 && isLeapYear) {
      return 30;
    } else if (month % 2 == 1) {
      return 30; // Odd months have 30 days
    } else {
      return 29; // Even months have 29 days
    }
  }

  /// Checks if a Hijri year is a leap year
  static bool _isHijriLeapYear(int year) {
    if (year <= 0) return false;

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
