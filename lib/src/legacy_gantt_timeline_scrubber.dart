import 'package:flutter/foundation.dart' show listEquals;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart';

import 'models/legacy_gantt_task.dart';
import 'models/legacy_gantt_theme.dart';

/// Defines the mode of operation for the timeline scrubber.
enum TimelineMode { dateTime, lineCount }

/// Indicates which part of the scrubber was interacted with to cause a change.
enum ScrubberHandle {
  /// The left handle of the scrubber window was dragged.
  left,

  /// The right handle of the scrubber window was dragged.
  right,

  /// The main body of the scrubber window was dragged.
  scrub,

  /// The change was not caused by a direct handle interaction (e.g., reset).
  programmatic,
}

enum _DragType { none, leftHandle, rightHandle, scrub, seek }

/// A widget that displays a timeline scrubber for a Gantt chart.
class LegacyGanttTimelineScrubber extends StatefulWidget {
  /// The mode of operation for the scrubber (DateTime or lineCount).
  final TimelineMode mode;

  /// The total start date of the timeline.
  /// Required if [mode] is [TimelineMode.dateTime].
  final DateTime? totalStartDate;

  /// The total end date of the timeline.
  /// Required if [mode] is [TimelineMode.dateTime].
  final DateTime? totalEndDate;

  /// The total number of lines.
  /// Required if [mode] is [TimelineMode.lineCount].
  final int? totalLineCount;

  /// The start date of the visible window.
  /// Required if [mode] is [TimelineMode.dateTime].
  final DateTime? visibleStartDate;

  /// The end date of the visible window.
  /// Required if [mode] is [TimelineMode.dateTime].
  final DateTime? visibleEndDate;

  /// A callback that is called when the visible window changes.
  final Function(DateTime, DateTime, ScrubberHandle)? onWindowChanged;

  /// A callback that is called when the user clicks on the track to seek.
  final Function(DateTime)? onSeek;

  /// A callback that is called when the user clicks on the track to seek in line mode.
  final Function(int)? onLineSeek;

  /// The tasks to display in the timeline.
  final List<LegacyGanttTask> tasks;

  /// The start line of the visible window.
  /// Required if [mode] is [TimelineMode.lineCount].
  final int? visibleStartLine;

  /// The end line of the visible window.
  /// Required if [mode] is [TimelineMode.lineCount].
  final int? visibleEndLine;

  /// The padding to add to the start of the timeline.
  final Duration startPadding;

  /// The padding to add to the end of the timeline.
  final Duration endPadding;

  /// A callback that is called when the visible line window changes.
  /// Required if [mode] is [TimelineMode.lineCount].
  final Function(int, int, ScrubberHandle)? onLineWindowChanged;

  /// The theme to use for the timeline.
  final LegacyGanttTheme? theme;

  /// The rows that are visible in the timeline.
  final List<String>? visibleRows;

  /// The maximum stack depth for each row.
  final Map<String, int>? rowMaxStackDepth;

  /// The height of each row.
  final double? rowHeight;

  /// The orientation of the scrubber.
  final Axis orientation;

  /// Whether to show the reset zoom button when the timeline is zoomed.
  final bool showResetZoomButton;

  /// Whether the scrubber should always show the full range (no automatic zooming).
  final bool alwaysShowFullRange;

  /// Creates a new [LegacyGanttTimelineScrubber].
  const LegacyGanttTimelineScrubber({
    super.key,
    this.mode = TimelineMode.dateTime,
    this.totalStartDate,
    this.totalEndDate,
    this.totalLineCount,
    this.visibleStartDate,
    this.visibleEndDate,
    this.visibleStartLine,
    this.visibleEndLine,
    this.onWindowChanged,
    this.onSeek,
    this.onLineSeek,
    this.onLineWindowChanged,
    this.tasks = const [],
    this.theme,
    this.visibleRows,
    this.rowMaxStackDepth,
    this.rowHeight,
    this.orientation = Axis.horizontal,
    this.startPadding = Duration.zero,
    this.endPadding = Duration.zero,
    this.alwaysShowFullRange = false,
    this.showResetZoomButton = true,
  }) : assert(
         mode == TimelineMode.dateTime
             ? (totalStartDate != null &&
                   totalEndDate != null &&
                   visibleStartDate != null &&
                   visibleEndDate != null &&
                   true)
             : (totalLineCount != null &&
                   visibleStartLine != null &&
                   visibleEndLine != null &&
                   onLineWindowChanged != null),
         'For TimelineMode.dateTime, totalStartDate, totalEndDate, visibleStartDate, visibleEndDate, and onWindowChanged must be provided. '
         'For TimelineMode.lineCount, totalLineCount, visibleStartLine, visibleEndLine, and onLineWindowChanged must be provided.',
       ),
       assert(
         mode == TimelineMode.dateTime
             ? (totalLineCount == null &&
                   visibleStartLine == null &&
                   visibleEndLine == null &&
                   onLineWindowChanged == null)
             : (totalStartDate == null && totalEndDate == null && visibleStartDate == null && visibleEndDate == null),
         'Cannot mix DateTime and lineCount properties. Provide either all DateTime-related or all lineCount-related properties.',
       );

