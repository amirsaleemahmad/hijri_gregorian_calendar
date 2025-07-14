import 'package:flutter/material.dart';
import 'hijri_greg_date.dart';
import 'hijri_greg_converter.dart';
import 'hijri_greg_date_picker.dart';

/// A compact bottom sheet widget for Hijri-Gregorian calendar functionality
/// that can be easily integrated into other apps.
class HijriGregBottomSheet extends StatefulWidget {
  /// Initial selected date
  final DateTime? initialDate;

  /// Whether to start with Gregorian calendar view
  final bool initialShowGregorian;

  /// Callback when date is selected
  final Function(DateTime)? onDateSelected;

  /// Callback when calendar type is changed
  final Function(bool isGregorian)? onCalendarTypeChanged;

  /// Custom background color for the bottom sheet
  final Color? backgroundColor;

  /// Custom height for the bottom sheet
  final double? height;

  /// Whether to show the calendar type toggle button
  final bool showCalendarToggle;

  /// Whether to show the date picker button
  final bool showDatePicker;

  const HijriGregBottomSheet({
    Key? key,
    this.initialDate,
    this.initialShowGregorian = true,
    this.onDateSelected,
    this.onCalendarTypeChanged,
    this.backgroundColor,
    this.height,
    this.showCalendarToggle = true,
    this.showDatePicker = true,
  }) : super(key: key);

  @override
  _HijriGregBottomSheetState createState() => _HijriGregBottomSheetState();
}

class _HijriGregBottomSheetState extends State<HijriGregBottomSheet> {
  late DateTime selectedDate;
  late bool showGregorian;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    showGregorian = widget.initialShowGregorian;
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: HijriGregDatePicker(
            initialDate: selectedDate,
            isGregorian: showGregorian,
            onDateSelected: (newDate) {
              setState(() {
                selectedDate = newDate;
              });
              widget.onDateSelected?.call(newDate);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _toggleCalendarType() {
    setState(() {
      showGregorian = !showGregorian;
    });
    widget.onCalendarTypeChanged?.call(showGregorian);
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriGregConverter.gregorianToHijri(selectedDate);

    return Container(
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                if (widget.showCalendarToggle)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      showGregorian ? 'Gregorian' : 'Hijri',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Date display
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                // mainAxisAlignment: MainAxisAlignment.center,
                shrinkWrap: true,
                children: [
                  // Primary date display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        showGregorian
                          ? selectedDate.day.toString()
                          : hijriDate.day.toString(),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            showGregorian
                              ? _getGregorianMonthName(selectedDate.month)
                              : hijriDate.monthNameEnglish,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Text(
                            showGregorian
                              ? selectedDate.year.toString()
                              : hijriDate.year.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Secondary date display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          showGregorian ? 'Hijri Equivalent' : 'Gregorian Equivalent',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          showGregorian
                            ? hijriDate.format()
                            : _formatGregorianDate(selectedDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.showCalendarToggle)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _toggleCalendarType,
                      icon: const Icon(Icons.swap_horiz),
                      label: Text('${showGregorian ? 'Hijri' : 'Gregorian'}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade700,
                        side: BorderSide(color: Colors.blue.shade300),
                      ),
                    ),
                  ),
                if (widget.showCalendarToggle && widget.showDatePicker)
                  const SizedBox(width: 12),
                if (widget.showDatePicker)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showDatePicker,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Select Date'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGregorianMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }

  String _formatGregorianDate(DateTime date) {
    return '${date.day} ${_getGregorianMonthName(date.month)} ${date.year}';
  }
}

/// Helper function to show the Hijri Gregorian calendar as a bottom sheet
Future<DateTime?> showHijriGregBottomSheet(
  BuildContext context, {
  DateTime? initialDate,
  bool initialShowGregorian = true,
  Color? backgroundColor,
  double? height,
  bool showCalendarToggle = true,
  bool showDatePicker = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (context) => HijriGregBottomSheet(
      initialDate: initialDate,
      initialShowGregorian: initialShowGregorian,
      backgroundColor: backgroundColor,
      height: height,
      showCalendarToggle: showCalendarToggle,
      showDatePicker: showDatePicker,
      onDateSelected: (date) {
        Navigator.of(context).pop(date);
      },
    ),
  );
}
