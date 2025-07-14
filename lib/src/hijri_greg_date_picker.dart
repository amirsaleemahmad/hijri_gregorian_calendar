import 'package:flutter/material.dart';
import 'hijri_greg_date.dart';
import 'hijri_greg_converter.dart';

/// Custom date picker that supports both Hijri and Gregorian calendars
class HijriGregDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final bool isGregorian;
  final Function(DateTime) onDateSelected;

  HijriGregDatePicker({
    required this.initialDate,
    required this.isGregorian,
    required this.onDateSelected,
  });

  @override
  _HijriGregDatePickerState createState() => _HijriGregDatePickerState();
}

class _HijriGregDatePickerState extends State<HijriGregDatePicker> {
  late DateTime _selectedDate;
  late int _currentYear;
  late int _currentMonth;
  late List<List<int>> _calendarGrid;
  late bool _isGregorian;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _isGregorian = widget.isGregorian;

    if (_isGregorian) {
      _currentYear = _selectedDate.year;
      _currentMonth = _selectedDate.month;
    } else {
      final hijriDate = HijriGregConverter.gregorianToHijri(_selectedDate);
      _currentYear = hijriDate.year;
      _currentMonth = hijriDate.month;
    }

    _generateCalendar();
  }

  void _generateCalendar() {
    if (_isGregorian) {
      _generateGregorianCalendar();
    } else {
      _generateHijriCalendar();
    }
  }

  void _generateGregorianCalendar() {
    final firstDayOfMonth = DateTime(_currentYear, _currentMonth, 1);
    final lastDayOfMonth = DateTime(_currentYear, _currentMonth + 1, 0);

    // Find weekday of first day (1=Monday, 7=Sunday)
    int startingWeekday = firstDayOfMonth.weekday % 7;

    List<List<int>> grid = [];
    List<int> currentWeek = List.filled(7, 0);

    int day = 1;
    for (int i = 0; i < 6; i++) { // 6 weeks max
      for (int j = 0; j < 7; j++) {
        if (i == 0 && j < startingWeekday) {
          // Days from previous month
          currentWeek[j] = 0;
        } else if (day > lastDayOfMonth.day) {
          // Days from next month
          currentWeek[j] = 0;
        } else {
          currentWeek[j] = day;
          day++;
        }
      }
      grid.add(List.from(currentWeek));
      if (day > lastDayOfMonth.day) break;
    }

    setState(() {
      _calendarGrid = grid;
    });
  }

  void _generateHijriCalendar() {
    // Get the number of days in the current Hijri month
    int daysInMonth = HijriGregConverter.getHijriMonthLength(_currentYear, _currentMonth);

    // Calculate which day of the week the first day falls on
    final firstDayGregorian = HijriGregConverter.hijriToGregorian(
      HijriGregDate(day: 1, month: _currentMonth, year: _currentYear)
    );
    int startingWeekday = firstDayGregorian.weekday % 7;

    List<List<int>> grid = [];
    List<int> currentWeek = List.filled(7, 0);

    int day = 1;
    for (int i = 0; i < 6; i++) { // 6 weeks max
      for (int j = 0; j < 7; j++) {
        if (i == 0 && j < startingWeekday) {
          // Days from previous month
          currentWeek[j] = 0;
        } else if (day > daysInMonth) {
          // Days from next month
          currentWeek[j] = 0;
        } else {
          currentWeek[j] = day;
          day++;
        }
      }
      grid.add(List.from(currentWeek));
      if (day > daysInMonth) break;
    }

    setState(() {
      _calendarGrid = grid;
    });
  }

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
    if (day != 0) {
      DateTime newDate;
      if (_isGregorian) {
        newDate = DateTime(_currentYear, _currentMonth, day);
      } else {
        // Convert Hijri date to Gregorian
        final hijriDate = HijriGregDate(day: day, month: _currentMonth, year: _currentYear);
        newDate = HijriGregConverter.hijriToGregorian(hijriDate);
      }

      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  String _getCurrentMonthName() {
    if (_isGregorian) {
      const monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return monthNames[_currentMonth - 1];
    } else {
      return HijriGregDate.monthNamesEnglish[_currentMonth - 1];
    }
  }

  bool _isSelectedDate(int day) {
    if (day == 0) return false;

    if (_isGregorian) {
      return day == _selectedDate.day &&
          _currentMonth == _selectedDate.month &&
          _currentYear == _selectedDate.year;
    } else {
      final hijriDate = HijriGregConverter.gregorianToHijri(_selectedDate);
      return day == hijriDate.day &&
          _currentMonth == hijriDate.month &&
          _currentYear == hijriDate.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with calendar type
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${_isGregorian ? 'Gregorian' : 'Hijri'} Calendar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),

          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: _previousMonth,
                color: Colors.blue.shade700,
              ),
              Text(
                '${_getCurrentMonthName()} $_currentYear',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: _nextMonth,
                color: Colors.blue.shade700,
              ),
            ],
          ),

          SizedBox(height: 10),

          // Calendar grid
          Table(
            children: [
              // Day headers
              TableRow(
                children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                    .map((day) => Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              // Calendar days
              ..._calendarGrid.map((week) {
                return TableRow(
                  children: week.map((day) {
                    bool isSelected = _isSelectedDate(day);
                    bool isToday = false;

                    // Check if this day is today
                    if (day != 0) {
                      if (_isGregorian) {
                        final today = DateTime.now();
                        isToday = day == today.day &&
                            _currentMonth == today.month &&
                            _currentYear == today.year;
                      } else {
                        final todayHijri = HijriGregConverter.gregorianToHijri(DateTime.now());
                        isToday = day == todayHijri.day &&
                            _currentMonth == todayHijri.month &&
                            _currentYear == todayHijri.year;
                      }
                    }

                    return GestureDetector(
                      onTap: () => _selectDate(day),
                      child: Container(
                        margin: EdgeInsets.all(2),
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue
                              : isToday
                                  ? Colors.blue.shade100
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday && !isSelected
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            day == 0 ? '' : day.toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? Colors.blue.shade700
                                      : day == 0
                                          ? Colors.transparent
                                          : Colors.black,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ],
          ),

          SizedBox(height: 20),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onDateSelected(_selectedDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Select'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