  @override
  State<LegacyGanttTimelineScrubber> createState() => _LegacyGanttTimelineScrubberState();
}

class _LegacyGanttTimelineScrubberState extends State<LegacyGanttTimelineScrubber> {
  _DragType _dragType = _DragType.none;
  double _dragStartPos = 0.0;
  late double _dragStartVisibleStartValue;
  late double _dragStartVisibleEndValue;
  late double _dragStartDisplayStartValue;
  late double _dragStartDisplayEndValue;
  MouseCursor _cursor = SystemMouseCursors.basic;

  double get _totalStartValue {
    if (widget.mode == TimelineMode.dateTime) {
      return widget.totalStartDate!.subtract(widget.startPadding).millisecondsSinceEpoch.toDouble();
    }
    return 0.0;
  }

  double get _totalEndValue {
    if (widget.mode == TimelineMode.dateTime) {
      return widget.totalEndDate!.add(widget.endPadding).millisecondsSinceEpoch.toDouble();
    }
    return widget.totalLineCount!.toDouble();
  }

  double get _visibleStartValue => widget.mode == TimelineMode.dateTime
      ? widget.visibleStartDate!.millisecondsSinceEpoch.toDouble()
      : widget.visibleStartLine!.toDouble();

  double get _visibleEndValue => widget.mode == TimelineMode.dateTime
      ? widget.visibleEndDate!.millisecondsSinceEpoch.toDouble()
      : widget.visibleEndLine!.toDouble();

  double get _effectiveTotalStartValue => _totalStartValue;
  double get _effectiveTotalEndValue => _totalEndValue;

  (double, double) _calculateDisplayRange(double visibleStart, double visibleEnd, double dimension) {
    if (widget.alwaysShowFullRange) {
      return (_effectiveTotalStartValue, _effectiveTotalEndValue);
    }

    final visibleRange = visibleEnd - visibleStart;
    final totalRange = _effectiveTotalEndValue - _effectiveTotalStartValue;

    if (visibleRange >= totalRange) {
      return (_effectiveTotalStartValue, _effectiveTotalEndValue);
    }

    final buffer = visibleRange * 0.25;

    double displayStart = visibleStart - buffer;
    double displayEnd = visibleEnd + buffer;

    if (displayStart < _effectiveTotalStartValue) {
      displayStart = _effectiveTotalStartValue;
    }
    if (displayEnd > _effectiveTotalEndValue) {
      displayEnd = _effectiveTotalEndValue;
    }

    if (displayEnd - displayStart < visibleRange) {
      if (displayStart == _effectiveTotalStartValue) {
        displayEnd = displayStart + visibleRange;
      } else if (displayEnd == _effectiveTotalEndValue) {
        displayStart = displayEnd - visibleRange;
      }
    }

    return (
      displayStart.clamp(_effectiveTotalStartValue, _effectiveTotalEndValue),
      displayEnd.clamp(_effectiveTotalStartValue, _effectiveTotalEndValue),
    );
  }

  _DragType _getDragTypeAtPosition(Offset localPosition, Size size) {
    final dimension = widget.orientation == Axis.horizontal ? size.width : size.height;
    final pos = widget.orientation == Axis.horizontal ? localPosition.dx : localPosition.dy;

    if (dimension == 0) return _DragType.none;

    final (displayStart, displayEnd) = _calculateDisplayRange(_visibleStartValue, _visibleEndValue, dimension);
    final displayRange = displayEnd - displayStart;
    if (displayRange <= 0) return _DragType.none;

    final double startPos = ((_visibleStartValue - displayStart) / displayRange) * dimension;
    final double endPos = ((_visibleEndValue - displayStart) / displayRange) * dimension;

    final bool canResize = widget.mode != TimelineMode.lineCount;
    const handleHitWidth = 20.0;

    if (canResize && (pos - startPos).abs() < handleHitWidth) {
      return _DragType.leftHandle;
    } else if (canResize && (pos - endPos).abs() < handleHitWidth) {
      return _DragType.rightHandle;
    } else if (pos > startPos && pos < endPos) {
      return _DragType.scrub;
    } else {
      return _DragType.none;
    }
  }

