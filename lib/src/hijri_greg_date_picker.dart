import 'package:flutter/material.dart';
import 'hijri_greg_date.dart';
import 'hijri_greg_converter.dart';
import 'calendar_constants.dart';
import 'localization.dart';

/// Custom date picker that supports both Hijri and Gregorian calendars.
class HijriGregDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final bool isGregorian;
  final Function(DateTime) onDateSelected;
  final int hijriAdjustment;
  final bool highlightHolidays;
  final String language;
  final int startOfWeek; // 0 = Sunday, 1 = Monday
  final String? fontFamily;

  const HijriGregDatePicker({
    super.key,
    required this.initialDate,
    required this.isGregorian,
    required this.onDateSelected,
    this.hijriAdjustment = 0,
    this.highlightHolidays = true,
    this.language = 'en',
    this.startOfWeek = 0,
    this.fontFamily,
  });

  @override
  HijriGregDatePickerState createState() => HijriGregDatePickerState();
}

class HijriGregDatePickerState extends State<HijriGregDatePicker> {
  late DateTime _selectedDate;
  late int _currentYear;
  late int _currentMonth;
  late bool _isGregorian;
  List<List<int>> _calendarGrid = [];
  late int _hijriAdjustment;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _isGregorian = widget.isGregorian;
    _hijriAdjustment = widget.hijriAdjustment;

    if (_isGregorian) {
      _currentYear = _selectedDate.year;
      _currentMonth = _selectedDate.month;
    } else {
      final hijriDate = HijriGregConverter.gregorianToHijri(_selectedDate, hijriAdjustment: _hijriAdjustment);
      _currentYear = hijriDate.year;
      _currentMonth = hijriDate.month;
    }

