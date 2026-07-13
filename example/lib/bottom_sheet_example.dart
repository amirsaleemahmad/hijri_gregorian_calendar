import 'package:flutter/material.dart';
import 'package:hijri_gregorian_calendar/hijri_gregorian_calendar.dart';

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  DateTime selectedDate = DateTime.now();
  bool isGregorian = true;
  String selectedLanguage = 'en';
  int hijriAdjustment = 0;
  bool highlightHolidays = true;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  // ── V1 Scroll Picker ──────────────────────────────────────────────────────
  void _showV1() async {
    final result = await showHijriGregBottomSheet(
      context,
      design: Design.v1,
      initialDate: selectedDate,
      initialShowGregorian: isGregorian,
      height: 350,
      language: selectedLanguage,
      hijriAdjustment: hijriAdjustment,
      highlightHolidays: highlightHolidays,
    );
    if (!mounted) return;
    if (result != null && result is DateTime) {
      setState(() => selectedDate = result);
      _showSnack('V1 → ${result.toString().split(' ')[0]}');
    }
  }

  // ── V2 Calendar Grid + Time Slots ─────────────────────────────────────────
  void _showV2() async {
    final result = await showHijriGregBottomSheet(
      context,
      design: Design.v2,
      initialDate: selectedDate,
      initialShowGregorian: isGregorian,
      height: 700,
      isShowTimeSlots: true,
      language: selectedLanguage,
      hijriAdjustment: hijriAdjustment,
      highlightHolidays: highlightHolidays,
      timeSlots: {
        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}': ['09:00', '10:00', '11:00', '14:00', '15:00'],
      },
    );
    if (!mounted) return;
    if (result != null && result is DateTimeResult) {
      setState(() => selectedDate = result.date);
      _showSnack('V2 → ${result.date.toString().split(' ')[0]} at ${result.time.format(context)}');
    }
  }

  // ── V3 Modern Card + Segmented Toggle ─────────────────────────────────────
  void _showV3() async {
    final result = await showHijriGregBottomSheet(
      context,
      design: Design.v3,
      initialDate: selectedDate,
      initialShowGregorian: isGregorian,
      showCalendarToggle: true,
      showLangSwitcher: true,
      language: selectedLanguage,
      hijriAdjustment: hijriAdjustment,
      highlightHolidays: highlightHolidays,
      title: 'Pick a Date',
      subtitle: 'Choose your preferred date',
    );
    if (!mounted) return;
    if (result != null && result is DateTime) {
      setState(() => selectedDate = result);
      _showSnack('V3 → ${result.toString().split(' ')[0]}');
    }
  }

  // ── V4 Dark Theme ─────────────────────────────────────────────────────────
  void _showV4() async {
    final result = await showHijriGregBottomSheet(
      context,
      design: Design.v4,
      initialDate: selectedDate,
      initialShowGregorian: isGregorian,
      language: selectedLanguage,
      hijriAdjustment: hijriAdjustment,
      highlightHolidays: highlightHolidays,
    );
    if (!mounted) return;
    if (result != null && result is DateTime) {
      setState(() => selectedDate = result);
      _showSnack('V4 → ${result.toString().split(' ')[0]}');
    }
  }

  // ── V5 Compact Dual Display ───────────────────────────────────────────────
  void _showV5() async {
    final result = await showHijriGregBottomSheet(
      context,
      design: Design.v5,
      initialDate: selectedDate,
      initialShowGregorian: isGregorian,
      language: selectedLanguage,
      hijriAdjustment: hijriAdjustment,
      highlightHolidays: highlightHolidays,
    );
    if (!mounted) return;
    if (result != null && result is DateTime) {
      setState(() => selectedDate = result);
      _showSnack('V5 → ${result.toString().split(' ')[0]}');
    }
  }

  // ── Dialog date picker ────────────────────────────────────────────────────
  void _showDialogPicker() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: HijriGregDatePicker(
          initialDate: selectedDate,
          isGregorian: isGregorian,
          hijriAdjustment: hijriAdjustment,
          highlightHolidays: highlightHolidays,
          onDateSelected: (date) {
            setState(() => selectedDate = date);
            Navigator.of(context).pop();
            _showSnack('Dialog → ${date.toString().split(' ')[0]}');
          },
        ),
      ),
    );
  }

  // ── V3 with time slots ───────────────────────────────────────────────────
  void _showV3WithTimeSlots() async {
    final result = await showHijriGregBottomSheet(
      context,
      design: Design.v3,
      initialDate: selectedDate,
      initialShowGregorian: isGregorian,
      isShowTimeSlots: true,
      height: 810,
      language: selectedLanguage,
      hijriAdjustment: hijriAdjustment,
      highlightHolidays: highlightHolidays,
      timeSlots: {
        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}': ['08:00', '09:30', '11:00', '13:00', '15:30', '17:00'],
      },
    );
    if (!mounted) return;
    if (result != null && result is DateTimeResult) {
      setState(() => selectedDate = result.date);
      _showSnack('V3+Time → ${result.date.toString().split(' ')[0]} at ${result.time.format(context)}');
    }
  }

  // ── Arabic mode ───────────────────────────────────────────────────────────
  void _showArabic() async {
    final result = await showHijriGregBottomSheet(
      context,
      design: Design.v4,
      initialDate: selectedDate,
      initialShowGregorian: false,
      language: 'ar',
      hijriAdjustment: hijriAdjustment,
      highlightHolidays: highlightHolidays,
    );
    if (!mounted) return;
    if (result != null && result is DateTime) {
      setState(() => selectedDate = result);
      _showSnack('Arabic → ${result.toString().split(' ')[0]}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hijriDate = HijriGregConverter.gregorianToHijri(selectedDate, hijriAdjustment: hijriAdjustment);
    final isAr = selectedLanguage == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'أمثلة التقويم الهجري والميلادي' : 'Hijri Calendar Examples'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Selected date card ──────────────────────────────────────────
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      isAr ? 'التاريخ المختار' : 'Selected Date',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoColumn(isAr ? 'ميلادي' : 'Gregorian', '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', Colors.blue),
                        Container(width: 1, height: 40, color: Colors.grey.shade200),
                        _infoColumn(isAr ? 'هجري' : 'Hijri', hijriDate.format(useArabicNames: isAr), Colors.teal),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'التقويم: ' : 'Calendar: ', style: const TextStyle(fontSize: 13)),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(value: true, label: Text(isAr ? 'ميلادي' : 'Gregorian')),
                            ButtonSegment(value: false, label: Text(isAr ? 'هجري' : 'Hijri')),
                          ],
                          selected: {isGregorian},
                          onSelectionChanged: (v) => setState(() => isGregorian = v.first),
                          style: SegmentedButton.styleFrom(selectedBackgroundColor: Colors.blue.withValues(alpha: 0.15)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'اللغة: ' : 'Language: ', style: const TextStyle(fontSize: 13)),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(value: 'en', label: Text(isAr ? 'الإنجليزية' : 'English')),
                            ButtonSegment(value: 'ar', label: Text(isAr ? 'العربية' : 'Arabic')),
                          ],
                          selected: {selectedLanguage},
                          onSelectionChanged: (v) => setState(() => selectedLanguage = v.first),
                          style: SegmentedButton.styleFrom(selectedBackgroundColor: Colors.teal.withValues(alpha: 0.15)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'تعديل اليوم: ' : 'Adjustment: ', style: const TextStyle(fontSize: 13)),
                        SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: -2, label: Text('-2')),
                            ButtonSegment(value: -1, label: Text('-1')),
                            ButtonSegment(value: 0, label: Text('0')),
                            ButtonSegment(value: 1, label: Text('+1')),
                            ButtonSegment(value: 2, label: Text('+2')),
                          ],
                          selected: {hijriAdjustment},
                          onSelectionChanged: (v) => setState(() => hijriAdjustment = v.first),
                          style: SegmentedButton.styleFrom(selectedBackgroundColor: Colors.orange.withValues(alpha: 0.15)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'تمييز الأعياد والمناسبات: ' : 'Highlight Holidays: ', style: const TextStyle(fontSize: 13)),
                        Switch(
                          value: highlightHolidays,
                          onChanged: (v) => setState(() => highlightHolidays = v),
                          activeColor: Colors.teal,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isAr ? 'تصاميم القائمة السفلية (Bottom Sheet)' : 'Bottom Sheet Designs',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _designButton(
              onPressed: _showV1,
              icon: Icons.view_stream,
              label: isAr ? 'منتقي V1 (التمرير)' : 'V1 — Scroll Picker',
              subtitle: isAr ? 'عجلة تمرير لليوم والشهر والسنة' : 'Day / Month / Year wheel scroll',
              color: Colors.blue,
            ),
            _designButton(
              onPressed: _showV2,
              icon: Icons.calendar_month,
              label: isAr ? 'منتقي V2 (الشبكة + الفترات)' : 'V2 — Calendar Grid + Time Slots',
              subtitle: isAr ? 'تقويم كامل مع تحديد الفترات الزمنية' : 'Full calendar with time selection',
              color: Colors.indigo,
            ),
            _designButton(
              onPressed: _showV3,
              icon: Icons.calendar_view_day,
              label: isAr ? 'منتقي V3 (الحديث)' : 'V3 — Modern Card Design',
              subtitle: isAr ? 'مفتاح تبديل مقسم، مبدل اللغة' : 'Segmented toggle, language switcher',
              color: const Color(0xFFDE5246),
            ),
            _designButton(
              onPressed: _showV4,
              icon: Icons.dark_mode,
              label: isAr ? 'منتقي V4 (المظهر الداكن)' : 'V4 — Dark Theme',
              subtitle: isAr ? 'تقويم داكن بسيط بلمسة بنفسجية' : 'Dark minimal calendar with purple accent',
              color: const Color(0xFF6C63FF),
            ),
            _designButton(
              onPressed: _showV5,
              icon: Icons.compare_arrows,
              label: isAr ? 'منتقي V5 (المزدوج المدمج)' : 'V5 — Compact Dual Display',
              subtitle: isAr ? 'عرض جانبي للتاريخ الهجري والميلادي' : 'Side-by-side Hijri + Gregorian dates',
              color: const Color(0xFF0D9373),
            ),

            const SizedBox(height: 20),

            Text(
              isAr ? 'متغيرات أخرى' : 'More Variants',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _designButton(
              onPressed: _showDialogPicker,
              icon: Icons.open_in_new,
              label: isAr ? 'منتقي نافذة الحوار' : 'Dialog Date Picker',
              subtitle: isAr ? 'يفتح في نافذة حوار مركزية بدلاً من القائمة السفلية' : 'Opens as a centered dialog instead of bottom sheet',
              color: Colors.orange,
            ),
            _designButton(
              onPressed: _showV3WithTimeSlots,
              icon: Icons.schedule,
              label: isAr ? 'منتقي V3 (شبكة + فترات)' : 'V3 + Time Slots',
              subtitle: isAr ? 'تصميم V3 مع تحديد فترات المواعيد' : 'V3 design with appointment time selection',
              color: Colors.deepOrange,
            ),
            _designButton(
              onPressed: _showArabic,
              icon: Icons.language,
              label: isAr ? 'المنتقي العربي الافتراضي' : 'Arabic / Hijri Mode',
              subtitle: isAr ? 'مظهر داكن يبدأ بالتاريخ الهجري واللغة العربية' : 'V4 dark theme starting in Hijri + Arabic',
              color: Colors.purple,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Widget _designButton({required VoidCallback onPressed, required IconData icon, required String label, required String subtitle, required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: color.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
