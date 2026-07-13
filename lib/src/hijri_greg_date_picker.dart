import 'package:flutter/material.dart';
import 'hijri_greg_date.dart';
import 'hijri_greg_converter.dart';
import 'calendar_constants.dart';

/// Custom date picker that supports both Hijri and Gregorian calendars.
class HijriGregDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final bool isGregorian;
  final Function(DateTime) onDateSelected;
  final int hijriAdjustment;
  final bool highlightHolidays;
  final String language;

  const HijriGregDatePicker({
    super.key,
    required this.initialDate,
    required this.isGregorian,
    required this.onDateSelected,
    this.hijriAdjustment = 0,
    this.highlightHolidays = true,
    this.language = 'en',
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _isGregorian = widget.isGregorian;

    if (_isGregorian) {
      _currentYear = _selectedDate.year;
      _currentMonth = _selectedDate.month;
    } else {
      final hijriDate = HijriGregConverter.gregorianToHijri(_selectedDate, hijriAdjustment: widget.hijriAdjustment);
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
    _calendarGrid = _buildGrid(firstDay.weekday % 7, lastDay.day);
  }

  void _generateHijriCalendar() {
    final daysInMonth = HijriGregConverter.getHijriMonthLength(_currentYear, _currentMonth);
    final firstDayGreg = HijriGregConverter.hijriToGregorian(
      HijriGregDate(day: 1, month: _currentMonth, year: _currentYear),
      hijriAdjustment: widget.hijriAdjustment,
    );
    _calendarGrid = _buildGrid(firstDayGreg.weekday % 7, daysInMonth);
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
      newDate = HijriGregConverter.hijriToGregorian(hijriDate, hijriAdjustment: widget.hijriAdjustment);
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
    final hijriDate = HijriGregConverter.gregorianToHijri(_selectedDate, hijriAdjustment: widget.hijriAdjustment);
    return day == hijriDate.day && _currentMonth == hijriDate.month && _currentYear == hijriDate.year;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              widget.language == 'ar'
                  ? (_isGregorian ? 'التقويم الميلادي' : 'التقويم الهجري')
                  : '${_isGregorian ? 'Gregorian' : 'Hijri'} Calendar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
            ),
          ),

          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _previousMonth, color: Colors.blue.shade700),
              Text(
                '${_getCurrentMonthName()} $_currentYear',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth, color: Colors.blue.shade700),
            ],
          ),

          const SizedBox(height: 10),

          // Calendar grid
          Table(
            children: [
              // Day headers
              TableRow(
                children: (widget.language == 'ar' ? CalendarConstants.dayNamesArabic : CalendarConstants.dayNamesEnglish)
                    .map(
                      (day) => Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700),
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
                        final todayHijri = HijriGregConverter.gregorianToHijri(DateTime.now(), hijriAdjustment: widget.hijriAdjustment);
                        isToday = day == todayHijri.day && _currentMonth == todayHijri.month && _currentYear == todayHijri.year;
                      }
                    }

                    final isHoliday = day != 0 && widget.highlightHolidays && (() {
                      if (_isGregorian) {
                        final cellDate = DateTime(_currentYear, _currentMonth, day);
                        final cellHijri = HijriGregConverter.gregorianToHijri(cellDate, hijriAdjustment: widget.hijriAdjustment);
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
                              ? Colors.blue
                              : isToday
                              ? Colors.blue.shade100
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday && !isSelected ? Border.all(color: Colors.blue, width: 2) : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day == 0 ? '' : day.toString(),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                      ? Colors.blue.shade700
                                      : day == 0
                                      ? Colors.transparent
                                      : Colors.black,
                                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              if (isHoliday)
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
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
                child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                onPressed: () => widget.onDateSelected(_selectedDate),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: const Text('Select'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
