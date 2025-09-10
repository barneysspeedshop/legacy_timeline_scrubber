import 'package:flutter/material.dart';

/// Signature for a function that builds a widget for a timeline cell.
typedef CellBuilder = Widget Function(
  BuildContext context,
  DateTime date,
  double cellWidth,
  double cellHeight,
);

/// A task to be displayed in the timeline.
@immutable
class LegacyGanttTask {
  /// A unique identifier for the task.
  final String id;

  /// The identifier of the row the task belongs to.
  final String rowId;

  /// The start date of the task.
  final DateTime start;

  /// The end date of the task.
  final DateTime end;

  /// The name of the task.
  final String? name;

  /// The color of the task.
  final Color? color;

  /// The index of the task in a stack of tasks.
  final int? stackIndex;

  /// Whether the task is a summary task.
  final bool isSummary;

  /// Whether the task is a time range highlight.
  final bool isTimeRangeHighlight;

  /// Whether the task is an overlap indicator.
  final bool isOverlapIndicator;

  /// The segments of the task.
  final List<LegacyGanttTaskSegment>? segments;

  /// A builder for the cell of the task.
  final CellBuilder? cellBuilder;

  /// The color of the text of the task.
  final Color? textColor;

  /// The original identifier of the task.
  final String? originalId;

  /// Creates a new [LegacyGanttTask].
  const LegacyGanttTask({
    required this.id,
    required this.rowId,
    required this.start,
    required this.end,
    this.name,
    this.color,
    this.stackIndex,
    this.isSummary = false,
    this.isTimeRangeHighlight = false,
    this.isOverlapIndicator = false,
    this.segments,
    this.cellBuilder,
    this.textColor,
    this.originalId,
  });

  /// Creates a copy of this task with the given fields replaced with the new
  /// values.
  LegacyGanttTask copyWith({
    String? id,
    String? rowId,
    DateTime? start,
    DateTime? end,
    String? name,
    Color? color,
    int? stackIndex,
    bool? isSummary,
    bool? isTimeRangeHighlight,
    bool? isOverlapIndicator,
    List<LegacyGanttTaskSegment>? segments,
    CellBuilder? cellBuilder,
    Color? textColor,
    String? originalId,
  }) =>
      LegacyGanttTask(
        id: id ?? this.id,
        rowId: rowId ?? this.rowId,
        start: start ?? this.start,
        end: end ?? this.end,
        name: name ?? this.name,
        color: color ?? this.color,
        stackIndex: stackIndex ?? this.stackIndex,
        isSummary: isSummary ?? this.isSummary,
        isTimeRangeHighlight: isTimeRangeHighlight ?? this.isTimeRangeHighlight,
        isOverlapIndicator: isOverlapIndicator ?? this.isOverlapIndicator,
        segments: segments ?? this.segments,
        cellBuilder: cellBuilder ?? this.cellBuilder,
        textColor: textColor ?? this.textColor,
        originalId: originalId ?? this.originalId,
      );
}

/// A segment of a task.
@immutable
class LegacyGanttTaskSegment {
  /// The start date of the segment.
  final DateTime start;

  /// The end date of the segment.
  final DateTime end;

  /// The color of the segment.
  final Color? color;

  /// Creates a new [LegacyGanttTaskSegment].
  const LegacyGanttTaskSegment({
    required this.start,
    required this.end,
    this.color,
  });
}
