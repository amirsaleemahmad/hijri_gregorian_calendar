import 'package:flutter/material.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

/// Main calendar screen that displays both Hijri and Gregorian dates
/// with the ability to switch between them and select dates.
class HijriGregCalendarScreen extends StatefulWidget {
  final String language;
  final int startOfWeek;
  final int hijriAdjustment;
  final String? fontFamily;

  const HijriGregCalendarScreen({Key? key, this.language = 'en', this.startOfWeek = 0, this.hijriAdjustment = 0, this.fontFamily}) : super(key: key);

  @override
  State<HijriGregCalendarScreen> createState() => _HijriGregCalendarScreenState();
}

class _HijriGregCalendarScreenState extends State<HijriGregCalendarScreen> {
  DateTime selectedDate = DateTime.now();
  bool showGregorian = true;

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: HijriGregDatePicker(
            initialDate: selectedDate,
            isGregorian: showGregorian,
            language: widget.language,
            hijriAdjustment: widget.hijriAdjustment,
            startOfWeek: widget.startOfWeek,
            fontFamily: widget.fontFamily,
            onDateSelected: (newDate) {
              setState(() {
                selectedDate = newDate;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriGregConverter.gregorianToHijri(selectedDate, hijriAdjustment: widget.hijriAdjustment);
    final isAr = widget.language == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isAr ? 'التقويم الهجري والميلادي' : 'Hijri Gregorian Calendar'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Calendar type indicator
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(isAr ? 'نوع التقويم الحالي' : 'Current Calendar Type', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),
                    Text(
                      showGregorian ? (isAr ? 'ميلادي' : 'Gregorian') : (isAr ? 'هجري' : 'Hijri'),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Date display
              Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(
                  children: [
                    // Primary date (large display)
                    Column(
                      children: [
                        Text(
                          showGregorian ? selectedDate.day.toString() : hijriDate.day.toString(),
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(
                          showGregorian ? CalendarConstants.getGregorianMonthName(selectedDate.month, language: widget.language) : (isAr ? hijriDate.monthNameArabic : hijriDate.monthNameEnglish),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
                        ),
                        Text(
                          showGregorian ? selectedDate.year.toString() : hijriDate.year.toString(),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Divider(color: Theme.of(context).colorScheme.primary.withOpacity(0.25)),

                    const SizedBox(height: 20),

                    // Secondary date (smaller display)
                    Column(
                      children: [
                        Text(
                          showGregorian ? (isAr ? 'المعادل الهجري' : 'Hijri Equivalent') : (isAr ? 'المعادل الميلادي' : 'Gregorian Equivalent'),
                          style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          showGregorian ? hijriDate.format(useArabicNames: isAr) : CalendarConstants.formatGregorianDate(selectedDate, language: widget.language),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showGregorian = !showGregorian;
                      });
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(showGregorian ? (isAr ? 'التحويل إلى هجري' : 'Switch to Hijri') : (isAr ? 'التحويل إلى ميلادي' : 'Switch to Gregorian')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showDatePicker,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(isAr ? 'اختر التاريخ' : 'Select Date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              TextButton(
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime.now();
                  });
                },
                child: Text(isAr ? 'الذهاب إلى اليوم' : 'Go to Today', style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
