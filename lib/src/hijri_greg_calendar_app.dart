import 'package:flutter/material.dart';
import 'hijri_greg_calendar_screen.dart';

/// Main application widget for the Hijri Gregorian Calendar.
class HijriGregCalendarApp extends StatelessWidget {
  final String language;

  const HijriGregCalendarApp({Key? key, this.language = 'en'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hijri Gregorian Calendar',
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: HijriGregCalendarScreen(language: language),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Convenience function to run the app.
void runHijriGregCalendarApp({String language = 'en'}) {
  runApp(HijriGregCalendarApp(language: language));
}