    _generateCalendar();
  }

  // ---------------------------------------------------------------------------
  // Calendar grid generation
  // ---------------------------------------------------------------------------

  void _generateCalendar() {
    _isGregorian ? _generateGregorianCalendar() : _generateHijriCalendar();
  }

  void _generateGregorianCalendar() {
    final firstDay = DateTime(_currentYear, _currentMonth, 1);
    final lastDay = DateTime(_currentYear, _currentMonth + 1, 0);
    int startWeekday = firstDay.weekday % 7; // Sunday=0
    startWeekday = (startWeekday - widget.startOfWeek + 7) % 7;
    _calendarGrid = _buildGrid(startWeekday, lastDay.day);
  }

  void _generateHijriCalendar() {
    final daysInMonth = HijriGregConverter.getHijriMonthLength(_currentYear, _currentMonth);
    final firstDayGreg = HijriGregConverter.hijriToGregorian(
      HijriGregDate(day: 1, month: _currentMonth, year: _currentYear),
      hijriAdjustment: _hijriAdjustment,
    );
    int startWeekday = firstDayGreg.weekday % 7;
    startWeekday = (startWeekday - widget.startOfWeek + 7) % 7;
    _calendarGrid = _buildGrid(startWeekday, daysInMonth);
  }

  List<List<int>> _buildGrid(int startWeekday, int totalDays) {
    final grid = <List<int>>[];
    var week = List<int>.filled(7, 0);
    int day = 1;

    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 7; j++) {
        if (i == 0 && j < startWeekday) {
          week[j] = 0;
        } else if (day > totalDays) {
          week[j] = 0;
        } else {
          week[j] = day++;
        }
      }
      grid.add(List.from(week));
      if (day > totalDays) break;
    }
    return grid;
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _previousMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
      _generateCalendar();
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
      _generateCalendar();
    });
  }

  void _selectDate(int day) {
    if (day == 0) return;

    DateTime newDate;
    if (_isGregorian) {
      newDate = DateTime(_currentYear, _currentMonth, day);
    } else {
      final hijriDate = HijriGregDate(day: day, month: _currentMonth, year: _currentYear);
      newDate = HijriGregConverter.hijriToGregorian(hijriDate, hijriAdjustment: _hijriAdjustment);
    }
    setState(() => _selectedDate = newDate);
  }

  String _getCurrentMonthName() {
    if (_isGregorian) {
      return CalendarConstants.getGregorianMonthName(_currentMonth, language: widget.language);
    }
    if (widget.language == 'ar') {
      return HijriGregDate.monthNamesArabic[_currentMonth - 1];
    }
    return HijriGregDate.monthNamesEnglish[_currentMonth - 1];
  }

  bool _isSelectedDate(int day) {
    if (day == 0) return false;
    if (_isGregorian) {
      return day == _selectedDate.day && _currentMonth == _selectedDate.month && _currentYear == _selectedDate.year;
    }
    final hijriDate = HijriGregConverter.gregorianToHijri(_selectedDate, hijriAdjustment: _hijriAdjustment);
    return day == hijriDate.day && _currentMonth == hijriDate.month && _currentYear == hijriDate.year;
  }

  List<String> _rotatedDayNames() {
    final names = CalendarConstants.getDayNames(language: widget.language);
    if (widget.startOfWeek == 0) return names;
    return List<String>.generate(7, (i) => names[(i + widget.startOfWeek) % 7]);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isAr = widget.language == 'ar';
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with hijri adjustment controls
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? (_isGregorian ? 'التقويم الميلادي' : 'التقويم الهجري') : '${_isGregorian ? 'Gregorian' : 'Hijri'} Calendar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary, fontFamily: widget.fontFamily),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(() {
                          _hijriAdjustment--;
                          _generateCalendar();
                        }),
                        color: primary,
                      ),
                      Text('$_hijriAdjustment', style: TextStyle(fontSize: 16, color: primary)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() {
                          _hijriAdjustment++;
                          _generateCalendar();
                        }),
                        color: primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Month navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousMonth, color: primary),
                Text(
                  '${_getCurrentMonthName()} $_currentYear',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primary, fontFamily: widget.fontFamily),
                ),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth, color: primary),
              ],
            ),

            const SizedBox(height: 10),

            // Calendar grid
            Table(
              children: [
                // Day headers
                TableRow(
                  children: _rotatedDayNames()
                      .map(
                        (day) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(fontWeight: FontWeight.bold, color: primary, fontFamily: widget.fontFamily),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                // Calendar days
                ..._calendarGrid.map((week) {
                  return TableRow(
                    children: week.map((day) {
                      final isSelected = _isSelectedDate(day);
                      bool isToday = false;

                      if (day != 0) {
                        if (_isGregorian) {
                          final today = DateTime.now();
                          isToday = day == today.day && _currentMonth == today.month && _currentYear == today.year;
                        } else {
                          final todayHijri = HijriGregConverter.gregorianToHijri(DateTime.now(), hijriAdjustment: _hijriAdjustment);
                          isToday = day == todayHijri.day && _currentMonth == todayHijri.month && _currentYear == todayHijri.year;
                        }
                      }

                      final isHoliday =
                          day != 0 &&
                          widget.highlightHolidays &&
                          (() {
                            if (_isGregorian) {
                              final cellDate = DateTime(_currentYear, _currentMonth, day);
                              final cellHijri = HijriGregConverter.gregorianToHijri(cellDate, hijriAdjustment: _hijriAdjustment);
                              return cellHijri.getIslamicHoliday() != null;
                            } else {
                              final cellHijri = HijriGregDate(day: day, month: _currentMonth, year: _currentYear);
                              return cellHijri.getIslamicHoliday() != null;
                            }
                          }());

                      return GestureDetector(
                        onTap: () => _selectDate(day),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary
                                : isToday
                                ? primary.withOpacity(0.15)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isToday && !isSelected ? Border.all(color: primary, width: 2) : null,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day == 0 ? '' : day.toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? onPrimary
                                        : isToday
                                        ? primary
                                        : day == 0
                                        ? Colors.transparent
                                        : Theme.of(context).textTheme.bodyLarge?.color,
                                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                    fontFamily: widget.fontFamily,
                                  ),
                                ),
                                if (isHoliday)
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(color: isSelected ? onPrimary : Colors.redAccent, shape: BoxShape.circle),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(Localization.of(widget.language).cancel, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                ),
                ElevatedButton(
                  onPressed: () => widget.onDateSelected(_selectedDate),
                  style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: onPrimary),
                  child: Text(Localization.of(widget.language).select),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
