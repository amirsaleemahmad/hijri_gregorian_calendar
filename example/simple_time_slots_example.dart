import 'package:flutter/material.dart';
import '../lib/src/hijri_greg_bottom_sheet.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple TimeSlots Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTimeResult? selectedResult;

  // Example time slots data in simple format
  final Map<String, List<String>> timeSlots = {
    "15/09/2025": ["09:00", "10:00", "11:00", "14:00", "15:00"],
    "16/09/2025": ["10:00", "11:00", "12:00", "16:00", "17:00"],
    "17/09/2025": ["08:00", "09:00", "13:00", "14:00"],
    "18/09/2025": ["09:30", "10:30", "11:30", "15:30"],
    "20/09/2025": ["08:00", "09:00", "10:00", "11:00", "14:00", "15:00", "16:00"],
    "22/09/2025": ["10:00", "11:00", "14:00", "15:00"],
  };

  void _showBottomSheet() {
    showHijriGregBottomSheet(
      context,
      design: Design.v2,
      initialDate: DateTime.now(),
      initialShowGregorian: true,
      showCalendarToggle: true,
      isShowTimeSlots: true,
      timeSlots: timeSlots, // Using the new simple timeSlots parameter
      showLangSwitcher: true,
      fontFamily: 'Arial',
      language: 'en',
    ).then((result) {
      if (result != null && result is DateTimeResult) {
        setState(() {
          selectedResult = result;
        });
        print('Selected: ${result.date} at ${result.time}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple TimeSlots Example'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Simple TimeSlots Format Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (selectedResult != null) ...[
              Text(
                'Selected Date: ${selectedResult!.date.day}/${selectedResult!.date.month}/${selectedResult!.date.year}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Selected Time: ${selectedResult!.time.format(context)}',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Full DateTime: ${selectedResult!.dateTime}',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 20),
            ],
            Text(
              'Available dates with time slots:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            ...timeSlots.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${entry.key}: ${entry.value.join(", ")}',
                style: TextStyle(fontSize: 14),
              ),
            )).toList(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _showBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text(
                'Show Date Time Picker',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}