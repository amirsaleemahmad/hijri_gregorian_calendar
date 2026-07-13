/// Shared constants for the Hijri-Gregorian calendar package.
class CalendarConstants {
  CalendarConstants._();

  /// Gregorian month names in English.
  static const List<String> gregorianMonthNamesEnglish = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  /// Gregorian month names in Arabic.
  static const List<String> gregorianMonthNamesArabic = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];

  /// Day-of-week headers in English.
  static const List<String> dayNamesEnglish = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  /// Day-of-week headers in Arabic.
  static const List<String> dayNamesArabic = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];

  /// Returns the Gregorian month name for the given 1-based [month] index.
  static String getGregorianMonthName(int month, {String language = 'en'}) {
    final names = language == 'ar' ? gregorianMonthNamesArabic : gregorianMonthNamesEnglish;
    return names[month - 1];
  }

  /// Returns the localized day-of-week names.
  static List<String> getDayNames({String language = 'en'}) {
    return language == 'ar' ? dayNamesArabic : dayNamesEnglish;
  }

  /// Formats a Gregorian [date] as "day MonthName year".
  static String formatGregorianDate(DateTime date, {String language = 'en'}) {
    return '${date.day} ${getGregorianMonthName(date.month, language: language)} ${date.year}';
  }
}
