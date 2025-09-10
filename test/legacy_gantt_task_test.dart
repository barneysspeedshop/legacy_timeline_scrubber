import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legacy_timeline_scrubber/src/models/legacy_gantt_task.dart';

void main() {
  group('LegacyGanttTask', () {
    final now = DateTime.now();
    final task = LegacyGanttTask(
      id: 'task1',
      rowId: 'rowA',
      start: now,
      end: now.add(const Duration(days: 1)),
      name: 'Test Task',
      color: Colors.blue,
      stackIndex: 0,
      isSummary: false,
      isTimeRangeHighlight: false,
      isOverlapIndicator: false,
      segments: [
        LegacyGanttTaskSegment(
          start: now,
          end: now.add(const Duration(hours: 12)),
          color: Colors.lightBlue,
        ),
      ],
      textColor: Colors.white,
      originalId: 'originalTask1',
    );

    test('constructor assigns all properties correctly', () {
      expect(task.id, 'task1');
      expect(task.rowId, 'rowA');
      expect(task.start, now);
      expect(task.end, now.add(const Duration(days: 1)));
      expect(task.name, 'Test Task');
      expect(task.color, Colors.blue);
      expect(task.stackIndex, 0);
      expect(task.isSummary, isFalse);
      expect(task.isTimeRangeHighlight, isFalse);
      expect(task.isOverlapIndicator, isFalse);
      expect(task.segments, isNotNull);
      expect(task.segments!.length, 1);
      expect(task.textColor, Colors.white);
      expect(task.originalId, 'originalTask1');
      expect(task.cellBuilder, isNull); // No cellBuilder provided in this test
    });

    test('copyWith creates a new instance with updated values', () {
      final updatedTask = task.copyWith(
        name: 'Updated Task',
        color: Colors.red,
        isSummary: true,
      );

      expect(updatedTask.id, task.id); // Should remain the same
      expect(updatedTask.rowId, task.rowId); // Should remain the same
      expect(updatedTask.name, 'Updated Task'); // Should be updated
      expect(updatedTask.color, Colors.red); // Should be updated
      expect(updatedTask.isSummary, isTrue); // Should be updated
      expect(updatedTask.isTimeRangeHighlight, task.isTimeRangeHighlight); // Should remain the same
      expect(updatedTask.segments, task.segments); // Should remain the same
    });

    test('copyWith with no changes returns an identical task', () {
      final copiedTask = task.copyWith();
      expect(copiedTask.id, task.id);
      expect(copiedTask.rowId, task.rowId);
      expect(copiedTask.start, task.start);
      expect(copiedTask.end, task.end);
      expect(copiedTask.name, task.name);
      expect(copiedTask.color, task.color);
      expect(copiedTask.stackIndex, task.stackIndex);
      expect(copiedTask.isSummary, task.isSummary);
      expect(copiedTask.isTimeRangeHighlight, task.isTimeRangeHighlight);
      expect(copiedTask.isOverlapIndicator, task.isOverlapIndicator);
      expect(copiedTask.segments, task.segments);
      expect(copiedTask.cellBuilder, task.cellBuilder);
      expect(copiedTask.textColor, task.textColor);
      expect(copiedTask.originalId, task.originalId);
    });

    test('default values are correctly applied', () {
      final defaultTask = LegacyGanttTask(
        id: 'default',
        rowId: 'defaultRow',
        start: now,
        end: now.add(const Duration(days: 1)),
      );
      expect(defaultTask.isSummary, isFalse);
      expect(defaultTask.isTimeRangeHighlight, isFalse);
      expect(defaultTask.isOverlapIndicator, isFalse);
      expect(defaultTask.segments, isNull);
      expect(defaultTask.name, isNull);
      expect(defaultTask.color, isNull);
      expect(defaultTask.stackIndex, isNull);
      expect(defaultTask.cellBuilder, isNull);
      expect(defaultTask.textColor, isNull);
      expect(defaultTask.originalId, isNull);
    });
  });

  group('LegacyGanttTaskSegment', () {
    final now = DateTime.now();
    final segment = LegacyGanttTaskSegment(
      start: now,
      end: now.add(const Duration(hours: 1)),
      color: Colors.purple,
    );

    test('constructor assigns all properties correctly', () {
      expect(segment.start, now);
      expect(segment.end, now.add(const Duration(hours: 1)));
      expect(segment.color, Colors.purple);
    });

    test('color can be null', () {
      final segmentWithoutColor = LegacyGanttTaskSegment(
        start: now,
        end: now.add(const Duration(hours: 1)),
      );
      expect(segmentWithoutColor.color, isNull);
    });
  });
}
