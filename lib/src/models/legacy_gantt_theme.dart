import 'package:flutter/material.dart';

/// Defines the theme for the [LegacyGanttTimelineScrubber].
///
/// This class encapsulates all the visual styling for the chart, including
/// colors, text styles, and dimensions.
@immutable
class LegacyGanttTheme {
  /// The primary color for task bars.
  final Color barColorPrimary;

  /// The secondary color for task bars.
  final Color barColorSecondary;

  /// The color for text.
  final Color textColor;

  /// The background color of the chart.
  final Color backgroundColor;

  /// The color of the grid lines.
  final Color gridColor;

  /// The color for summary bars.
  final Color summaryBarColor;

  /// The color for bars that represent a conflict.
  final Color conflictBarColor;

  /// The color for ghost bars, which are used to indicate a task's original
  /// position during a drag operation.
  final Color ghostBarColor;

  /// The text style for the axis labels.
  final TextStyle axisTextStyle;

  /// The text style for task labels.
  final TextStyle taskTextStyle;

  /// The color of the lines drawn to represent task dependencies.
  final Color dependencyLineColor;

  /// The color for background highlights, such as holidays or weekends.
  /// This is used for tasks where `isTimeRangeHighlight` is true.
  final Color timeRangeHighlightColor;

  /// The background color for a task that is contained within another.
  final Color containedDependencyBackgroundColor;

  /// The background color for the highlight that appears when hovering over
  /// empty space in a row, indicating a new task can be created.
  final Color emptySpaceHighlightColor;

  /// The color of the add icon (+) that appears in the empty space highlight.
  final Color emptySpaceAddIconColor;

  /// The ratio of the bar height to the row height.
  final double barHeightRatio;

  /// The corner radius for task bars.
  final Radius barCornerRadius;

  /// Whether to show borders between rows.
  final bool showRowBorders;

  /// The color of the row borders.
  final Color? rowBorderColor;

  /// The background color of the scrubber.
  final Color scrubberBackgroundColor;

  /// The color of the scrubber window.
  final Color scrubberWindowColor;

  /// The color of the scrubber window border.
  final Color scrubberWindowBorderColor;

  /// Creates a new [LegacyGanttTheme].
  LegacyGanttTheme({
    required this.barColorPrimary,
    required this.barColorSecondary,
    required this.textColor,
    required this.backgroundColor,
    this.gridColor = const Color(0x33888888), // Colors.grey.withValues(alpha:0.2)
    this.summaryBarColor = const Color(0x33000000), // Colors.black.withValues(alpha:0.2)
    this.conflictBarColor = const Color(0x80F44336), // Colors.red.withValues(alpha:0.5)
    this.ghostBarColor = const Color(0xB32196F3), // Colors.blue.withValues(alpha:0.7)
    TextStyle? axisTextStyle,
    TextStyle? taskTextStyle,
    this.showRowBorders = false,
    this.rowBorderColor,
    this.dependencyLineColor = const Color(0xFF616161), // Colors.grey[700]!
    this.timeRangeHighlightColor =
        const Color(0x0D000000), // Colors.black.withValues(alpha:0.05)
    this.containedDependencyBackgroundColor =
        const Color(0x1A000000), // Colors.black.withValues(alpha:0.1)
    this.emptySpaceHighlightColor =
        const Color(0x0F2196F3), // Colors.blue.withValues(alpha:0.06)
    this.emptySpaceAddIconColor = const Color(0xFF2196F3), // Colors.blue
    this.barHeightRatio = 0.7,
    this.barCornerRadius = const Radius.circular(4.0),
    // New fields
    this.scrubberBackgroundColor = const Color(0xFF303030), // Colors.grey.shade800
    this.scrubberWindowColor =
        const Color(0x332196F3), // Colors.blue.withValues(alpha:0.2)
    this.scrubberWindowBorderColor =
        const Color(0xFF1976D2), // Colors.blue.shade700
  }) : axisTextStyle = const TextStyle(fontSize: 12)
            .copyWith(color: textColor)
            .merge(axisTextStyle),
       taskTextStyle = const TextStyle(fontSize: 14, color: Colors.white)
           .merge(taskTextStyle);