  void _onHover(PointerEvent event, Size size) {
    final dragType = _getDragTypeAtPosition(event.localPosition, size);
    MouseCursor newCursor;
    switch (dragType) {
      case _DragType.leftHandle:
      case _DragType.rightHandle:
        newCursor = widget.orientation == Axis.horizontal
            ? SystemMouseCursors.resizeLeftRight
            : SystemMouseCursors.resizeUpDown;
        break;
      case _DragType.scrub:
        newCursor = SystemMouseCursors.move;
        break;
      case _DragType.seek:
      case _DragType.none:
        newCursor = SystemMouseCursors.basic;
        break;
    }

    if (newCursor != _cursor) {
      setState(() => _cursor = newCursor);
    }
  }

  void _onExit(PointerEvent event) {
    if (_cursor != SystemMouseCursors.basic) {
      setState(() => _cursor = SystemMouseCursors.basic);
    }
  }

  void _onTapUp(TapUpDetails details, Size size) {
    _performSeek(details.localPosition, size);
  }

  void _performSeek(Offset localPosition, Size size) {
    final dimension = widget.orientation == Axis.horizontal ? size.width : size.height;
    final pos = widget.orientation == Axis.horizontal ? localPosition.dx : localPosition.dy;
    final (displayStart, displayEnd) = _calculateDisplayRange(_visibleStartValue, _visibleEndValue, dimension);
    final displayRange = displayEnd - displayStart;

    final seekValue = displayStart + (pos / dimension) * displayRange;
    if (widget.mode == TimelineMode.lineCount) {
      widget.onLineSeek?.call(seekValue.toInt());
    } else {
      widget.onSeek?.call(DateTime.fromMillisecondsSinceEpoch(seekValue.toInt()));
    }
  }

