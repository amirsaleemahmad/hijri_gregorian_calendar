import 'package:flutter/material.dart';
import 'hijri_greg_calendar_screen.dart';

/// Main application widget for the Hijri Gregorian Calendar.
class HijriGregCalendarApp extends StatelessWidget {
  final String language;
  final ThemeMode themeMode;

  const HijriGregCalendarApp({Key? key, this.language = 'en', this.themeMode = ThemeMode.system}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hijri Gregorian Calendar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: false,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        useMaterial3: false,
      ),
      themeMode: themeMode,
      home: HijriGregCalendarScreen(language: language),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Convenience function to run the app.
void runHijriGregCalendarApp({String language = 'en', ThemeMode themeMode = ThemeMode.system}) {
  runApp(HijriGregCalendarApp(language: language, themeMode: themeMode));
}