  /// Creates a copy of this theme with the given fields replaced with the new
  /// values.
  LegacyGanttTheme copyWith({
    Color? barColorPrimary,
    Color? barColorSecondary,
    Color? textColor,
    Color? backgroundColor,
    Color? gridColor,
    Color? summaryBarColor,
    Color? conflictBarColor,
    Color? ghostBarColor,
    TextStyle? axisTextStyle,
    TextStyle? taskTextStyle,
    Color? dependencyLineColor,
    Color? timeRangeHighlightColor,
    Color? containedDependencyBackgroundColor,
    Color? emptySpaceHighlightColor,
    Color? emptySpaceAddIconColor,
    double? barHeightRatio,
    Radius? barCornerRadius,
    bool? showRowBorders,
    Color? rowBorderColor,
    // New fields
    Color? scrubberBackgroundColor,
    Color? scrubberWindowColor,
    Color? scrubberWindowBorderColor,
  }) =>
      LegacyGanttTheme(
        barColorPrimary: barColorPrimary ?? this.barColorPrimary,
        barColorSecondary: barColorSecondary ?? this.barColorSecondary,
        textColor: textColor ?? this.textColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        gridColor: gridColor ?? this.gridColor,
        summaryBarColor: summaryBarColor ?? this.summaryBarColor,
        conflictBarColor: conflictBarColor ?? this.conflictBarColor,
        ghostBarColor: ghostBarColor ?? this.ghostBarColor,
        axisTextStyle: axisTextStyle ?? this.axisTextStyle,
        taskTextStyle: taskTextStyle ?? this.taskTextStyle,
        dependencyLineColor: dependencyLineColor ?? this.dependencyLineColor,
        timeRangeHighlightColor:
            timeRangeHighlightColor ?? this.timeRangeHighlightColor,
        containedDependencyBackgroundColor: containedDependencyBackgroundColor ??
            this.containedDependencyBackgroundColor,
        emptySpaceHighlightColor:
            emptySpaceHighlightColor ?? this.emptySpaceHighlightColor,
        emptySpaceAddIconColor:
            emptySpaceAddIconColor ?? this.emptySpaceAddIconColor,
        barHeightRatio: barHeightRatio ?? this.barHeightRatio,
        barCornerRadius: barCornerRadius ?? this.barCornerRadius,
        showRowBorders: showRowBorders ?? this.showRowBorders,
        rowBorderColor: rowBorderColor ?? this.rowBorderColor,
        // New fields
        scrubberBackgroundColor:
            scrubberBackgroundColor ?? this.scrubberBackgroundColor,
        scrubberWindowColor: scrubberWindowColor ?? this.scrubberWindowColor,
        scrubberWindowBorderColor:
            scrubberWindowBorderColor ?? this.scrubberWindowBorderColor,
      );

  /// Creates a default theme based on the application's [ThemeData].
  factory LegacyGanttTheme.fromTheme(ThemeData theme) => LegacyGanttTheme(
        barColorPrimary: theme.colorScheme.primary,
        barColorSecondary: theme.colorScheme.secondary,
        textColor: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surface,
        gridColor: theme.colorScheme.onSurface.withValues(alpha:0.2),
        summaryBarColor: theme.colorScheme.onSurface.withValues(alpha:0.2),
        conflictBarColor: Colors.red.withValues(alpha:0.5),
        ghostBarColor: theme.colorScheme.primary.withValues(alpha:0.7),
        rowBorderColor: theme.colorScheme.onSurface.withValues(alpha:0.2),
        dependencyLineColor: theme.colorScheme.onSurface.withValues(alpha:0.8),
        timeRangeHighlightColor: theme.colorScheme.onSurface.withValues(alpha:0.05),
        containedDependencyBackgroundColor:
            theme.colorScheme.primary.withValues(alpha:0.1),
        emptySpaceHighlightColor: theme.colorScheme.primary.withValues(alpha:0.06),
        emptySpaceAddIconColor: theme.colorScheme.primary,
        axisTextStyle: theme.textTheme.bodySmall,
        taskTextStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary),
        // New fields
        scrubberBackgroundColor: theme.colorScheme.surfaceContainerHighest,
        scrubberWindowColor: theme.colorScheme.primaryContainer.withValues(alpha:0.2),
        scrubberWindowBorderColor: theme.colorScheme.primary,
      );
}