import 'package:flutter/material.dart';

typedef CellBuilder = Widget Function(
  BuildContext context,
  DateTime date,
  double cellWidth,
  double cellHeight,
);

@immutable
class LegacyGanttTask {
  final String id;
  final String rowId;
  final DateTime start;
  final DateTime end;
  final String? name;
  final Color? color;
  final int? stackIndex;
  final bool isSummary;
  final bool isTimeRangeHighlight;
  final bool isOverlapIndicator;
  final List<LegacyGanttTaskSegment>? segments;
  final CellBuilder? cellBuilder;
  final Color? textColor;
  final String? originalId;

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
  }) => LegacyGanttTask(
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

@immutable
class LegacyGanttTaskSegment {
  final DateTime start;
  final DateTime end;
  final Color? color;

  const LegacyGanttTaskSegment({
    required this.start,
    required this.end,
    this.color,
  });
}