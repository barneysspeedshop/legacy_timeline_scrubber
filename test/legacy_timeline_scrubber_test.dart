import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legacy_timeline_scrubber/legacy_timeline_scrubber.dart';

void main() {
  testWidgets('LegacyGanttTimelineScrubber basic rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LegacyGanttTimelineScrubber(
            totalStartDate: DateTime(2023, 1, 1),
            totalEndDate: DateTime(2023, 1, 31),
            visibleStartDate: DateTime(2023, 1, 5),
            visibleEndDate: DateTime(2023, 1, 15),
            onWindowChanged: (start, end) {},
          ),
        ),
      ),
    );

    expect(find.byType(LegacyGanttTimelineScrubber), findsOneWidget);
  });

  testWidgets('LegacyGanttTimelineScrubber drag left handle', (WidgetTester tester) async {
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
                onWindowChanged: (start, end) {
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

    final Offset leftHandle = tester.getCenter(scrubber) - const Offset(50, 0);
    final TestGesture gesture = await tester.startGesture(leftHandle);
    await gesture.moveBy(const Offset(-20, 0));
    await gesture.up();
    await tester.pump();

    expect(newStart.isBefore(DateTime(2023, 1, 5)), isTrue);
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
                onWindowChanged: (start, end) {
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

    final Offset rightHandle = tester.getCenter(scrubber) + const Offset(50, 0);
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
                onWindowChanged: (start, end) {
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
                onWindowChanged: (start, end) {
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
}