# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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