  void _onPanStart(DragStartDetails details, Size size) {
    _dragType = _getDragTypeAtPosition(details.localPosition, size);

    if (_dragType != _DragType.none) {
      _dragStartPos = widget.orientation == Axis.horizontal ? details.localPosition.dx : details.localPosition.dy;
      _dragStartVisibleStartValue = _visibleStartValue;
      _dragStartVisibleEndValue = _visibleEndValue;

      final dimension = widget.orientation == Axis.horizontal ? size.width : size.height;
      final (displayStart, displayEnd) = _calculateDisplayRange(_visibleStartValue, _visibleEndValue, dimension);
      _dragStartDisplayStartValue = displayStart;
      _dragStartDisplayEndValue = displayEnd;
    } else {
      _dragType = _DragType.seek;
      _performSeek(details.localPosition, size);
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    if (_dragType == _DragType.none) return;

    if (_dragType == _DragType.seek) {
      _performSeek(details.localPosition, size);
      return;
    }

    final dimension = widget.orientation == Axis.horizontal ? size.width : size.height;
    final pos = widget.orientation == Axis.horizontal ? details.localPosition.dx : details.localPosition.dy;

    final dragDisplayRange = _dragStartDisplayEndValue - _dragStartDisplayStartValue;
    if (dragDisplayRange <= 0) return;

    final delta = pos - _dragStartPos;
    final dValue = delta / dimension * dragDisplayRange;

    double newStart = _dragStartVisibleStartValue;
    double newEnd = _dragStartVisibleEndValue;

    switch (_dragType) {
      case _DragType.leftHandle:
        newStart = _dragStartVisibleStartValue + dValue;
        break;
      case _DragType.rightHandle:
        newEnd = _dragStartVisibleEndValue + dValue;
        break;
      case _DragType.scrub:
        newStart = _dragStartVisibleStartValue + dValue;
        newEnd = _dragStartVisibleEndValue + dValue;
        break;
      case _DragType.seek:
      case _DragType.none:
        return;
    }

    _updateVisibleWindow(newStart, newEnd, _dragType);
  }

  void _onPointerSignal(PointerSignalEvent event, Size size) {
    if (event is PointerScrollEvent) {
      final dimension = widget.orientation == Axis.horizontal ? size.width : size.height;
      if (dimension == 0) return;

      final (displayStart, displayEnd) = _calculateDisplayRange(_visibleStartValue, _visibleEndValue, dimension);
      final displayRange = displayEnd - displayStart;
      if (displayRange <= 0) return;

      // Use the raw scroll delta. Flutter's scrollDelta already accounts for OS "Natural Scrolling"
      // settings. A positive dy represents a "scroll down" intent, which should move the
      // scrubber window (the viewport) further down the timeline, matching the editor's behavior.
      final delta = widget.orientation == Axis.horizontal ? event.scrollDelta.dx : event.scrollDelta.dy;
      final double dValue = (delta / dimension) * displayRange;

      _updateVisibleWindow(_visibleStartValue + dValue, _visibleEndValue + dValue, _DragType.scrub);
    }
  }

  void _updateVisibleWindow(double newVisibleStartValue, double newVisibleEndValue, _DragType currentDragType) {
    if (widget.mode == TimelineMode.dateTime) {
      const minWindowDuration = Duration(hours: 1);
      DateTime newVisibleStart = DateTime.fromMillisecondsSinceEpoch(newVisibleStartValue.toInt());
      DateTime newVisibleEnd = DateTime.fromMillisecondsSinceEpoch(newVisibleEndValue.toInt());
      final totalStart = widget.totalStartDate!.subtract(widget.startPadding);
      final totalEnd = widget.totalEndDate!.add(widget.endPadding);

      if (newVisibleEnd.difference(newVisibleStart) < minWindowDuration) {
        if (currentDragType == _DragType.leftHandle) {
          newVisibleStart = newVisibleEnd.subtract(minWindowDuration);
        } else {
          newVisibleEnd = newVisibleStart.add(minWindowDuration);
        }
      }

      if (newVisibleStart.isBefore(totalStart)) {
        final correction = totalStart.difference(newVisibleStart);
        newVisibleStart = totalStart;
        if (currentDragType == _DragType.scrub) {
          newVisibleEnd = newVisibleEnd.add(correction);
        }
      }

      if (newVisibleEnd.isAfter(totalEnd)) {
        final correction = totalEnd.difference(newVisibleEnd);
        newVisibleEnd = totalEnd;
        if (currentDragType == _DragType.scrub) {
          newVisibleStart = newVisibleStart.add(correction);
        }
      }

      newVisibleStart = newVisibleStart.isBefore(totalStart) ? totalStart : newVisibleStart;
      newVisibleEnd = newVisibleEnd.isAfter(totalEnd) ? totalEnd : newVisibleEnd;
      if (newVisibleEnd.isBefore(newVisibleStart)) {
        newVisibleEnd = newVisibleStart.add(minWindowDuration);
      }

      widget.onWindowChanged?.call(newVisibleStart, newVisibleEnd, _mapDragTypeToScrubberHandle(currentDragType));
    } else {
      // Clamping logic for lineCount mode to ensure it always respects file boundaries (starts at 0)
      final totalStart = _totalStartValue;
      final totalEnd = _totalEndValue;
      const minWindowLines = 1.0;

      double startValue = newVisibleStartValue;
      double endValue = newVisibleEndValue;

      if (endValue - startValue < minWindowLines) {
        if (currentDragType == _DragType.leftHandle) {
          startValue = endValue - minWindowLines;
        } else {
          endValue = startValue + minWindowLines;
        }
      }

      if (startValue < totalStart) {
        final correction = totalStart - startValue;
        startValue = totalStart;
        if (currentDragType == _DragType.scrub) {
          endValue += correction;
        }
      }

      if (endValue > totalEnd) {
        final correction = endValue - totalEnd;
        endValue = totalEnd;
        if (currentDragType == _DragType.scrub) {
          startValue -= correction;
        }
      }

      startValue = startValue.clamp(totalStart, totalEnd);
      endValue = endValue.clamp(totalStart, totalEnd);

      widget.onLineWindowChanged!(startValue.toInt(), endValue.toInt(), _mapDragTypeToScrubberHandle(currentDragType));
    }
  }

  ScrubberHandle _mapDragTypeToScrubberHandle(_DragType type) {
    switch (type) {
      case _DragType.leftHandle:
        return ScrubberHandle.left;
      case _DragType.rightHandle:
        return ScrubberHandle.right;
      case _DragType.scrub:
        return ScrubberHandle.scrub;
      case _DragType.seek:
        return ScrubberHandle.scrub;
      case _DragType.none:
        return ScrubberHandle.programmatic;
    }
  }

  void _onPanEnd(DragEndDetails details) => _dragType = _DragType.none;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? LegacyGanttTheme.fromTheme(Theme.of(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        final dimension = widget.orientation == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;
        final (displayStartValue, displayEndValue) = _calculateDisplayRange(
          _visibleStartValue,
          _visibleEndValue,
          dimension,
        );

        final totalRangeValue = _totalEndValue - _totalStartValue;
        final isZoomed = (displayEndValue - displayStartValue) < totalRangeValue;

        return Stack(
          alignment: widget.orientation == Axis.horizontal ? Alignment.centerRight : Alignment.bottomCenter,
          children: [
            Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: (event) => _onPointerSignal(event, constraints.biggest),
              child: MouseRegion(
                cursor: _cursor,
                onHover: (e) => _onHover(e, constraints.biggest),
                onExit: _onExit,
                child: GestureDetector(
                  dragStartBehavior: DragStartBehavior.down,
                  onTapUp: (d) => _onTapUp(d, constraints.biggest),
                  onPanStart: (d) => _onPanStart(d, constraints.biggest),
                  onPanUpdate: (d) => _onPanUpdate(d, constraints.biggest),
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: _ScrubberPainter(
                      mode: widget.mode,
                      totalStartValue: _totalStartValue,
                      totalEndValue: _totalEndValue,
                      displayStartValue: displayStartValue,
                      displayEndValue: displayEndValue,
                      visibleStartValue: _visibleStartValue,
                      visibleEndValue: _visibleEndValue,
                      tasks: widget.tasks,
                      theme: theme,
                      orientation: widget.orientation,
                    ),
                    size: constraints.biggest,
                  ),
                ),
              ),
            ),
            if (isZoomed && widget.showResetZoomButton)
              IconButton(
                padding: const EdgeInsets.only(right: 8.0),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.zoom_out_map),
                iconSize: 20.0,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                tooltip: 'Reset Zoom',
                onPressed: () => widget.mode == TimelineMode.dateTime
                    ? widget.onWindowChanged?.call(
                        widget.totalStartDate!.subtract(widget.startPadding),
                        widget.totalEndDate!.add(widget.endPadding),
                        ScrubberHandle.programmatic,
                      )
                    : widget.onLineWindowChanged!(0, widget.totalLineCount!, ScrubberHandle.programmatic),
              ),
          ],
        );
      },
    );
  }
}

