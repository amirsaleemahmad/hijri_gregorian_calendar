import 'package:flutter/material.dart';
import 'calendar_screen.dart';

/// Main application widget for the Hijri Gregorian Calendar
class DualCalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hijri Gregorian Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CalendarScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Convenience function to run the app
void runDualCalendarApp() {
  runApp(DualCalendarApp());
}
