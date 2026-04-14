import 'package:flutter/material.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

/// Test to verify single date selection behavior
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Single Selection Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SingleSelectionTest(),
    );
  }
}

class SingleSelectionTest extends StatefulWidget {
  const SingleSelectionTest({super.key});

  @override
  State<SingleSelectionTest> createState() => _SingleSelectionTestState();
}

class _SingleSelectionTestState extends State<SingleSelectionTest> {
  DateTimeResult? selectedDateTime;
  
  // Limited freeTimeSlots for focused testing
  final List<String> dateTimeSlots = [
    "/Date(1757921400000+0300)/", // Sep 15, 2025 10:30 AM local time
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
        title: const Text('Single Selection Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧪 Test Instructions:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '1. Click a date with a red dot (has time slots)\n'
                      '2. Click another date - border should move\n'
                      '3. Only ONE date should show selection border\n'
                      '4. Try both Gregorian and Hijri calendars\n'
                      '5. Navigate between months and select dates',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _openCalendar,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Open Calendar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (selectedDateTime != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ Last Selected Result:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text('📅 Date: ${selectedDateTime!.date}'),
                      Text('🕐 Time: ${selectedDateTime!.time.format(context)}'),
                      Text('📋 DateTime: ${selectedDateTime!.dateTime}'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                color: Colors.grey.shade100,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⏳ No date selected yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text('Select a date in the calendar to see the result here.'),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}