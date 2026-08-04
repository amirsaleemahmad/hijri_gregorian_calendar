import 'package:flutter/material.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

/// Simple test to verify the new date selection behavior
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Selection Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DateSelectionTest(),
    );
  }
}

class DateSelectionTest extends StatefulWidget {
  const DateSelectionTest({super.key});

  @override
  State<DateSelectionTest> createState() => _DateSelectionTestState();
}

class _DateSelectionTestState extends State<DateSelectionTest> {
  DateTimeResult? selectedDateTime;
  
  // Limited freeTimeSlots for testing
  final List<String> dateTimeSlots = [
    "/Date(1757921400000+0300)/", // Sep 15, 2025 10:30 AM local time
    "/Date(1757922300000+0300)/", // Sep 15, 2025 10:45 AM local time
    "/Date(1758002400000+0300)/", // Sep 16, 2025 09:00 AM local time
  ];

  void _openCalendar() async {
    final result = await showHijriGregBottomSheet(
      context,
      design: Design.v2,
      dateTimeSlots: dateTimeSlots,
      showLangSwitcher: true,
    );
    
    if (result != null && result is DateTimeResult) {
      setState(() {
        selectedDateTime = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Selection Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Scenarios:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '1. Dates with red dots (Sep 15-16): Should have time slots available\n'
              '2. Future dates without dots: Should be selectable but no time slots\n'
              '3. Past dates: Should not be selectable (disabled)\n'
              '4. Date selection: Only one date selected at a time',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openCalendar,
              child: const Text('Open Calendar Test'),
            ),
            const SizedBox(height: 20),
            if (selectedDateTime != null) ...[
              const Text(
                'Last Selected:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${selectedDateTime!.date}'),
                    Text('Time: ${selectedDateTime!.time.format(context)}'),
                    Text('DateTime: ${selectedDateTime!.dateTime}'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}