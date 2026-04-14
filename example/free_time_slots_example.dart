import 'package:flutter/material.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

/// Example showing how to use the freeTimeSlots feature in V2 design
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Time Slots Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const FreeTimeSlotsExample(),
    );
  }
}

class FreeTimeSlotsExample extends StatefulWidget {
  const FreeTimeSlotsExample({super.key});

  @override
  State<FreeTimeSlotsExample> createState() => _FreeTimeSlotsExampleState();
}

class _FreeTimeSlotsExampleState extends State<FreeTimeSlotsExample> {
  DateTimeResult? selectedDateTime;
  
  // Example free time slots - these represent available appointment times
  // September 15, 2025 to October 1, 2025 with correct UTC timestamps for +0300 timezone
  final List<String> dateTimeSlots = [
    // September 15, 2025
    "/Date(1757921400000+0300)/", // Sep 15, 2025 10:30 AM local time
    "/Date(1757922300000+0300)/", // Sep 15, 2025 10:45 AM local time
    "/Date(1757923200000+0300)/", // Sep 15, 2025 11:00 AM local time
    "/Date(1757924100000+0300)/", // Sep 15, 2025 11:15 AM local time
    "/Date(1757925000000+0300)/", // Sep 15, 2025 11:30 AM local time
    "/Date(1757925900000+0300)/", // Sep 15, 2025 11:45 AM local time
    
    // September 16, 2025
    "/Date(1758002400000+0300)/", // Sep 16, 2025 09:00 AM local time
    "/Date(1758004200000+0300)/", // Sep 16, 2025 09:30 AM local time
    "/Date(1758006000000+0300)/", // Sep 16, 2025 10:00 AM local time
    
    // September 17, 2025
    "/Date(1758088800000+0300)/", // Sep 17, 2025 09:00 AM local time
    "/Date(1758090600000+0300)/", // Sep 17, 2025 09:30 AM local time
    
    // October 1, 2025
    "/Date(1759298400000+0300)/", // Oct 1, 2025 09:00 AM local time
    "/Date(1759300200000+0300)/", // Oct 1, 2025 09:30 AM local time
    "/Date(1759302000000+0300)/", // Oct 1, 2025 10:00 AM local time
  ];

  void _openFreeTimeSlotsCalendar() async {
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
      print('Selected DateTime: ${result.dateTime}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Time Slots Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This example demonstrates the freeTimeSlots feature in V2 design:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '• Shows only dates that have available time slots\n'
              '• Red dots indicate available dates\n'
              '• Time picker shows only available times for selected date\n'
              '• Includes language switcher functionality',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openFreeTimeSlotsCalendar,
              child: const Text('Open Calendar with Free Time Slots'),
            ),
            const SizedBox(height: 20),
            if (selectedDateTime != null) ...[
              const Text(
                'Selected Date & Time:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date & Time: ${selectedDateTime!.dateTime}'),
                    Text('Date: ${selectedDateTime!.date}'),
                    Text('Time: ${selectedDateTime!.time.format(context)}'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Available Time Slots:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: dateTimeSlots.length,
                itemBuilder: (context, index) {
                  final slot = dateTimeSlots[index];
                  // Parse the timestamp to show readable date/time
                  final match = RegExp(r'/Date\((\d+)([\+\-]\d{4})\)/').firstMatch(slot);
                  if (match != null) {
                    final timestamp = int.parse(match.group(1)!);
                    final timezone = match.group(2)!;
                    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
                    
                    return Card(
                      child: ListTile(
                        title: Text('${dateTime.day}/${dateTime.month}/${dateTime.year}'),
                        subtitle: Text('${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} (${timezone})'),
                        trailing: Text(slot, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    );
                  }
                  return ListTile(title: Text(slot));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}