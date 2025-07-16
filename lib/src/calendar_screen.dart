import 'package:flutter/material.dart';
import 'hijri_converter.dart';
import 'custom_date_picker.dart';

/// Main calendar screen that displays both Hijri and Gregorian dates
/// with the ability to switch between them and select dates.
class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  bool showGregorian = true;

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: CustomDatePicker(
            initialDate: selectedDate,
            isGregorian: showGregorian,
            onDateSelected: (newDate) {
              setState(() {
                selectedDate = newDate;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriConverter.gregorianToHijri(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hijri Gregorian Calendar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Calendar type indicator
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Current Calendar Type',
                    style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    showGregorian ? 'Gregorian' : 'Hijri',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Date display
            Container(
              padding: EdgeInsets.all(30),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Primary date (large display)
                  Column(
                    children: [
                      Text(
                        showGregorian
                            ? selectedDate.day.toString()
                            : hijriDate.day.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        showGregorian
                            ? _getGregorianMonthName(selectedDate.month)
                            : hijriDate.monthNameEnglish,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      Text(
                        showGregorian
                            ? selectedDate.year.toString()
                            : hijriDate.year.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Divider
                  Divider(color: Colors.blue.shade200),

                  SizedBox(height: 20),

                  // Secondary date (smaller display)
                  Column(
                    children: [
                      Text(
                        showGregorian
                            ? 'Hijri Equivalent'
                            : 'Gregorian Equivalent',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        showGregorian
                            ? hijriDate.format()
                            : _formatGregorianDate(selectedDate),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Toggle button
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showGregorian = !showGregorian;
                    });
                  },
                  icon: Icon(Icons.swap_horiz),
                  label: Text(
                    'Switch to ${showGregorian ? 'Hijri' : 'Gregorian'}',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                // Date picker button
                ElevatedButton.icon(
                  onPressed: _showDatePicker,
                  icon: Icon(Icons.calendar_today),
                  label: Text('Select Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Today button
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDate = DateTime.now();
                });
              },
              child: Text(
                'Go to Today',
                style: TextStyle(fontSize: 16, color: Colors.blue.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGregorianMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }

  String _formatGregorianDate(DateTime date) {
    return '${date.day} ${_getGregorianMonthName(date.month)} ${date.year}';
  }
}
