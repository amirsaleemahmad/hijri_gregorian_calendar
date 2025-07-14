import 'package:flutter/material.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

/// Example showing how to use the HijriGregBottomSheet in other apps
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hijri Calendar Bottom Sheet Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  @override
  _ExampleHomePageState createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  DateTime selectedDate = DateTime.now();
  bool currentCalendarType = true; // true = Gregorian, false = Hijri

  // Method 1: Using the helper function (Recommended)
  void _showCalendarBottomSheet() async {
    final result = await showHijriGregBottomSheet(
      context,
      initialDate: selectedDate,
      initialShowGregorian: currentCalendarType,
      height: 350,
      showCalendarToggle: true,
      showDatePicker: true,
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected date: ${result.toString().split(' ')[0]}'),
        ),
      );
    }
  }

  // Method 2: Using the widget directly in showModalBottomSheet
  void _showCustomBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HijriGregBottomSheet(
        initialDate: selectedDate,
        initialShowGregorian: currentCalendarType,
        backgroundColor: Colors.white,
        height: 400,
        showCalendarToggle: true,
        showDatePicker: true,
        onDateSelected: (date) {
          setState(() {
            selectedDate = date;
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Date selected: ${date.toString().split(' ')[0]}'),
            ),
          );
        },
        onCalendarTypeChanged: (isGregorian) {
          setState(() {
            currentCalendarType = isGregorian;
          });
        },
      ),
    );
  }

  // Method 3: Using the widget as a persistent bottom sheet
  void _showPersistentBottomSheet() {
    showBottomSheet(
      context: context,
      builder: (context) => HijriGregBottomSheet(
        initialDate: selectedDate,
        initialShowGregorian: currentCalendarType,
        height: 320,
        showCalendarToggle: true,
        showDatePicker: false, // Hide date picker in persistent sheet
        onDateSelected: (date) {
          setState(() {
            selectedDate = date;
          });
        },
        onCalendarTypeChanged: (isGregorian) {
          setState(() {
            currentCalendarType = isGregorian;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriGregConverter.gregorianToHijri(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hijri Calendar Bottom Sheet Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current selected date display
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Currently Selected Date',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Gregorian',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Hijri',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              hijriDate.format(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Different ways to use the bottom sheet
            Text(
              'Different Ways to Use the Calendar:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            // Method 1: Helper function
            ElevatedButton.icon(
              onPressed: _showCalendarBottomSheet,
              icon: Icon(Icons.calendar_today),
              label: Text('Show Calendar (Helper Function)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 12),

            // Method 2: Custom modal bottom sheet
            ElevatedButton.icon(
              onPressed: _showCustomBottomSheet,
              icon: Icon(Icons.calendar_month),
              label: Text('Show Custom Bottom Sheet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 12),

            // Method 3: Persistent bottom sheet
            ElevatedButton.icon(
              onPressed: _showPersistentBottomSheet,
              icon: Icon(Icons.calendar_view_month),
              label: Text('Show Persistent Bottom Sheet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 24),

            // Usage instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usage Instructions:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Helper Function: Quick and easy way to show the calendar\n'
                      '2. Custom Bottom Sheet: Full control over the modal presentation\n'
                      '3. Persistent Bottom Sheet: Shows calendar without modal overlay',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
