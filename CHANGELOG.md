## 3.0.0

* **BREAKING**: Add line-count and vertical modes; date fields and date callbacks are nullable. Date consumers must handle null or select date-time mode. Require Dart 3.10 and Flutter 3.38 or newer.
* Fix drag initiation: use the original pointer-down position when selecting a handle or moving the visible window, including gestures that cross the touch-slop threshold.
* Preserve start/end padding when resetting zoom.

## 2.0.0

* **BREAKING FEATURE**: Added `ScrubberHandle` to allow anchored scaling for better precision.

## 1.0.2

* **FIX**: Optimize example gif size
* **PATCH**: Add test coverage badge to README.md

## 1.0.1

* **FIX**: Add dartdoc

## 1.0.0

* Initial release of the legacy_timeline_scrubber package.
* Added the `LegacyGanttTimelineScrubber` widget.
* Added a comprehensive example project.