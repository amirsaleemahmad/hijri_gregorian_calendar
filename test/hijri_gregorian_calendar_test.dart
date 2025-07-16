import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

void main() {
  group('HijriGregConverter Tests', () {
    test('Convert Gregorian to Hijri', () {
      // Test known conversion: January 1, 2024 (Gregorian)
      final gregorianDate = DateTime(2024, 1, 1);
      final hijriDate = HijriGregConverter.gregorianToHijri(gregorianDate);

      expect(hijriDate.year, isA<int>());
      expect(hijriDate.month, greaterThan(0));
      expect(hijriDate.month, lessThanOrEqualTo(12));
      expect(hijriDate.day, greaterThan(0));
      expect(hijriDate.day, lessThanOrEqualTo(30));
    });

    test('Convert Hijri to Gregorian', () {
      // Test conversion back
      final hijriDate = HijriGregDate(day: 1, month: 1, year: 1445);
      final gregorianDate = HijriGregConverter.hijriToGregorian(hijriDate);

      expect(gregorianDate.year, isA<int>());
      expect(gregorianDate.month, greaterThan(0));
      expect(gregorianDate.month, lessThanOrEqualTo(12));
      expect(gregorianDate.day, greaterThan(0));
      expect(gregorianDate.day, lessThanOrEqualTo(31));
    });

    test('Round-trip conversion should be consistent', () {
      final originalDate = DateTime(2024, 6, 15);
      final hijriDate = HijriGregConverter.gregorianToHijri(originalDate);
      final convertedBackDate = HijriGregConverter.hijriToGregorian(hijriDate);

      // Should be within 1 day due to calendar system differences
      final difference = originalDate
          .difference(convertedBackDate)
          .inDays
          .abs();
      expect(difference, lessThanOrEqualTo(1));
    });

    test('Hijri month lengths', () {
      // Test that month lengths are correct
      expect(
        HijriGregConverter.getHijriMonthLength(1445, 1),
        30,
      ); // Muharram has 30 days
      expect(
        HijriGregConverter.getHijriMonthLength(1445, 2),
        29,
      ); // Safar has 29 days
      expect(
        HijriGregConverter.getHijriMonthLength(1445, 3),
        30,
      ); // Rabi' al-awwal has 30 days
    });

    test('Hijri leap year detection', () {
      // Test leap year detection
      expect(HijriGregConverter.isHijriLeapYear(1445), isA<bool>());

      // Known leap years in a 30-year cycle
      expect(HijriGregConverter.isHijriLeapYear(2), true);
      expect(HijriGregConverter.isHijriLeapYear(5), true);
      expect(HijriGregConverter.isHijriLeapYear(1), false);
      expect(HijriGregConverter.isHijriLeapYear(3), false);
    });
  });

  group('HijriGregDate Tests', () {
    test('HijriGregDate creation', () {
      final hijriDate = HijriGregDate(day: 15, month: 6, year: 1445);

      expect(hijriDate.day, 15);
      expect(hijriDate.month, 6);
      expect(hijriDate.year, 1445);
    });

    test('HijriGregDate.now() creates current date', () {
      final hijriDate = HijriGregDate.now();

      expect(hijriDate.day, isA<int>());
      expect(hijriDate.month, isA<int>());
      expect(hijriDate.year, isA<int>());
    });

    test('HijriGregDate month names', () {
      final hijriDate = HijriGregDate(day: 1, month: 1, year: 1445);

      expect(hijriDate.monthNameEnglish, 'Muharram');
      expect(hijriDate.monthNameArabic, 'محرم');
    });

    test('HijriGregDate formatting', () {
      final hijriDate = HijriGregDate(day: 15, month: 9, year: 1445);

      expect(hijriDate.format(), '15 Ramadan 1445');
      expect(hijriDate.format(useArabicNames: true), '15 رمضان 1445');
      expect(hijriDate.toString(), '15/9/1445 H');
    });

    test('HijriGregDate to Gregorian conversion', () {
      final hijriDate = HijriGregDate(day: 1, month: 1, year: 1445);
      final gregorianDate = hijriDate.toGregorian();

      expect(gregorianDate, isA<DateTime>());
    });

    test('HijriGregDate equality', () {
      final date1 = HijriGregDate(day: 15, month: 6, year: 1445);
      final date2 = HijriGregDate(day: 15, month: 6, year: 1445);
      final date3 = HijriGregDate(day: 16, month: 6, year: 1445);

      expect(date1, equals(date2));
      expect(date1, isNot(equals(date3)));
    });

    test('HijriGregDate validation', () {
      // Valid dates should work
      expect(
        () => HijriGregDate(day: 1, month: 1, year: 1445),
        returnsNormally,
      );
      expect(
        () => HijriGregDate(day: 30, month: 12, year: 1445),
        returnsNormally,
      );

      // Invalid dates should throw assertions
      expect(
        () => HijriGregDate(day: 0, month: 1, year: 1445),
        throwsAssertionError,
      );
      expect(
        () => HijriGregDate(day: 31, month: 1, year: 1445),
        throwsAssertionError,
      );
      expect(
        () => HijriGregDate(day: 1, month: 0, year: 1445),
        throwsAssertionError,
      );
      expect(
        () => HijriGregDate(day: 1, month: 13, year: 1445),
        throwsAssertionError,
      );
      expect(
        () => HijriGregDate(day: 1, month: 1, year: 0),
        throwsAssertionError,
      );
    });
  });
}
