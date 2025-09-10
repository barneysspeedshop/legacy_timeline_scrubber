import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legacy_timeline_scrubber/legacy_timeline_scrubber.dart';

void main() {
  group('LegacyGanttTimelineScrubber Golden Tests', () {
    final totalStart = DateTime(2023, 1, 1);
    final totalEnd = DateTime(2023, 1, 31);
    final visibleStart = DateTime(2023, 1, 10);
    final visibleEnd = DateTime(2023, 1, 20);

    final tasks = [
      // Regular task with a specific color
      LegacyGanttTask(
        id: '1',
        rowId: 'r1',
        start: DateTime(2023, 1, 11),
        end: DateTime(2023, 1, 14),
        color: Colors.purple,
      ),
      // Task with no color, should use theme default
      LegacyGanttTask(
        id: '2',
        rowId: 'r1',
        start: DateTime(2023, 1, 16),
        end: DateTime(2023, 1, 18),
      ),
      // Overlap indicator task
      LegacyGanttTask(
        id: '3',
        rowId: 'r1',
        start: DateTime(2023, 1, 19),
        end: DateTime(2023, 1, 22), // Extends beyond visible area
        isOverlapIndicator: true,
      ),
      // Task that should be filtered out
      LegacyGanttTask(
        id: '4',
        rowId: 'r1',
        start: DateTime(2023, 1, 5),
        end: DateTime(2023, 1, 6),
        isTimeRangeHighlight: true,
      ),
    ];

    Widget buildScrubber() => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 50,
                child: LegacyGanttTimelineScrubber(
                  totalStartDate: totalStart,
                  totalEndDate: totalEnd,
                  visibleStartDate: visibleStart,
                  visibleEndDate: visibleEnd,
                  onWindowChanged: (start, end) {},
                  tasks: tasks,
                ),
              ),
            ),
          ),
        );

    testWidgets('renders correctly with tasks and window', (WidgetTester tester) async {
      await tester.pumpWidget(buildScrubber());

      await expectLater(
        find.byType(LegacyGanttTimelineScrubber),
        matchesGoldenFile('goldens/scrubber_with_tasks.png'),
      );
    });

    testWidgets('renders correctly when fully zoomed out', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 50,
              child: LegacyGanttTimelineScrubber(
                totalStartDate: totalStart,
                totalEndDate: totalEnd,
                visibleStartDate: totalStart, // Fully zoomed out
                visibleEndDate: totalEnd, // Fully zoomed out
                onWindowChanged: (start, end) {},
                tasks: tasks,
              ),
            ),
          ),
        ),
      ));

      await expectLater(find.byType(LegacyGanttTimelineScrubber), matchesGoldenFile('goldens/scrubber_zoomed_out.png'));
    });

    testWidgets('renders correctly with a custom theme', (WidgetTester tester) async {
      final customTheme = LegacyGanttTheme(
        // Provide required theme properties
        barColorPrimary: Colors.teal,
        barColorSecondary: Colors.lime,
        textColor: Colors.black,
        backgroundColor: Colors.white,
        // Override scrubber-specific colors
        scrubberWindowColor: Colors.orange.withValues(alpha:0.3),
        scrubberWindowBorderColor: Colors.deepOrange,
        conflictBarColor: Colors.black,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 50,
              child: LegacyGanttTimelineScrubber(
                totalStartDate: totalStart,
                totalEndDate: totalEnd,
                visibleStartDate: visibleStart,
                visibleEndDate: visibleEnd,
                onWindowChanged: (start, end) {},
                tasks: tasks,
                theme: customTheme,
              ),
            ),
          ),
        ),
      ));

      await expectLater(
          find.byType(LegacyGanttTimelineScrubber), matchesGoldenFile('goldens/scrubber_with_custom_theme.png'));
    });
  });
}
