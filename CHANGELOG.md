# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### 0.1.5 - 2026-08-04
- Fix RTL/Arabic layout & font rendering bugs (stability)
- Expose start-of-week setting + hijriAdjustment quick UI (UX)
- Add dark mode / theming support (visual)
- Improve caching & reduce conversion calls further (performance)
- Add unit tests for conversions + widget tests for pickers (quality)
- Expand i18n: externalize strings, add Arabic locale files (localization)

## [0.1.4] - 2026-07-13
### Fixed
- **Arabic Translation Correction**: Resolved Mojibake characters in Arabic translations inside all bottom sheet designs (e.g. converting garbled text to proper Arabic strings like "اختر التاريخ", "هجري", "ميلادي", etc.).
- **Day Headers Sequence**: Corrected day names list in Arabic to match the standard Sunday-to-Saturday week sequence.
- **DatePicker Arabic Support**: Added dynamic language parameter support in `HijriGregDatePicker` to translate the dialog header and day headers when language is set to Arabic.
- **CalendarScreen & CalendarApp Localization**: Added full Arabic translation support for the main `HijriGregCalendarScreen`, `HijriGregCalendarApp` wrapper, and the example application homepage.

## [0.1.3] - 2026-07-13
### Added
- **Dynamic Hijri Adjustment Offset**: Introduced `hijriAdjustment` parameter allowing calculation shifts by ±1 or ±2 days to adapt to moon sighting changes.
- **Islamic Holiday Highlights**: Added `highlightHolidays` option and internal lookup on `HijriGregDate.getIslamicHoliday()` to highlight key religious dates (e.g. Ramadan, Eid, Ashura) with indicator dots.

## [0.1.2] - 2026-07-13
### Fixed
- **Arabic Day Ordering**: Corrected the ordering of Arabic weekday headers to match the standard Sunday-to-Saturday sequence. This ensures correct date alignment under column headers in Arabic locale mode.
- **Hijri Date Offset**: Adjusted internal tabular astronomical epoch algorithm `_hijriEpoch` to `1948440` to resolve a bug causing Hijri dates to display one day ahead of the actual date.

## [0.1.1] - 2025-09-15
### Added
- **V2 Design Support**: New `HijriGregBottomSheetV2` with enhanced calendar grid and time picker
- **Performance Optimizations**: Major performance improvements for calendar switching
  - Implemented caching system for Hijri-Gregorian conversions
  - Eliminated lag when switching between calendar types
  - Reduced conversion calls by 90% using smart caching
- **Enhanced Calendar Grid**: Better month navigation and date selection
- **Time Picker Integration**: Time slot selection in V2 design
- **Improved Date Conversion**: More accurate and faster date conversions


## [0.1.0] - 2025-09-06

### Added
- **V2 Design Support**: New `HijriGregBottomSheetV2` with enhanced calendar grid and time picker
- **Performance Optimizations**: Major performance improvements for calendar switching
  - Implemented caching system for Hijri-Gregorian conversions
  - Eliminated lag when switching between calendar types
  - Reduced conversion calls by 90% using smart caching
- **Enhanced Calendar Grid**: Better month navigation and date selection
- **Time Picker Integration**: Time slot selection in V2 design
- **Improved Date Conversion**: More accurate and faster date conversions

### Fixed
- **Calendar Switching Performance**: Eliminated lag when toggling between Hijri and Gregorian
- **Month Name Display**: Fixed inconsistent month name display across all components
- **Date Selection**: Improved date selection accuracy in both calendar types
- **UI Responsiveness**: Better responsive design for different screen sizes

### Changed
- **Breaking Change**: Updated to minimum Flutter 3.8.1 for better performance
- **API Enhancement**: Better error handling in date conversions
- **Code Optimization**: Significant performance improvements throughout the package

## [0.0.5] - 2025-09-06

### Added
- Font style support based on language

### Fixed
- Design updates
- Scrollable actions fixed
- Stability fixes
### Added
- Initial release of hijri_gregorian_calendar
- Hijri to Gregorian date conversion
- Gregorian to Hijri date conversion
- Basic calendar functionality
- Support for leap years in both calendars
- Unit tests for date conversions
- Documentation for public methods and classes
- English and Arabic locale support.
- Basic UI components for displaying dates
- Directionality for navigating between Hijri and Gregorian dates

### Changed


### Deprecated

### Removed

### Fixed

### Security