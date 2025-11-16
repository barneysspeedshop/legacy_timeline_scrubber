import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legacy_timeline_scrubber/legacy_timeline_scrubber.dart';

void main() {
  // Helper to calculate the display range, mirroring the logic in the widget.
  (DateTime, DateTime) calculateDisplayRange(DateTime totalStart, DateTime totalEnd, DateTime visibleStart,
      DateTime visibleEnd, Duration startPadding, Duration endPadding) {
    final effectiveTotalStart = totalStart.subtract(startPadding);
    final effectiveTotalEnd = totalEnd.add(endPadding);
    final visibleDuration = visibleEnd.difference(visibleStart);
    final totalDuration = effectiveTotalEnd.difference(effectiveTotalStart);

    if (visibleDuration >= totalDuration) {
      return (effectiveTotalStart, effectiveTotalEnd);
    }

    final bufferDuration = Duration(milliseconds: (visibleDuration.inMilliseconds * 0.25).round());

    DateTime displayStart = visibleStart.subtract(bufferDuration);
    DateTime displayEnd = visibleEnd.add(bufferDuration);

    if (displayStart.isBefore(effectiveTotalStart)) {
      displayStart = effectiveTotalStart;
    }
    if (displayEnd.isAfter(effectiveTotalEnd)) {
      displayEnd = effectiveTotalEnd;
    }

    if (displayEnd.difference(displayStart) < visibleDuration) {
      // This logic must match the implementation in the widget state.
      if (displayStart == effectiveTotalStart) {
      } else if (displayEnd == effectiveTotalEnd) {
        displayEnd = displayStart.add(visibleDuration);
      } else if (displayEnd == effectiveTotalEnd) {
        displayStart = displayEnd.subtract(visibleDuration);
      }
    }

    // Final clamp to ensure we don't exceed total range after adjustments.
    // This is also present in the widget's implementation.
    if (displayEnd.isAfter(effectiveTotalEnd)) {
      displayEnd = effectiveTotalEnd;
    }
    if (displayStart.isBefore(effectiveTotalStart)) {
      displayStart = effectiveTotalStart;
    }

    return (displayStart, displayEnd);
  }

  testWidgets('LegacyGanttTimelineScrubber basic rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LegacyGanttTimelineScrubber(
            totalStartDate: DateTime(2023, 1, 1),
            totalEndDate: DateTime(2023, 1, 31),
            visibleStartDate: DateTime(2023, 1, 5),
            visibleEndDate: DateTime(2023, 1, 15),
            onWindowChanged: (start, end, handle) {},
          ),
        ),
      ),
    );

    expect(find.byType(LegacyGanttTimelineScrubber), findsOneWidget);
  });

  testWidgets('LegacyGanttTimelineScrubber drag left handle', (WidgetTester tester) async {
    DateTime newStart = DateTime(2023, 1, 5);
    DateTime newEnd = DateTime(2023, 1, 15);
    final initialStart = newStart;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: Scaffold(
            body: LegacyGanttTimelineScrubber(
              totalStartDate: DateTime(2023, 1, 1),
              totalEndDate: DateTime(2023, 1, 31),
              visibleStartDate: newStart,
              visibleEndDate: newEnd,
              onWindowChanged: (start, end, handle) {
                setState(() {
                  newStart = start;
                  newEnd = end;
                });
              },
            ),
          ),
        ),
      ),
    );

    final scrubber = find.byType(LegacyGanttTimelineScrubber);
    expect(scrubber, findsOneWidget);

    final scrubberWidget = tester.widget<LegacyGanttTimelineScrubber>(scrubber);
    final scrubberSize = tester.getSize(scrubber);
    final scrubberTopLeft = tester.getTopLeft(scrubber);

    final (displayStart, displayEnd) = calculateDisplayRange(scrubberWidget.totalStartDate, scrubberWidget.totalEndDate,
        newStart, newEnd, scrubberWidget.startPadding, scrubberWidget.endPadding);
    final displayDurationMs = displayEnd.difference(displayStart).inMilliseconds;
    final startX = (newStart.difference(displayStart).inMilliseconds / displayDurationMs) * scrubberSize.width;

    final Offset leftHandle = scrubberTopLeft + Offset(startX, scrubberSize.height / 2);
    final TestGesture gesture = await tester.startGesture(leftHandle);
    await gesture.moveBy(const Offset(-20, 0));
    await gesture.up();
    await tester.pump();

    expect(newStart.isBefore(initialStart), isTrue);
  });

  testWidgets('LegacyGanttTimelineScrubber drag right handle', (WidgetTester tester) async {
    DateTime newStart = DateTime(2023, 1, 5);
    DateTime newEnd = DateTime(2023, 1, 15);

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: Scaffold(
            body: LegacyGanttTimelineScrubber(
              totalStartDate: DateTime(2023, 1, 1),
              totalEndDate: DateTime(2023, 1, 31),
              visibleStartDate: newStart,
              visibleEndDate: newEnd,
              onWindowChanged: (start, end, handle) {
                setState(() {
                  newStart = start;
                  newEnd = end;
                });
              },
            ),
          ),
        ),
      ),
    );

    final scrubber = find.byType(LegacyGanttTimelineScrubber);
    expect(scrubber, findsOneWidget);

    final scrubberWidget = tester.widget<LegacyGanttTimelineScrubber>(scrubber);
    final scrubberSize = tester.getSize(scrubber);
    final scrubberTopLeft = tester.getTopLeft(scrubber);

    final (displayStart, displayEnd) = calculateDisplayRange(scrubberWidget.totalStartDate, scrubberWidget.totalEndDate,
        newStart, newEnd, scrubberWidget.startPadding, scrubberWidget.endPadding);
    final displayDurationMs = displayEnd.difference(displayStart).inMilliseconds;
    final endX = (newEnd.difference(displayStart).inMilliseconds / displayDurationMs) * scrubberSize.width;

    final Offset rightHandle = scrubberTopLeft + Offset(endX, scrubberSize.height / 2);
    final TestGesture gesture = await tester.startGesture(rightHandle);
    await gesture.moveBy(const Offset(20, 0));
    await gesture.up();
    await tester.pump();

    expect(newEnd.isAfter(DateTime(2023, 1, 15)), isTrue);
  });

  testWidgets('LegacyGanttTimelineScrubber drag window', (WidgetTester tester) async {
    DateTime newStart = DateTime(2023, 1, 5);
    DateTime newEnd = DateTime(2023, 1, 15);

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: Scaffold(
            body: LegacyGanttTimelineScrubber(
              totalStartDate: DateTime(2023, 1, 1),
              totalEndDate: DateTime(2023, 1, 31),
              visibleStartDate: newStart,
              visibleEndDate: newEnd,
              onWindowChanged: (start, end, handle) {
                setState(() {
                  newStart = start;
                  newEnd = end;
                });
              },
            ),
          ),
        ),
      ),
    );

    final scrubber = find.byType(LegacyGanttTimelineScrubber);
    expect(scrubber, findsOneWidget);

    final Offset window = tester.getCenter(scrubber);
    final TestGesture gesture = await tester.startGesture(window);
    await gesture.moveBy(const Offset(20, 0));
    await gesture.up();
    await tester.pump();

    expect(newStart.isAfter(DateTime(2023, 1, 5)), isTrue);
    expect(newEnd.isAfter(DateTime(2023, 1, 15)), isTrue);
  });

  testWidgets('LegacyGanttTimelineScrubber reset zoom button', (WidgetTester tester) async {
    DateTime newStart = DateTime(2023, 1, 5);
    DateTime newEnd = DateTime(2023, 1, 15);

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: Scaffold(
            body: LegacyGanttTimelineScrubber(
              totalStartDate: DateTime(2023, 1, 1),
              totalEndDate: DateTime(2023, 1, 31),
              visibleStartDate: newStart,
              visibleEndDate: newEnd,
              onWindowChanged: (start, end, handle) {
                setState(() {
                  newStart = start;
                  newEnd = end;
                });
              },
            ),
          ),
        ),
      ),
    );

    final resetButton = find.byIcon(Icons.zoom_out_map);
    expect(resetButton, findsOneWidget);

    await tester.tap(resetButton);
    await tester.pump();

    expect(newStart, DateTime(2023, 1, 1));
    expect(newEnd, DateTime(2023, 1, 31));
  });

  testWidgets('LegacyGanttTimelineScrubber reset zoom button is hidden when not zoomed', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LegacyGanttTimelineScrubber(
            totalStartDate: DateTime(2023, 1, 1),
            totalEndDate: DateTime(2023, 1, 31),
            // Visible window is same as total window
            visibleStartDate: DateTime(2023, 1, 1),
            visibleEndDate: DateTime(2023, 1, 31),
            onWindowChanged: (start, end, handle) {},
          ),
        ),
      ),
    );

    // When not zoomed in, the button should not be present.
    expect(find.byIcon(Icons.zoom_out_map), findsNothing);

    // Also test with a visible window larger than the total window
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: LegacyGanttTimelineScrubber(
                totalStartDate: DateTime(2023, 1, 1),
                totalEndDate: DateTime(2023, 1, 31),
                visibleStartDate: DateTime(2022, 12, 1),
                visibleEndDate: DateTime(2023, 2, 28),
                onWindowChanged: (start, end, handle) {}))));
    expect(find.byIcon(Icons.zoom_out_map), findsNothing);
  });

  testWidgets('LegacyGanttTimelineScrubber mouse cursor changes on hover', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 100,
              child: LegacyGanttTimelineScrubber(
                totalStartDate: DateTime(2023, 1, 1),
                totalEndDate: DateTime(2023, 1, 31),
                visibleStartDate: DateTime(2023, 1, 10),
                visibleEndDate: DateTime(2023, 1, 20),
                onWindowChanged: (start, end, handle) {},
              ),
            ),
          ),
        ),
      ),
    );

    final scrubber = find.byType(LegacyGanttTimelineScrubber);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Helper to get the current cursor
    MouseCursor cursor() => tester
        .widget<MouseRegion>(find.ancestor(of: find.byType(CustomPaint), matching: find.byType(MouseRegion)))
        .cursor;

    // Hover over the middle of the window
    await gesture.moveTo(tester.getCenter(scrubber));
    await tester.pumpAndSettle();
    expect(cursor(), SystemMouseCursors.move);

    // Hover over the left handle (approximate position)
    await gesture.moveTo(tester.getCenter(scrubber) - const Offset(130, 0));
    await tester.pumpAndSettle();
    expect(cursor(), SystemMouseCursors.resizeLeftRight);

    // Hover over the right handle (approximate position)
    await gesture.moveTo(tester.getCenter(scrubber) + const Offset(130, 0));
    await tester.pumpAndSettle();
    expect(cursor(), SystemMouseCursors.resizeLeftRight);

    // Move outside the scrubber
    await gesture.moveTo(const Offset(0, 0));
    await tester.pumpAndSettle();
    expect(cursor(), SystemMouseCursors.basic);
  });

  testWidgets('LegacyGanttTimelineScrubber respects start boundary on window drag', (WidgetTester tester) async {
    DateTime newStart = DateTime(2023, 1, 10);
    DateTime newEnd = DateTime(2023, 1, 12);
    final totalStart = DateTime(2023, 1, 1);
    final totalEnd = DateTime(2023, 1, 31);
    final originalDuration = newEnd.difference(newStart);

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: Scaffold(
            body: LegacyGanttTimelineScrubber(
              totalStartDate: totalStart,
              totalEndDate: totalEnd,
              visibleStartDate: newStart,
              visibleEndDate: newEnd,
              onWindowChanged: (start, end, handle) {
                setState(() {
                  newStart = start;
                  newEnd = end;
                });
              },
            ),
          ),
        ),
      ),
    );

    final scrubberCenter = tester.getCenter(find.byType(LegacyGanttTimelineScrubber));
    final TestGesture gesture = await tester.startGesture(scrubberCenter);
    await gesture.moveBy(const Offset(-5000, 0)); // Drag way past the start
    await gesture.up();
    await tester.pump();

    expect(newStart, totalStart);
    expect(newEnd.difference(newStart), originalDuration);
  });

  testWidgets('LegacyGanttTimelineScrubber respects end boundary on window drag', (WidgetTester tester) async {
    DateTime newStart = DateTime(2023, 1, 10);
    DateTime newEnd = DateTime(2023, 1, 12);
    final totalStart = DateTime(2023, 1, 1);
    final totalEnd = DateTime(2023, 1, 31);
    final originalDuration = newEnd.difference(newStart);

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: Scaffold(
            body: LegacyGanttTimelineScrubber(
              totalStartDate: totalStart,
              totalEndDate: totalEnd,
              visibleStartDate: newStart,
              visibleEndDate: newEnd,
              onWindowChanged: (start, end, handle) {
                setState(() {
                  newStart = start;
                  newEnd = end;
                });
              },
            ),
          ),
        ),
      ),
    );

    final scrubberCenter = tester.getCenter(find.byType(LegacyGanttTimelineScrubber));
    final TestGesture gesture = await tester.startGesture(scrubberCenter);
    await gesture.moveBy(const Offset(10000, 0)); // Drag way past the end
    await gesture.up();
    await tester.pump();
    expect(newEnd, totalEnd);
    expect(newEnd.difference(newStart), originalDuration);
  });

  group('LegacyGanttTimelineScrubber drag constraints', () {
    testWidgets('respects minimum window size when dragging left handle', (WidgetTester tester) async {
      DateTime newStart = DateTime(2023, 1, 10);
      DateTime newEnd = DateTime(2023, 1, 10, 2); // 2 hour window
      final initialEnd = newEnd;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => MaterialApp(
            home: Scaffold(
              body: LegacyGanttTimelineScrubber(
                totalStartDate: DateTime(2023, 1, 1),
                totalEndDate: DateTime(2023, 1, 31),
                visibleStartDate: newStart,
                visibleEndDate: newEnd,
                onWindowChanged: (start, end, handle) {
                  setState(() {
                    newStart = start;
                    newEnd = end;
                  });
                },
              ),
            ),
          ),
        ),
      );

      final scrubber = find.byType(LegacyGanttTimelineScrubber);
      final scrubberWidget = tester.widget<LegacyGanttTimelineScrubber>(scrubber);
      final scrubberSize = tester.getSize(scrubber);
      final scrubberTopLeft = tester.getTopLeft(scrubber);

      final (displayStart, displayEnd) = calculateDisplayRange(scrubberWidget.totalStartDate,
          scrubberWidget.totalEndDate, newStart, newEnd, scrubberWidget.startPadding, scrubberWidget.endPadding);
      final displayDurationMs = displayEnd.difference(displayStart).inMilliseconds;
      final startX = (newStart.difference(displayStart).inMilliseconds / displayDurationMs) * scrubberSize.width;

      final Offset leftHandle = scrubberTopLeft + Offset(startX, scrubberSize.height / 2);
      final TestGesture gesture = await tester.startGesture(leftHandle);
      await gesture.moveBy(const Offset(500, 0)); // Drag way past the right handle
      await gesture.up();
      await tester.pump();

      const minWindowDuration = Duration(hours: 1);
      expect(newEnd.difference(newStart), minWindowDuration);
      expect(newStart, initialEnd.subtract(minWindowDuration));
    });

    testWidgets('respects minimum window size when dragging right handle', (WidgetTester tester) async {
      DateTime newStart = DateTime(2023, 1, 10);
      DateTime newEnd = DateTime(2023, 1, 10, 2); // 2 hour window
      final initialStart = newStart;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => MaterialApp(
            home: Scaffold(
              body: LegacyGanttTimelineScrubber(
                totalStartDate: DateTime(2023, 1, 1),
                totalEndDate: DateTime(2023, 1, 31),
                visibleStartDate: newStart,
                visibleEndDate: newEnd,
                onWindowChanged: (start, end, handle) {
                  setState(() {
                    newStart = start;
                    newEnd = end;
                  });
                },
              ),
            ),
          ),
        ),
      );

      final scrubber = find.byType(LegacyGanttTimelineScrubber);
      final scrubberWidget = tester.widget<LegacyGanttTimelineScrubber>(scrubber);
      final scrubberSize = tester.getSize(scrubber);
      final scrubberTopLeft = tester.getTopLeft(scrubber);

      final (displayStart, displayEnd) = calculateDisplayRange(scrubberWidget.totalStartDate,
          scrubberWidget.totalEndDate, newStart, newEnd, scrubberWidget.startPadding, scrubberWidget.endPadding);
      final displayDurationMs = displayEnd.difference(displayStart).inMilliseconds;
      final endX = (newEnd.difference(displayStart).inMilliseconds / displayDurationMs) * scrubberSize.width;

      final Offset rightHandle = scrubberTopLeft + Offset(endX, scrubberSize.height / 2);
      final TestGesture gesture = await tester.startGesture(rightHandle);
      await gesture.moveBy(const Offset(-500, 0)); // Drag way past the left handle
      await gesture.up();
      await tester.pump();

      const minWindowDuration = Duration(hours: 1);
      expect(newEnd.difference(newStart), minWindowDuration);
      expect(newEnd, initialStart.add(minWindowDuration));
    });

    testWidgets('respects start boundary on left handle drag', (WidgetTester tester) async {
      DateTime newStart = DateTime(2023, 1, 10);
      DateTime newEnd = DateTime(2023, 1, 12);
      final totalStart = DateTime(2023, 1, 1);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => MaterialApp(
            home: Scaffold(
              body: LegacyGanttTimelineScrubber(
                totalStartDate: totalStart,
                totalEndDate: DateTime(2023, 1, 31),
                visibleStartDate: newStart,
                visibleEndDate: newEnd,
                onWindowChanged: (start, end, handle) {
                  setState(() {
                    newStart = start;
                    newEnd = end;
                  });
                },
              ),
            ),
          ),
        ),
      );

      final scrubber = find.byType(LegacyGanttTimelineScrubber);
      final scrubberWidget = tester.widget<LegacyGanttTimelineScrubber>(scrubber);
      final scrubberSize = tester.getSize(scrubber);
      final scrubberTopLeft = tester.getTopLeft(scrubber);

      final (displayStart, displayEnd) = calculateDisplayRange(
          scrubberWidget.totalStartDate, scrubberWidget.totalEndDate, newStart, newEnd, Duration.zero, Duration.zero);
      final displayDurationMs = displayEnd.difference(displayStart).inMilliseconds;
      final startX = (newStart.difference(displayStart).inMilliseconds / displayDurationMs) * scrubberSize.width;

      final Offset leftHandle = scrubberTopLeft + Offset(startX, scrubberSize.height / 2);
      final TestGesture gesture = await tester.startGesture(leftHandle);
      await gesture.moveBy(const Offset(-5000, 0)); // Drag way past the start
      await gesture.up();
      await tester.pump();

      expect(newStart, totalStart);
    });

    testWidgets('respects end boundary on right handle drag', (WidgetTester tester) async {
      DateTime newStart = DateTime(2023, 1, 10);
      DateTime newEnd = DateTime(2023, 1, 12);
      final totalEnd = DateTime(2023, 1, 31);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => MaterialApp(
            home: Scaffold(
              body: LegacyGanttTimelineScrubber(
                totalStartDate: DateTime(2023, 1, 1),
                totalEndDate: totalEnd,
                visibleStartDate: newStart,
                visibleEndDate: newEnd,
                onWindowChanged: (start, end, handle) {
                  setState(() {
                    newStart = start;
                    newEnd = end;
                  });
                },
              ),
            ),
          ),
        ),
      );

      final scrubber = find.byType(LegacyGanttTimelineScrubber);
      final scrubberWidget = tester.widget<LegacyGanttTimelineScrubber>(scrubber);
      final scrubberSize = tester.getSize(scrubber);
      final scrubberTopLeft = tester.getTopLeft(scrubber);

      final (displayStart, displayEnd) = calculateDisplayRange(
          scrubberWidget.totalStartDate, scrubberWidget.totalEndDate, newStart, newEnd, Duration.zero, Duration.zero);
      final displayDurationMs = displayEnd.difference(displayStart).inMilliseconds;
      final endX = (newEnd.difference(displayStart).inMilliseconds / displayDurationMs) * scrubberSize.width;

      final Offset rightHandle = scrubberTopLeft + Offset(endX, scrubberSize.height / 2);
      final TestGesture gesture = await tester.startGesture(rightHandle);
      await gesture.moveBy(const Offset(10000, 0)); // Drag way past the end
      await gesture.up();
      await tester.pump();

      expect(newEnd, totalEnd);
    });
  });

  testWidgets('LegacyGanttTimelineScrubber respects start and end padding', (WidgetTester tester) async {
    DateTime newStart = DateTime(2023, 1, 5);
    DateTime newEnd = DateTime(2023, 1, 15);
    final totalStart = DateTime(2023, 1, 1);
    final totalEnd = DateTime(2023, 1, 31);
    const startPadding = Duration(days: 2);
    const endPadding = Duration(days: 3);

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: Scaffold(
            body: LegacyGanttTimelineScrubber(
              totalStartDate: totalStart,
              totalEndDate: totalEnd,
              visibleStartDate: newStart,
              visibleEndDate: newEnd,
              startPadding: startPadding,
              endPadding: endPadding,
              onWindowChanged: (start, end, handle) {
                setState(() {
                  newStart = start;
                  newEnd = end;
                });
              },
            ),
          ),
        ),
      ),
    );

    // Drag left handle beyond the padded start
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(LegacyGanttTimelineScrubber)) - const Offset(100, 0));
    await gesture.moveBy(const Offset(-500, 0));
    await gesture.up();
    await tester.pump();

    expect(newStart, totalStart.subtract(startPadding));

    // Tap reset zoom button
    final resetButton = find.byIcon(Icons.zoom_out_map);
    expect(resetButton, findsOneWidget);
    await tester.tap(resetButton);
    await tester.pump();

    expect(newStart, totalStart.subtract(startPadding));
    expect(newEnd, totalEnd.add(endPadding));
  });

  testWidgets('does not call onWindowChanged when dragging outside window', (WidgetTester tester) async {
    int callCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LegacyGanttTimelineScrubber(
            totalStartDate: DateTime(2023, 1, 1),
            totalEndDate: DateTime(2023, 1, 31),
            visibleStartDate: DateTime(2023, 1, 10),
            visibleEndDate: DateTime(2023, 1, 20),
            onWindowChanged: (start, end, handle) {
              callCount++;
            },
          ),
        ),
      ),
    );

    final scrubber = find.byType(LegacyGanttTimelineScrubber);
    final scrubberTopLeft = tester.getTopLeft(scrubber);

    // Start a drag gesture outside any interactive area of the scrubber.
    // The scrubber window is in the middle, so the top-left corner is safe.
    final TestGesture gesture = await tester.startGesture(scrubberTopLeft);
    await gesture.moveBy(const Offset(10, 0));
    await gesture.up();
    await tester.pump();

    // The onWindowChanged callback should not have been called.
    expect(callCount, 0);
  });

  testWidgets('does not call onWindowChanged for _DragType.none inside onPanUpdate', (WidgetTester tester) async {
    int callCount = 0;
    DateTime visibleStart = DateTime(2023, 1, 10);
    DateTime visibleEnd = DateTime(2023, 1, 20);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LegacyGanttTimelineScrubber(
            totalStartDate: DateTime(2023, 1, 1),
            totalEndDate: DateTime(2023, 1, 31),
            visibleStartDate: visibleStart,
            visibleEndDate: visibleEnd,
            onWindowChanged: (start, end, handle) {
              callCount++;
              visibleStart = start;
              visibleEnd = end;
            },
          ),
        ),
      ),
    );

    // Start a drag gesture outside any interactive area of the scrubber.
    final gesture = await tester.startGesture(const Offset(0, 0));
    await gesture.moveBy(const Offset(50, 0));
    await gesture.up();

    expect(callCount, 0);
  });

  group('_calculateDisplayRange edge cases', () {
    test('handles visible window near the start boundary', () {
      final totalStart = DateTime(2023, 1, 1);
      final totalEnd = DateTime(2023, 1, 31);
      // Visible window is very close to the start.
      // Adjusted to ensure displayStart is clamped to totalStart.
      final visibleStart = DateTime(2023, 1, 1);
      final visibleEnd = DateTime(2023, 1, 3);

      final (displayStart, displayEnd) = calculateDisplayRange(
        totalStart,
        totalEnd,
        visibleStart,
        visibleEnd,
        Duration.zero,
        Duration.zero,
      );

      // The displayStart should be clamped to totalStart.
      expect(displayStart, totalStart);
      // The displayEnd should be adjusted to maintain the visible window's duration.
      // And then the buffer is added on top of that.
      final visibleDuration = visibleEnd.difference(visibleStart);
      final expectedDisplayEnd = totalStart.add(visibleDuration);
      final buffer = Duration(milliseconds: (visibleDuration.inMilliseconds * 0.25).round());
      expect(displayEnd, expectedDisplayEnd.add(buffer));
    });

    test('handles visible window near the end boundary', () {
      final totalStart = DateTime(2023, 1, 1);
      final totalEnd = DateTime(2023, 1, 31);
      // Visible window is very close to the end.
      // Adjusted to ensure displayEnd is clamped to totalEnd.
      final visibleStart = DateTime(2023, 1, 29);
      final visibleEnd = DateTime(2023, 1, 31);

      final (displayStart, displayEnd) = calculateDisplayRange(
        totalStart,
        totalEnd,
        visibleStart,
        visibleEnd,
        Duration.zero,
        Duration.zero,
      );

      // The displayEnd should be clamped to totalEnd.
      expect(displayEnd, totalEnd);
      // The displayStart should be adjusted to maintain the visible window's duration.
      // And then the buffer is subtracted from that.
      final visibleDuration = visibleEnd.difference(visibleStart);
      final expectedDisplayStart = totalEnd.subtract(visibleDuration);
      final buffer = Duration(milliseconds: (visibleDuration.inMilliseconds * 0.25).round());
      expect(displayStart, expectedDisplayStart.subtract(buffer));
    });
  });

  testWidgets('LegacyGanttTimelineScrubber adjusts end correctly when it becomes before start',
      (WidgetTester tester) async {
    DateTime newStart = DateTime(2023, 1, 10);
    DateTime newEnd = DateTime(2023, 1, 20);
    final totalStart = DateTime(2023, 1, 1);
    final totalEnd = DateTime(2023, 1, 31);
    const minWindowDuration = Duration(hours: 1);

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: Scaffold(
            body: LegacyGanttTimelineScrubber(
              totalStartDate: totalStart,
              totalEndDate: totalEnd,
              visibleStartDate: newStart,
              visibleEndDate: newEnd,
              onWindowChanged: (start, end, handle) {
                setState(() {
                  newStart = start;
                  newEnd = end;
                });
              },
            ),
          ),
        ),
      ),
    );

    final scrubber = find.byType(LegacyGanttTimelineScrubber);
    final scrubberWidget = tester.widget<LegacyGanttTimelineScrubber>(scrubber);
    final scrubberSize = tester.getSize(scrubber);
    final scrubberTopLeft = tester.getTopLeft(scrubber);

    final (displayStart, displayEnd) = calculateDisplayRange(
        scrubberWidget.totalStartDate, scrubberWidget.totalEndDate, newStart, newEnd, Duration.zero, Duration.zero);
    final displayDurationMs = displayEnd.difference(displayStart).inMilliseconds;
    final endX = (newEnd.difference(displayStart).inMilliseconds / displayDurationMs) * scrubberSize.width;

    final Offset rightHandle = scrubberTopLeft + Offset(endX, scrubberSize.height / 2);
    final TestGesture gesture = await tester.startGesture(rightHandle);
    // Drag the right handle far to the left, past the start handle and the total start date.
    // This will cause newVisibleEnd to be before newVisibleStart, triggering the fix-up logic.
    await gesture.moveBy(const Offset(-10000, 0));
    await gesture.up();
    await tester.pump();

    // The start date remains unchanged because we only dragged the right handle.
    expect(newStart, DateTime(2023, 1, 10));
    // The end date is corrected to be `newStart` + `minWindowDuration`.
    expect(newEnd, newStart.add(minWindowDuration));
  });
}
