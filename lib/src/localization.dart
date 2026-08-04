class LocalizationStrings {
  final String cancel;
  final String select;
  final String goToToday;

  LocalizationStrings({required this.cancel, required this.select, required this.goToToday});
}

class Localization {
  static final Map<String, LocalizationStrings> _map = {
    'en': LocalizationStrings(cancel: 'Cancel', select: 'Select', goToToday: 'Go to Today'),
    'ar': LocalizationStrings(cancel: 'إلغاء', select: 'اختر', goToToday: 'الذهاب إلى اليوم'),
  };

  static LocalizationStrings of(String language) => _map[language] ?? _map['en']!;
}
