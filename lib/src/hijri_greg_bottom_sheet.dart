import 'dart:async';
import 'package:flutter/material.dart';
import 'hijri_greg_date.dart';
import 'hijri_greg_converter.dart';

// Custom scroll physics to remove overscroll glow
class NoOverscrollPhysics extends ScrollPhysics {
  const NoOverscrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  NoOverscrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoOverscrollPhysics(parent: buildParent(ancestor));
  }

  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.pixels && position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) {
      return value - position.pixels;
    }
    if (value < position.minScrollExtent && position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }
    if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }
}

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

  final Widget switcherIcon;

  final String fontFamily;

  final String language;

  final Widget? okWidget;

  final Widget? cancelWidget;

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
    this.switcherIcon = const SizedBox(),
    this.fontFamily = 'Poppins',
    this.language = 'en',
    this.okWidget,
    this.cancelWidget,
  }) : super(key: key);

  @override
  _HijriGregBottomSheetState createState() => _HijriGregBottomSheetState();
}

class _HijriGregBottomSheetState extends State<HijriGregBottomSheet> {
  late DateTime selectedDate;
  late bool showGregorian;

  // Add controllers to manage scroll positions
  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  // Add timers for auto-centering
  Timer? _dayScrollTimer;
  Timer? _monthScrollTimer;
  Timer? _yearScrollTimer;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    showGregorian = widget.initialShowGregorian;
    _initializeControllers();
  }

  void _initializeControllers() {
    final int minYear = showGregorian ? 1900 : 1300;

    dayController = FixedExtentScrollController(initialItem: showGregorian ? selectedDate.day - 1 : selectedDate.day - 1);
    monthController = FixedExtentScrollController(initialItem: showGregorian ? selectedDate.month - 1 : selectedDate.month - 1);
    yearController = FixedExtentScrollController(initialItem: showGregorian ? selectedDate.year - minYear : selectedDate.year - minYear);
  }

  void _updateControllers() {
    DateTime tempSelectedDate = selectedDate;
    print('Updating controllers for selected date: $selectedDate, showGregorian: $showGregorian');
    print('Updating controllers for temp selected date: $tempSelectedDate, showGregorian: $showGregorian');

    final hijriDate = HijriGregConverter.gregorianToHijri(selectedDate);
    final int minYear = showGregorian ? 1900 : 1300;
    dayController.animateToItem(showGregorian ? selectedDate.day - 1 : hijriDate.day - 1, duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    monthController.animateToItem(showGregorian ? selectedDate.month - 1 : hijriDate.month - 1, duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    yearController.animateToItem(showGregorian ? selectedDate.year - minYear : hijriDate.year - minYear, duration: Duration(milliseconds: 100), curve: Curves.easeInOut);
    selectedDate = tempSelectedDate;
  }

  void _toggleCalendarType() {
    setState(() {
      showGregorian = !showGregorian;
    });
    // Update controllers to show the correct positions in the new calendar type
    _updateControllers();

    widget.onCalendarTypeChanged?.call(showGregorian);
  }

  void _onOkPressed() {
    widget.onDateSelected?.call(selectedDate);
  }

  void _onCancelPress() {
    Navigator.of(context).pop();
  }

  String _getLocalizedText(String enText, String arText) {
    return widget.language == 'ar' ? arText : enText;
  }

  Widget _buildScrollablePicker() {
    final hijriDate = HijriGregConverter.gregorianToHijri(selectedDate);
    final int minYear = showGregorian ? 1900 : 1300;
    final int maxYear = showGregorian ? 2100 : 1500;
    final int monthCount = 12;

    // Create current selections for Hijri mode
    int currentHijriDay = hijriDate.day;
    int currentHijriMonth = hijriDate.month;
    int currentHijriYear = hijriDate.year;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(overscroll: false, physics: const ClampingScrollPhysics()),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (notification) {
          notification.disallowIndicator();
          return true;
        },
        child: Directionality(
          textDirection: widget.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Day picker
              SizedBox(
                width: 65,
                height: 200,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      // Reset timer when scroll ends
                      _dayScrollTimer?.cancel();
                      _dayScrollTimer = Timer(Duration(milliseconds: 150), () {
                        // Auto-snap to center after scroll stops
                        final currentIndex = dayController.selectedItem;
                        if (currentIndex >= 0 && currentIndex < 31) {
                          dayController.animateToItem(currentIndex, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                        }
                      });
                    }
                    return false;
                  },
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 40,
                    physics: const ClampingScrollPhysics(),
                    diameterRatio: 2.0,
                    perspective: 0.002,
                    squeeze: 1.1,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        if (showGregorian) {
                          selectedDate = DateTime(selectedDate.year, selectedDate.month, index + 1);
                        } else {
                          // Get fresh Hijri date values for current selectedDate
                          final currentHijriDate = HijriGregConverter.gregorianToHijri(selectedDate);
                          try {
                            final newHijriDate = HijriGregDate(year: currentHijriDate.year, month: currentHijriDate.month, day: index + 1);
                            selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                          } catch (e) {
                            // If invalid date, keep current selection
                            print('Invalid Hijri date: ${currentHijriDate.year}-${currentHijriDate.month}-${index + 1}');
                          }
                        }
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index >= 31) return null;

                        // Check if this day is valid for current Hijri month/year
                        bool isValidDay = true;
                        if (!showGregorian) {
                          try {
                            HijriGregDate(year: currentHijriYear, month: currentHijriMonth, day: index + 1);
                          } catch (e) {
                            isValidDay = false;
                          }
                        }

                        if (!isValidDay) return Container(); // Hide invalid days

                        bool isSelected = (showGregorian ? selectedDate.day - 1 : currentHijriDay - 1) == index;
                        return Container(
                          width: 65,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: isSelected ? Color(0xFF2E3039) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 17 : 15,
                              color: isSelected ? Colors.white : Color(0xFF2E3039).withOpacity(0.6),
                              fontFamily: widget.fontFamily,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                      childCount: 31,
                    ),
                    controller: dayController,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Month picker
              SizedBox(
                width: 120,
                height: 200,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      // Reset timer when scroll ends
                      _monthScrollTimer?.cancel();
                      _monthScrollTimer = Timer(Duration(milliseconds: 150), () {
                        // Auto-snap to center after scroll stops
                        final currentIndex = monthController.selectedItem;
                        if (currentIndex >= 0 && currentIndex < monthCount) {
                          monthController.animateToItem(currentIndex, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                        }
                      });
                    }
                    return false;
                  },
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 45,
                    physics: const ClampingScrollPhysics(),
                    diameterRatio: 2.0,
                    perspective: 0.002,
                    squeeze: 1.1,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        if (showGregorian) {
                          selectedDate = DateTime(selectedDate.year, index + 1, selectedDate.day);
                        } else {
                          // Get fresh Hijri date values for current selectedDate
                          final currentHijriDate = HijriGregConverter.gregorianToHijri(selectedDate);
                          try {
                            final newHijriDate = HijriGregDate(year: currentHijriDate.year, month: index + 1, day: currentHijriDate.day);
                            selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                          } catch (e) {
                            // If invalid date, try with day 1
                            try {
                              final newHijriDate = HijriGregDate(year: currentHijriDate.year, month: index + 1, day: 1);
                              selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                            } catch (e2) {
                              print('Invalid Hijri date: ${currentHijriDate.year}-${index + 1}-${currentHijriDate.day}');
                            }
                          }
                        }
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index >= monthCount) return null;
                        bool isSelected = (showGregorian ? selectedDate.month - 1 : currentHijriMonth - 1) == index;
                        return Container(
                          width: 120,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: isSelected ? Color(0xFF2E3039) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            showGregorian ? _getLocalizedMonthName(index + 1, true) : _getLocalizedMonthName(index, false),
                            style: TextStyle(
                              fontSize: isSelected ? 15 : 13,
                              color: isSelected ? Colors.white : Color(0xFF2E3039).withOpacity(0.6),
                              fontFamily: widget.fontFamily,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                      childCount: monthCount,
                    ),
                    controller: monthController,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Year picker
              SizedBox(
                width: 80,
                height: 200,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      // Reset timer when scroll ends
                      _yearScrollTimer?.cancel();
                      _yearScrollTimer = Timer(Duration(milliseconds: 150), () {
                        // Auto-snap to center after scroll stops
                        final currentIndex = yearController.selectedItem;
                        if (currentIndex >= 0 && currentIndex <= (maxYear - minYear)) {
                          yearController.animateToItem(currentIndex, duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
                        }
                      });
                    }
                    return false;
                  },
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 40,
                    physics: const ClampingScrollPhysics(),
                    diameterRatio: 2.0,
                    perspective: 0.002,
                    squeeze: 1.1,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        if (showGregorian) {
                          selectedDate = DateTime(minYear + index, selectedDate.month, selectedDate.day);
                        } else {
                          // Get fresh Hijri date values for current selectedDate
                          final currentHijriDate = HijriGregConverter.gregorianToHijri(selectedDate);
                          try {
                            final newHijriDate = HijriGregDate(year: minYear + index, month: currentHijriDate.month, day: currentHijriDate.day);
                            selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                          } catch (e) {
                            // If invalid date, try with day 1
                            try {
                              final newHijriDate = HijriGregDate(year: minYear + index, month: currentHijriDate.month, day: 1);
                              selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                            } catch (e2) {
                              print('Invalid Hijri date: ${minYear + index}-${currentHijriDate.month}-${currentHijriDate.day}');
                            }
                          }
                        }
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index > (maxYear - minYear)) return null;
                        bool isSelected = (showGregorian ? selectedDate.year - minYear : currentHijriYear - minYear) == index;
                        return Container(
                          width: 80,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: isSelected ? Color(0xFF2E3039) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            (minYear + index).toString(),
                            style: TextStyle(
                              fontSize: isSelected ? 17 : 15,
                              color: isSelected ? Colors.white : Color(0xFF2E3039).withOpacity(0.6),
                              fontFamily: widget.fontFamily,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                      childCount: maxYear - minYear + 1,
                    ),
                    controller: yearController,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLocalizedMonthName(int index, bool isGregorian) {
    if (isGregorian) {
      // Gregorian month names
      if (widget.language == 'ar') {
        const gregorianMonthNamesAr = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
        return gregorianMonthNamesAr[index - 1];
      } else {
        const gregorianMonthNamesEn = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        return gregorianMonthNamesEn[index - 1];
      }
    } else {
      // Hijri month names from HijriGregDate class
      if (widget.language == 'ar') {
        return HijriGregDate.monthNamesArabic[index];
      } else {
        return HijriGregDate.monthNamesEnglish[index];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: widget.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          height: widget.height ?? 350,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(), blurRadius: 10, offset: const Offset(0, -2))],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 60,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              // Header row (no heading, calendar type toggle as button)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _getLocalizedText('Select Date', 'اختر التاريخ'),
                      style: TextStyle(fontWeight: FontWeight.w600, fontFamily: widget.fontFamily, fontSize: 18, color: const Color(0xFF2E3039), letterSpacing: 0.1),
                    ),
                    if (widget.showCalendarToggle)
                      GestureDetector(
                        onTap: _toggleCalendarType,
                        child: Container(
                          width: 120,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Color(0xFFFEE9EA)),
                          padding: EdgeInsets.all(8),
                          // decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.switcherIcon,
                              const SizedBox(width: 6),
                              Text(
                                showGregorian ? _getLocalizedText('Hijri', 'هجري') : _getLocalizedText('Gregorian', 'ميلادي'),
                                style: TextStyle(fontWeight: FontWeight.w500, fontFamily: widget.fontFamily, fontSize: 14, color: const Color(0xFFED1C2B), letterSpacing: 0.1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Date picker
              Expanded(child: Center(child: _buildScrollablePicker())),
              // OK button centered
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _onCancelPress,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Color(0xFFED1C2B)),
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.cancelWidget ??
                                    Text(
                                      _getLocalizedText('Cancel', 'إلغاء'),
                                      style: TextStyle(fontWeight: FontWeight.w500, fontFamily: widget.fontFamily, fontSize: 16, color: Colors.white, letterSpacing: 0.1),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 50),
                    Expanded(
                      child: GestureDetector(
                        onTap: _onOkPressed,
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Color(0xFFED1C2B)),
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                widget.okWidget ??
                                    Text(
                                      _getLocalizedText('Confirm', 'تأكيد'),
                                      style: TextStyle(fontWeight: FontWeight.w500, fontFamily: widget.fontFamily, fontSize: 16, color: Colors.white, letterSpacing: 0.1),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    // Cancel timers if they are active
    _dayScrollTimer?.cancel();
    _monthScrollTimer?.cancel();
    _yearScrollTimer?.cancel();
    super.dispose();
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
  Widget switcherIcon = const SizedBox(),
  String fontFamily = 'Poppins',
  String language = 'en',
  Function(bool isGregorian)? onCalendarTypeChanged,
  Widget? okWidget,
  Widget? cancelWidget,
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
      switcherIcon: switcherIcon,
      fontFamily: fontFamily,
      language: language,
      onCalendarTypeChanged: onCalendarTypeChanged,
      okWidget: okWidget,
      cancelWidget: cancelWidget,
      onDateSelected: (date) {
        Navigator.of(context).pop(date);
      },
    ),
  );
}
