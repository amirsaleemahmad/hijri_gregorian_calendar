import 'dart:async';
import 'package:flutter/material.dart';
import 'hijri_greg_date.dart';
import 'hijri_greg_converter.dart';

enum Design { v1, v2 }

class DateTimeResult {
  final DateTime date;
  final TimeOfDay time;

  DateTimeResult({required this.date, required this.time});

  DateTime get dateTime {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}

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

class HijriGregBottomSheet extends StatefulWidget {
  final DateTime? initialDate;
  final bool initialShowGregorian;
  final Function(DateTime)? onDateSelected;
  final Function(bool isGregorian)? onCalendarTypeChanged;
  final Color? backgroundColor;
  final double? height;
  final bool showCalendarToggle;
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

  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

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
              SizedBox(
                width: 65,
                height: 200,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      _dayScrollTimer?.cancel();
                      _dayScrollTimer = Timer(Duration(milliseconds: 150), () {
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
                          } catch (e) {}
                        }
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        if (index < 0 || index >= 31) return null;

                        bool isValidDay = true;
                        if (!showGregorian) {
                          try {
                            HijriGregDate(year: currentHijriYear, month: currentHijriMonth, day: index + 1);
                          } catch (e) {
                            isValidDay = false;
                          }
                        }

                        if (!isValidDay) return Container();

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
              SizedBox(
                width: 120,
                height: 200,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      _monthScrollTimer?.cancel();
                      _monthScrollTimer = Timer(Duration(milliseconds: 150), () {
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
                          final currentHijriDate = HijriGregConverter.gregorianToHijri(selectedDate);
                          try {
                            final newHijriDate = HijriGregDate(year: currentHijriDate.year, month: index + 1, day: currentHijriDate.day);
                            selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                          } catch (e) {
                            try {
                              final newHijriDate = HijriGregDate(year: currentHijriDate.year, month: index + 1, day: 1);
                              selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                            } catch (e2) {}
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
              SizedBox(
                width: 80,
                height: 200,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollEndNotification) {
                      _yearScrollTimer?.cancel();
                      _yearScrollTimer = Timer(Duration(milliseconds: 150), () {
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
                          final currentHijriDate = HijriGregConverter.gregorianToHijri(selectedDate);
                          try {
                            final newHijriDate = HijriGregDate(year: minYear + index, month: currentHijriDate.month, day: currentHijriDate.day);
                            selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                          } catch (e) {
                            try {
                              final newHijriDate = HijriGregDate(year: minYear + index, month: currentHijriDate.month, day: 1);
                              selectedDate = HijriGregConverter.hijriToGregorian(newHijriDate);
                            } catch (e2) {}
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
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 4,
                width: 60,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
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
              Expanded(child: Center(child: _buildScrollablePicker())),
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
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Color(0xFF18C273)),
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
    _dayScrollTimer?.cancel();
    _monthScrollTimer?.cancel();
    _yearScrollTimer?.cancel();
    super.dispose();
  }
}

class HijriGregBottomSheetV2 extends StatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final bool initialShowGregorian;
  final Function(DateTimeResult)? onDateTimeSelected;
  final Function(bool isGregorian)? onCalendarTypeChanged;
  final Color? backgroundColor;
  final double? height;
  final bool showCalendarToggle;
  final bool isShowTimeSlots;
  final Widget switcherIcon;
  final String fontFamily;
  final String language;
  final Widget? okWidget;
  final Widget? cancelWidget;

  const HijriGregBottomSheetV2({
    Key? key,
    this.initialDate,
    this.initialTime,
    this.initialShowGregorian = true,
    this.onDateTimeSelected,
    this.onCalendarTypeChanged,
    this.backgroundColor,
    this.height,
    this.showCalendarToggle = true,
    this.isShowTimeSlots = false,
    this.switcherIcon = const SizedBox(),
    this.fontFamily = 'Poppins',
    this.language = 'en',
    this.okWidget,
    this.cancelWidget,
  }) : super(key: key);

  @override
  _HijriGregBottomSheetV2State createState() => _HijriGregBottomSheetV2State();
}

class _HijriGregBottomSheetV2State extends State<HijriGregBottomSheetV2> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late bool showGregorian;
  late DateTime currentMonth;

  late HijriGregDate _cachedCurrentMonthHijri;
  late HijriGregDate _cachedSelectedDateHijri;
  late HijriGregDate _cachedTodayHijri;

  final List<String> timeSlots = [
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
  ];

  int selectedTimeSlotIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    selectedTime = widget.initialTime ?? TimeOfDay.now();
    showGregorian = widget.initialShowGregorian;
    currentMonth = DateTime(selectedDate.year, selectedDate.month, 1);

    // Initialize cache
    _updateCachedValues();

    // Find closest time slot
    String currentTimeString = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
    selectedTimeSlotIndex = timeSlots.indexOf(currentTimeString);
    if (selectedTimeSlotIndex == -1) {
      selectedTimeSlotIndex = 0; // Default to first slot if not found
    }
  }

  void _updateCachedValues() {
    _cachedCurrentMonthHijri = HijriGregConverter.gregorianToHijri(currentMonth);
    _cachedSelectedDateHijri = HijriGregConverter.gregorianToHijri(selectedDate);
    _cachedTodayHijri = HijriGregConverter.gregorianToHijri(DateTime.now());
  }

  void _toggleCalendarType() {
    setState(() {
      showGregorian = !showGregorian;
      // No need to update cache here as currentMonth and selectedDate don't change
    });
    widget.onCalendarTypeChanged?.call(showGregorian);
  }

  void _onOkPressed() {
    final result = DateTimeResult(date: selectedDate, time: selectedTime);
    widget.onDateTimeSelected?.call(result);
  }

  String _getLocalizedText(String enText, String arText) {
    return widget.language == 'ar' ? arText : enText;
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    var first = DateTime(month.year, month.month, 1);

    // Find the first day of the grid (might be from previous month)
    var firstDayOfGrid = first.subtract(Duration(days: first.weekday % 7));

    var days = <DateTime>[];
    for (var i = 0; i < 42; i++) {
      days.add(firstDayOfGrid.add(Duration(days: i)));
    }

    return days;
  }

  Widget _buildCalendarGrid() {
    final dayNames = widget.language == 'ar' ? ['سبت', 'جمعة', 'خميس', 'أربعاء', 'ثلاثاء', 'اثنين', 'أحد'] : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    if (showGregorian) {
      // Gregorian calendar view
      final days = _getDaysInMonth(currentMonth);

      return Column(
        children: [
          // Day names header
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.5),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  dayNames[index],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600, fontFamily: widget.fontFamily),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          // Calendar days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.2),
            itemCount: 42,
            itemBuilder: (context, index) {
              final day = days[index];
              final isCurrentMonth = day.month == currentMonth.month;
              final isSelected = selectedDate.year == day.year && selectedDate.month == day.month && selectedDate.day == day.day;
              final isToday = day.year == DateTime.now().year && day.month == DateTime.now().month && day.day == DateTime.now().day;

              return GestureDetector(
                onTap: () {
                  if (isCurrentMonth) {
                    setState(() {
                      selectedDate = day;
                      _updateCachedValues(); // Update cache when date changes
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFDE5246) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected ? Border.all(color: const Color(0xFFDE5246), width: 1) : null,
                  ),
                  child: Center(
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : isCurrentMonth
                            ? Colors.black87
                            : Colors.grey.shade400,
                        fontFamily: widget.fontFamily,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else {
      // Hijri calendar view - optimized with cached values
      // Get the first day of the Hijri month in Gregorian
      final firstGregorian = HijriGregConverter.hijriToGregorian(HijriGregDate(day: 1, month: _cachedCurrentMonthHijri.month, year: _cachedCurrentMonthHijri.year));

      // Find the first day of the grid (start of the week containing the first day)
      var firstDayOfGrid = firstGregorian.subtract(Duration(days: firstGregorian.weekday % 7));

      // Create a list of 42 days for the grid
      var gridDays = <DateTime>[];
      for (var i = 0; i < 42; i++) {
        gridDays.add(firstDayOfGrid.add(Duration(days: i)));
      }

      return Column(
        children: [
          // Day names header
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.5),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  dayNames[index],
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600, fontFamily: widget.fontFamily),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          // Calendar days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.2),
            itemCount: 42,
            itemBuilder: (context, index) {
              final gregorianDay = gridDays[index];
              final hijriDay = HijriGregConverter.gregorianToHijri(gregorianDay);
              final isCurrentMonth = hijriDay.month == _cachedCurrentMonthHijri.month && hijriDay.year == _cachedCurrentMonthHijri.year;
              final isSelected = _cachedSelectedDateHijri.month == hijriDay.month && _cachedSelectedDateHijri.year == hijriDay.year && _cachedSelectedDateHijri.day == hijriDay.day;
              final isToday = _cachedTodayHijri.year == hijriDay.year && _cachedTodayHijri.month == hijriDay.month && _cachedTodayHijri.day == hijriDay.day;

              return GestureDetector(
                onTap: () {
                  if (isCurrentMonth) {
                    setState(() {
                      selectedDate = gregorianDay;
                      _cachedSelectedDateHijri = hijriDay; // Update cache
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFDE5246) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isToday && !isSelected ? Border.all(color: const Color(0xFFDE5246), width: 1) : null,
                  ),
                  child: Center(
                    child: Text(
                      hijriDay.day.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : isCurrentMonth
                            ? Colors.black87
                            : Colors.grey.shade400,
                        fontFamily: widget.fontFamily,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    }
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            showGregorian
                ? '${selectedDate.day.toString().padLeft(2, '0')} ${_getLocalizedMonthName(selectedDate.month, true)}, ${selectedDate.year}'
                : '${_cachedSelectedDateHijri.day.toString().padLeft(2, '0')} ${_getLocalizedMonthName(_cachedSelectedDateHijri.month - 1, false)}, ${_cachedSelectedDateHijri.year}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: widget.fontFamily),
          ),
        ),
        Container(
          height: 120,
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, childAspectRatio: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              bool isSelected = selectedTimeSlotIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTimeSlotIndex = index;
                    final timeParts = timeSlots[index].split(':');
                    selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFDE5246) : Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: Color(0xFFDE5246), width: 2) : null,
                  ),
                  child: Center(
                    child: Text(
                      timeSlots[index],
                      style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? Colors.white : Colors.black87, fontFamily: widget.fontFamily),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  void _navigateMonth(int direction) {
    setState(() {
      if (showGregorian) {
        currentMonth = DateTime(currentMonth.year, currentMonth.month + direction, 1);
      } else {
        int newMonth = _cachedCurrentMonthHijri.month + direction;
        int newYear = _cachedCurrentMonthHijri.year;

        if (newMonth > 12) {
          newMonth = 1;
          newYear++;
        } else if (newMonth < 1) {
          newMonth = 12;
          newYear--;
        }

        try {
          final newHijriDate = HijriGregDate(day: 1, month: newMonth, year: newYear);
          currentMonth = HijriGregConverter.hijriToGregorian(newHijriDate);
        } catch (e) {}
      }
      _updateCachedValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: widget.language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          height: widget.height ?? 810,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close, color: Colors.black87),
                        ),
                        SizedBox(width: 12),
                        Text(
                          _getLocalizedText('Pick a Date', 'اختر التاريخ'),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87, fontFamily: widget.fontFamily),
                        ),
                      ],
                    ),
                    if (widget.showCalendarToggle)
                      GestureDetector(
                        onTap: _toggleCalendarType,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.switcherIcon,
                              if (widget.switcherIcon != const SizedBox()) const SizedBox(width: 4),
                              Text(
                                showGregorian ? _getLocalizedText('Hijri', 'هجري') : _getLocalizedText('Gregorian', 'ميلادي'),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87, fontFamily: widget.fontFamily),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Text(
                _getLocalizedText('Please select the date you want to visit', 'يرجى اختيار التاريخ الذي تريد زيارته'),
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontFamily: widget.fontFamily),
              ),

              SizedBox(height: 20),

              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            showGregorian
                                ? '${_getLocalizedMonthName(currentMonth.month, true)} ${currentMonth.year}'
                                : '${_getLocalizedMonthName(_cachedCurrentMonthHijri.month - 1, false)} ${_cachedCurrentMonthHijri.year}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDE5246), fontFamily: widget.fontFamily),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => _navigateMonth(-1),
                                icon: Icon(Icons.chevron_left, color: Colors.black87),
                              ),
                              IconButton(
                                onPressed: () => _navigateMonth(1),
                                icon: Icon(Icons.chevron_right, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10),

                    Expanded(
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _buildCalendarGrid()),
                    ),

                    SizedBox(height: 20),

                    if (widget.isShowTimeSlots) _buildTimePicker(),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onOkPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFDE5246),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        widget.okWidget ??
                        Text(
                          _getLocalizedText('Select', 'اختار'),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: widget.fontFamily),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> showHijriGregBottomSheet(
  BuildContext context, {
  Design design = Design.v1,
  DateTime? initialDate,
  TimeOfDay? initialTime,
  bool initialShowGregorian = true,
  Color? backgroundColor,
  double? height,
  bool showCalendarToggle = true,
  bool showDatePicker = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isShowTimeSlots = false,
  Widget switcherIcon = const SizedBox(),
  String fontFamily = 'Poppins',
  String language = 'en',
  Function(bool isGregorian)? onCalendarTypeChanged,
  Widget? okWidget,
  Widget? cancelWidget,
}) {
  if (design == Design.v2) {
    return showModalBottomSheet<DateTimeResult>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => HijriGregBottomSheetV2(
        initialDate: initialDate,
        initialTime: initialTime,
        initialShowGregorian: initialShowGregorian,
        backgroundColor: backgroundColor,
        height: height,
        showCalendarToggle: showCalendarToggle,
        isShowTimeSlots: isShowTimeSlots,
        switcherIcon: switcherIcon,
        fontFamily: fontFamily,
        language: language,
        onCalendarTypeChanged: onCalendarTypeChanged,
        okWidget: okWidget,
        cancelWidget: cancelWidget,
        onDateTimeSelected: (result) {
          Navigator.of(context).pop(result);
        },
      ),
    );
  } else {
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
}
