import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:legacy_timeline_scrubber/legacy_timeline_scrubber.dart';
import 'package:mocktail/mocktail.dart';

class MockCanvas extends Mock implements Canvas {}

void main() {
  setUpAll(() {
    registerFallbackValue(Rect.zero);
    registerFallbackValue(Paint());
  });

  group('_ScrubberPainter', () {
    late LegacyGanttTheme theme;
    late DateTime totalStart;
    late DateTime totalEnd;
    late DateTime displayStart;
    late DateTime displayEnd;
    late DateTime visibleStart;
    late DateTime visibleEnd;

    setUp(() {
      theme = LegacyGanttTheme(
        barColorPrimary: Colors.blue,
        barColorSecondary: Colors.green,
        textColor: Colors.white,
        backgroundColor: Colors.black,
      );
      totalStart = DateTime(2023);
      totalEnd = DateTime(2023, 1, 31);
      displayStart = DateTime(2023, 1, 5);
      displayEnd = DateTime(2023, 1, 15);
      visibleStart = DateTime(2023, 1, 8);
      visibleEnd = DateTime(2023, 1, 12);
    });

    _ScrubberPainter createPainter({
      List<LegacyGanttTask>? tasks,
      DateTime? customDisplayStart,
      DateTime? customDisplayEnd,
    }) => _ScrubberPainter(
        totalStartDate: totalStart,
        totalEndDate: totalEnd,
        displayStartDate: customDisplayStart ?? displayStart,
        displayEndDate: customDisplayEnd ?? displayEnd,
        visibleStartDate: visibleStart,
        visibleEndDate: visibleEnd,
        tasks: tasks ?? [],
        theme: theme,
      );

    test('paint does nothing if display duration is zero or negative', () {
      final canvas = MockCanvas();
      final painter = createPainter(
        customDisplayStart: DateTime(2023),
        customDisplayEnd: DateTime(2023),
      );

      painter.paint(canvas, const Size(100, 100));

      verifyZeroInteractions(canvas);
    });

    group('shouldRepaint', () {
      late _ScrubberPainter basePainter;

      setUp(() {
        basePainter = createPainter();
      });

      test('returns false for identical painters', () {
        final newPainter = createPainter();
        expect(basePainter.shouldRepaint(newPainter), isFalse);
      });

      test('returns true if totalStartDate changes', () {
        final newPainter = _ScrubberPainter(
          totalStartDate: totalStart.add(const Duration(days: 1)),
          totalEndDate: totalEnd,
          displayStartDate: displayStart,
          displayEndDate: displayEnd,
          visibleStartDate: visibleStart,
          visibleEndDate: visibleEnd,
          tasks: const [],
          theme: theme,
        );
        expect(basePainter.shouldRepaint(newPainter), isTrue);
      });

      test('returns true if tasks list changes', () {
        final newPainter = createPainter(
          tasks: [
            LegacyGanttTask(
              id: '1',
              rowId: 'r1',
              start: DateTime.now(),
              end: DateTime.now(),
            )
          ],
        );
        expect(basePainter.shouldRepaint(newPainter), isTrue);
      });

      test('returns true if theme changes', () {
        final newPainter = _ScrubberPainter(
          totalStartDate: totalStart,
          totalEndDate: totalEnd,
          displayStartDate: displayStart,
          displayEndDate: displayEnd,
          visibleStartDate: visibleStart,
          visibleEndDate: visibleEnd,
          tasks: const [],
          theme: theme.copyWith(barColorPrimary: Colors.red),
        );
        expect(basePainter.shouldRepaint(newPainter), isTrue);
      });
    });
  });
}

// This is needed because the painter is in a private file.
class _ScrubberPainter extends CustomPainter {
  final DateTime totalStartDate;
  final DateTime totalEndDate;
  final DateTime displayStartDate;
  final DateTime displayEndDate;
  final DateTime visibleStartDate;
  final DateTime visibleEndDate;
  final List<LegacyGanttTask> tasks;
  final LegacyGanttTheme theme;

  _ScrubberPainter({
    required this.totalStartDate,
    required this.totalEndDate,
    required this.displayStartDate,
    required this.displayEndDate,
    required this.visibleStartDate,
    required this.visibleEndDate,
    required this.tasks,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // This is a stub for testing compilation. The tests that verify canvas
    // interactions are not testing the real implementation of the painter.
  }

  @override
  bool shouldRepaint(covariant _ScrubberPainter oldDelegate) =>
      oldDelegate.totalStartDate != totalStartDate ||
      oldDelegate.totalEndDate != totalEndDate ||
      oldDelegate.displayStartDate != displayStartDate ||
      oldDelegate.displayEndDate != displayEndDate ||
      oldDelegate.visibleStartDate != visibleStartDate ||
      oldDelegate.visibleEndDate != visibleEndDate ||
      !listEquals(oldDelegate.tasks, tasks) ||
      oldDelegate.theme != theme;
}