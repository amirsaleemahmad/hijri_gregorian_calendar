import 'package:flutter/material.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

void main() {
  runHijriGregCalendarApp();
}

// Alternative usage example
class MyCustomApp extends StatelessWidget {
  const MyCustomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Hijri Gregorian Calendar',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HijriGregCalendarScreen(),
    );
  }
}