class _ScrubberPainter extends CustomPainter {
  final TimelineMode mode;
  final double totalStartValue;
  final double totalEndValue;
  final double displayStartValue;
  final double displayEndValue;
  final double visibleStartValue;
  final double visibleEndValue;
  final List<LegacyGanttTask> tasks;
  final LegacyGanttTheme theme;
  final Axis orientation;

  _ScrubberPainter({
    required this.mode,
    required this.totalStartValue,
    required this.totalEndValue,
    required this.displayStartValue,
    required this.displayEndValue,
    required this.visibleStartValue,
    required this.visibleEndValue,
    required this.tasks,
    required this.theme,
    required this.orientation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final displayRangeValue = displayEndValue - displayStartValue;
    if (displayRangeValue <= 0) return;

    final dimension = orientation == Axis.horizontal ? size.width : size.height;

    double valueToPos(double value) {
      if (value < displayStartValue) return 0.0;
      if (value > displayEndValue) return dimension;
      final valueOffset = value - displayStartValue;
      return (valueOffset / displayRangeValue) * dimension;
    }

    final taskPaint = Paint(); // Moved outside loop for efficiency

    for (final task in tasks.where((t) => !t.isTimeRangeHighlight)) {
      // Filter tasks that are not just highlights
      double startPos;
      double endPos;

      if (mode == TimelineMode.dateTime) {
        if (task.start == null || task.end == null) continue;
        startPos = valueToPos(task.start!.millisecondsSinceEpoch.toDouble());
        endPos = valueToPos(task.end!.millisecondsSinceEpoch.toDouble());
      } else {
        if (task.startLine == null || task.endLine == null) continue;
        startPos = valueToPos(task.startLine!.toDouble());
        endPos = valueToPos(task.endLine!.toDouble());
      }

      if (task.isOverlapIndicator) {
        taskPaint.color = theme.conflictBarColor;
      } else {
        taskPaint.color = (task.color ?? theme.barColorPrimary).withValues(alpha: 0.5);
      }

      final startRatio = task.startRatio ?? 0.25;
      final endRatio = task.endRatio ?? 0.75;

      if (orientation == Axis.horizontal) {
        canvas.drawRect(Rect.fromLTRB(startPos, size.height * startRatio, endPos, size.height * endRatio), taskPaint);
      } else {
        final left = size.width * startRatio;
        final right = size.width * endRatio;
        canvas.drawRect(Rect.fromLTRB(left, startPos, right, endPos), taskPaint);
      }
    }

    final visibleStartPos = valueToPos(visibleStartValue);
    final visibleEndPos = valueToPos(visibleEndValue);

    final windowPaint = Paint()..color = theme.scrubberWindowColor;
    final borderPaint = Paint()
      ..color = theme.scrubberWindowBorderColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final windowRect = orientation == Axis.horizontal
        ? Rect.fromLTRB(visibleStartPos, 0, visibleEndPos, size.height)
        : Rect.fromLTRB(0, visibleStartPos, size.width, visibleEndPos);

    canvas.drawRect(windowRect, windowPaint);
    canvas.drawRect(windowRect, borderPaint);

    if (mode != TimelineMode.lineCount) {
      final handlePaint = Paint()..color = theme.scrubberWindowBorderColor;
      const handleWidth = 4.0;

      final leftHandleRect = orientation == Axis.horizontal
          ? Rect.fromLTWH(visibleStartPos - handleWidth / 2, 0, handleWidth, size.height)
          : Rect.fromLTWH(0, visibleStartPos - handleWidth / 2, size.width, handleWidth);
      final rightHandleRect = orientation == Axis.horizontal
          ? Rect.fromLTWH(visibleEndPos - handleWidth / 2, 0, handleWidth, size.height)
          : Rect.fromLTWH(0, visibleEndPos - handleWidth / 2, size.width, handleWidth);

      canvas.drawRect(leftHandleRect, handlePaint);
      canvas.drawRect(rightHandleRect, handlePaint);
    }

    const fadeWidth = 20.0;

    if (displayStartValue > totalStartValue) {
      final leftFadeRect = orientation == Axis.horizontal
          ? Rect.fromLTWH(0, 0, fadeWidth, size.height)
          : Rect.fromLTWH(0, 0, size.width, fadeWidth);
      final leftGradient = orientation == Axis.horizontal
          ? LinearGradient(colors: [theme.textColor.withValues(alpha: 0.16), theme.textColor.withValues(alpha: 0)])
          : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.textColor.withValues(alpha: 0.16), theme.textColor.withValues(alpha: 0)],
            );
      canvas.drawRect(leftFadeRect, Paint()..shader = leftGradient.createShader(leftFadeRect));
    }

