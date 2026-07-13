import 'package:flutter_test/flutter_test.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

void main() {
  group('HijriGregConverter Tests', () {
    test('Convert Gregorian to Hijri', () {
      final gregorianDate = DateTime(2024, 1, 1);
      final hijriDate = HijriGregConverter.gregorianToHijri(gregorianDate);

      expect(hijriDate.year, isA<int>());
      expect(hijriDate.month, greaterThan(0));
      expect(hijriDate.month, lessThanOrEqualTo(12));
      expect(hijriDate.day, greaterThan(0));
      expect(hijriDate.day, lessThanOrEqualTo(30));

      // Test a specific date: Dec 15, 2025 should be 24 Jumada al-Thani (month 6) 1447
      final specificGregDate = DateTime(2025, 12, 15);
      final specificHijriDate = HijriGregConverter.gregorianToHijri(specificGregDate);
      expect(specificHijriDate.day, 24);
      expect(specificHijriDate.month, 6);
      expect(specificHijriDate.year, 1447);
    });

    test('Convert Hijri to Gregorian', () {
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

      final difference = originalDate.difference(convertedBackDate).inDays.abs();
      expect(difference, lessThanOrEqualTo(1));
    });

    test('Hijri month lengths', () {
      expect(HijriGregConverter.getHijriMonthLength(1445, 1), 30);
      expect(HijriGregConverter.getHijriMonthLength(1445, 2), 29);
      expect(HijriGregConverter.getHijriMonthLength(1445, 3), 30);
    });

    test('Hijri leap year detection', () {
      expect(HijriGregConverter.isHijriLeapYear(1445), isA<bool>());
      expect(HijriGregConverter.isHijriLeapYear(2), true);
      expect(HijriGregConverter.isHijriLeapYear(5), true);
      expect(HijriGregConverter.isHijriLeapYear(1), false);
      expect(HijriGregConverter.isHijriLeapYear(3), false);
    });

    test('Performance: converting year 1445 should not be slow', () {
      final sw = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        HijriGregConverter.gregorianToHijri(DateTime(2024, 1, 1));
      }
      sw.stop();
      // 1000 conversions should take well under 1 second
      expect(sw.elapsedMilliseconds, lessThan(1000));
    });

    test('Multiple years round-trip consistency', () {
      for (int year = 2020; year <= 2030; year++) {
        for (int month = 1; month <= 12; month++) {
          final date = DateTime(year, month, 15);
          final hijri = HijriGregConverter.gregorianToHijri(date);
          final back = HijriGregConverter.hijriToGregorian(hijri);
          final diff = date.difference(back).inDays.abs();
          expect(diff, lessThanOrEqualTo(1), reason: 'Failed for $year-$month-15');
        }
      }
    });

    test('Conversion with hijriAdjustment parameter', () {
      final date = DateTime(2025, 12, 15);
      
      // Without adjustment -> Jumada II 24
      final h0 = HijriGregConverter.gregorianToHijri(date, hijriAdjustment: 0);
      expect(h0.day, 24);
      expect(h0.month, 6);
      
      // With adjustment +1 -> Jumada II 25
      final hPlus1 = HijriGregConverter.gregorianToHijri(date, hijriAdjustment: 1);
      expect(hPlus1.day, 25);
      expect(hPlus1.month, 6);

      // With adjustment -1 -> Jumada II 23
      final hMinus1 = HijriGregConverter.gregorianToHijri(date, hijriAdjustment: -1);
      expect(hMinus1.day, 23);
      expect(hMinus1.month, 6);

      // Round-trip consistency with adjustment
      final back = HijriGregConverter.hijriToGregorian(hPlus1, hijriAdjustment: 1);
      expect(back.year, date.year);
      expect(back.month, date.month);
      expect(back.day, date.day);
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

    test('HijriGregDate.fromGregorian() factory', () {
      final date = DateTime(2024, 1, 1);
      final hijri = HijriGregDate.fromGregorian(date);

      expect(hijri.day, greaterThan(0));
      expect(hijri.month, greaterThan(0));
      expect(hijri.year, greaterThan(0));
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

    test('HijriGregDate copyWith', () {
      final date = HijriGregDate(day: 15, month: 6, year: 1445);
      final copied = date.copyWith(day: 20);

      expect(copied.day, 20);
      expect(copied.month, 6);
      expect(copied.year, 1445);
    });

    test('HijriGregDate comparison', () {
      final earlier = HijriGregDate(day: 1, month: 1, year: 1445);
      final later = HijriGregDate(day: 1, month: 6, year: 1445);

      expect(earlier.isBefore(later), isTrue);
      expect(later.isAfter(earlier), isTrue);
      expect(earlier.compareTo(later), lessThan(0));
    });

    test('HijriGregDate daysInMonth and isLeapYear', () {
      final date = HijriGregDate(day: 1, month: 1, year: 1445);
      expect(date.daysInMonth, isA<int>());
      expect(date.isLeapYear, isA<bool>());
    });

    test('HijriGregDate validation', () {
      expect(() => HijriGregDate(day: 1, month: 1, year: 1445), returnsNormally);
      expect(() => HijriGregDate(day: 30, month: 12, year: 1445), returnsNormally);
      expect(() => HijriGregDate(day: 0, month: 1, year: 1445), throwsAssertionError);
      expect(() => HijriGregDate(day: 31, month: 1, year: 1445), throwsAssertionError);
      expect(() => HijriGregDate(day: 1, month: 0, year: 1445), throwsAssertionError);
      expect(() => HijriGregDate(day: 1, month: 13, year: 1445), throwsAssertionError);
      expect(() => HijriGregDate(day: 1, month: 1, year: 0), throwsAssertionError);
    });

    test('Islamic holidays detection', () {
      final ramadan = HijriGregDate(day: 1, month: 9, year: 1447);
      expect(ramadan.getIslamicHoliday(), 'Ramadan Start');

      final eidAlFitr = HijriGregDate(day: 1, month: 10, year: 1447);
      expect(eidAlFitr.getIslamicHoliday(), 'Eid al-Fitr');

      final nonHoliday = HijriGregDate(day: 15, month: 6, year: 1447);
      expect(nonHoliday.getIslamicHoliday(), isNull);
    });
  });

  group('CalendarConstants Tests', () {
    test('Gregorian month names', () {
      expect(CalendarConstants.getGregorianMonthName(1), 'January');
      expect(CalendarConstants.getGregorianMonthName(12), 'December');
      expect(CalendarConstants.getGregorianMonthName(1, language: 'ar'), 'يناير');
    });

    test('Format Gregorian date', () {
      final date = DateTime(2024, 6, 15);
      expect(CalendarConstants.formatGregorianDate(date), '15 June 2024');
    });

    test('Day names', () {
      expect(CalendarConstants.getDayNames().length, 7);
      expect(CalendarConstants.getDayNames(language: 'ar'), ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت']);
    });
  });
}
