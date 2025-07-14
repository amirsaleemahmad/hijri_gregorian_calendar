import 'package:flutter/material.dart';
import 'hijri_greg_calendar_screen.dart';

/// Main application widget for the Hijri Gregorian Calendar
class HijriGregCalendarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hijri Gregorian Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HijriGregCalendarScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Convenience function to run the app
void runHijriGregCalendarApp() {
  runApp(HijriGregCalendarApp());
}