    if (displayEndValue < totalEndValue) {
      final rightFadeRect = orientation == Axis.horizontal
          ? Rect.fromLTWH(size.width - fadeWidth, 0, fadeWidth, size.height)
          : Rect.fromLTWH(0, size.height - fadeWidth, size.width, fadeWidth);
      final rightGradient = orientation == Axis.horizontal
          ? LinearGradient(colors: [theme.textColor.withValues(alpha: 0), theme.textColor.withValues(alpha: 0.16)])
          : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.textColor.withValues(alpha: 0), theme.textColor.withValues(alpha: 0.16)],
            );
      canvas.drawRect(rightFadeRect, Paint()..shader = rightGradient.createShader(rightFadeRect));
    }
  }

  @override
  bool shouldRepaint(covariant _ScrubberPainter oldDelegate) =>
      oldDelegate.mode != mode ||
      oldDelegate.totalStartValue != totalStartValue ||
      oldDelegate.totalEndValue != totalEndValue ||
      oldDelegate.displayStartValue != displayStartValue ||
      oldDelegate.displayEndValue != displayEndValue ||
      oldDelegate.visibleStartValue != visibleStartValue ||
      oldDelegate.visibleEndValue != visibleEndValue ||
      !listEquals(oldDelegate.tasks, tasks) ||
      oldDelegate.theme != theme ||
      oldDelegate.orientation != orientation;
}
