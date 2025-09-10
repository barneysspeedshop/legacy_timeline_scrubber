import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'models/legacy_gantt_task.dart';
import 'models/legacy_gantt_theme.dart';

enum _DragType { none, leftHandle, rightHandle, window }

/// A widget that displays a timeline scrubber for a Gantt chart.
class LegacyGanttTimelineScrubber extends StatefulWidget {
  /// The total start date of the timeline.
  final DateTime totalStartDate;

  /// The total end date of the timeline.
  final DateTime totalEndDate;

  /// The start date of the visible window.
  final DateTime visibleStartDate;

  /// The end date of the visible window.
  final DateTime visibleEndDate;

  /// A callback that is called when the visible window changes.
  final Function(DateTime, DateTime) onWindowChanged;

  /// The tasks to display in the timeline.
  final List<LegacyGanttTask> tasks;

  /// The theme to use for the timeline.
  final LegacyGanttTheme? theme;

  /// The padding to add to the start of the timeline.
  final Duration startPadding;

  /// The padding to add to the end of the timeline.
  final Duration endPadding;

  /// The rows that are visible in the timeline.
  final List<String>? visibleRows;

  /// The maximum stack depth for each row.
  final Map<String, int>? rowMaxStackDepth;

  /// The height of each row.
  final double? rowHeight;

  /// Creates a new [LegacyGanttTimelineScrubber].
  const LegacyGanttTimelineScrubber({
    super.key,
    required this.totalStartDate,
    required this.totalEndDate,
    required this.visibleStartDate,
    required this.visibleEndDate,
    required this.onWindowChanged,
    this.tasks = const [],
    this.theme,
    this.startPadding = Duration.zero,
    this.endPadding = Duration.zero,
    this.visibleRows,
    this.rowMaxStackDepth,
    this.rowHeight,
  });

  @override
  State<LegacyGanttTimelineScrubber> createState() => _LegacyGanttTimelineScrubberState();
}

class _LegacyGanttTimelineScrubberState extends State<LegacyGanttTimelineScrubber> {
  _DragType _dragType = _DragType.none;
  double _dragStartDx = 0.0;
  late DateTime _dragStartVisibleStart;
  late DateTime _dragStartVisibleEnd;
  late DateTime _dragStartDisplayStart;
  late DateTime _dragStartDisplayEnd;
  MouseCursor _cursor = SystemMouseCursors.basic;

  DateTime get _effectiveTotalStart => widget.totalStartDate.subtract(widget.startPadding);
  DateTime get _effectiveTotalEnd => widget.totalEndDate.add(widget.endPadding);

  (DateTime, DateTime) _calculateDisplayRange(DateTime visibleStart, DateTime visibleEnd, double width) {
    final visibleDuration = visibleEnd.difference(visibleStart);
    final totalDuration = _effectiveTotalEnd.difference(_effectiveTotalStart);

    if (visibleDuration >= totalDuration) {
      return (_effectiveTotalStart, _effectiveTotalEnd);
    }

    final bufferDuration = Duration(milliseconds: (visibleDuration.inMilliseconds * 0.25).round());

    DateTime displayStart = visibleStart.subtract(bufferDuration);
    DateTime displayEnd = visibleEnd.add(bufferDuration);

    if (displayStart.isBefore(_effectiveTotalStart)) {
      displayStart = _effectiveTotalStart;
    }
    if (displayEnd.isAfter(_effectiveTotalEnd)) {
      displayEnd = _effectiveTotalEnd;
    }

    if (displayEnd.difference(displayStart) < visibleDuration) {
      if (displayStart == _effectiveTotalStart) {
        displayEnd = displayStart.add(visibleDuration);
      } else if (displayEnd == _effectiveTotalEnd) {
        displayStart = displayEnd.subtract(visibleDuration);
      }
    }

    if (displayEnd.isAfter(_effectiveTotalEnd)) {
      displayEnd = _effectiveTotalEnd;
    }
    if (displayStart.isBefore(_effectiveTotalStart)) {
      displayStart = _effectiveTotalStart;
    }

    return (displayStart, displayEnd);
  }

  _DragType _getDragTypeAtPosition(Offset localPosition, double width) {
    if (width == 0) return _DragType.none;

    final (displayStart, displayEnd) = _calculateDisplayRange(widget.visibleStartDate, widget.visibleEndDate, width);
    final displayDurationMs = displayEnd.difference(displayStart).inMilliseconds;
    if (displayDurationMs <= 0) return _DragType.none;

    final double startX = (widget.visibleStartDate.difference(displayStart).inMilliseconds / displayDurationMs) * width;
    final double endX = (widget.visibleEndDate.difference(displayStart).inMilliseconds / displayDurationMs) * width;

    const handleHitWidth = 20.0;
    if ((localPosition.dx - startX).abs() < handleHitWidth) {
      return _DragType.leftHandle;
    } else if ((localPosition.dx - endX).abs() < handleHitWidth) {
      return _DragType.rightHandle;
    } else if (localPosition.dx > startX && localPosition.dx < endX) {
      return _DragType.window;
    } else {
      return _DragType.none;
    }
  }

  void _onHover(PointerEvent event, double width) {
    final dragType = _getDragTypeAtPosition(event.localPosition, width);
    MouseCursor newCursor;
    switch (dragType) {
      case _DragType.leftHandle:
      case _DragType.rightHandle:
        newCursor = SystemMouseCursors.resizeLeftRight;
        break;
      case _DragType.window:
        newCursor = SystemMouseCursors.move;
        break;
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

  void _onPanStart(DragStartDetails details, double width) {
    _dragType = _getDragTypeAtPosition(details.localPosition, width);

    if (_dragType != _DragType.none) {
      _dragStartDx = details.localPosition.dx;
      _dragStartVisibleStart = widget.visibleStartDate;
      _dragStartVisibleEnd = widget.visibleEndDate;

      final (displayStart, displayEnd) = _calculateDisplayRange(widget.visibleStartDate, widget.visibleEndDate, width);
      _dragStartDisplayStart = displayStart;
      _dragStartDisplayEnd = displayEnd;
    }
  }

  void _onPanUpdate(DragUpdateDetails details, double width) {
    if (_dragType == _DragType.none) return;

    final dragDisplayDuration = _dragStartDisplayEnd.difference(_dragStartDisplayStart);
    if (dragDisplayDuration.inMilliseconds <= 0) return;

    final dx = details.localPosition.dx - _dragStartDx;
    final dDuration = Duration(milliseconds: (dx / width * dragDisplayDuration.inMilliseconds).round());

    DateTime newVisibleStart = _dragStartVisibleStart;
    DateTime newVisibleEnd = _dragStartVisibleEnd;

    switch (_dragType) {
      case _DragType.leftHandle:
        newVisibleStart = _dragStartVisibleStart.add(dDuration);
        break;
      case _DragType.rightHandle:
        newVisibleEnd = _dragStartVisibleEnd.add(dDuration);
        break;
      case _DragType.window:
        newVisibleStart = _dragStartVisibleStart.add(dDuration);
        newVisibleEnd = _dragStartVisibleEnd.add(dDuration);
        break;
      case _DragType.none:
        return;
    }

    const minWindowDuration = Duration(hours: 1);
    if (newVisibleEnd.difference(newVisibleStart) < minWindowDuration) {
      if (_dragType == _DragType.leftHandle) {
        newVisibleStart = newVisibleEnd.subtract(minWindowDuration);
      } else {
        newVisibleEnd = newVisibleStart.add(minWindowDuration);
      }
    }

    if (newVisibleStart.isBefore(_effectiveTotalStart)) {
      final correction = _effectiveTotalStart.difference(newVisibleStart);
      newVisibleStart = _effectiveTotalStart;
      if (_dragType == _DragType.window) {
        newVisibleEnd = newVisibleEnd.add(correction);
      }
    }

    if (newVisibleEnd.isAfter(_effectiveTotalEnd)) {
      final correction = _effectiveTotalEnd.difference(newVisibleEnd);
      newVisibleEnd = _effectiveTotalEnd;
      if (_dragType == _DragType.window) {
        newVisibleStart = newVisibleStart.add(correction);
      }
    }

    newVisibleStart = newVisibleStart.isBefore(_effectiveTotalStart) ? _effectiveTotalStart : newVisibleStart;
    newVisibleEnd = newVisibleEnd.isAfter(_effectiveTotalEnd) ? _effectiveTotalEnd : newVisibleEnd;
    if (newVisibleEnd.isBefore(newVisibleStart)) {
      newVisibleEnd = newVisibleStart.add(minWindowDuration);
    }
    widget.onWindowChanged(newVisibleStart, newVisibleEnd);
  }

  void _onPanEnd(DragEndDetails details) => _dragType = _DragType.none;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? LegacyGanttTheme.fromTheme(Theme.of(context));
    return LayoutBuilder(
      builder: (context, constraints) {
        final (displayStart, displayEnd) = _calculateDisplayRange(
          widget.visibleStartDate,
          widget.visibleEndDate,
          constraints.maxWidth,
        );

        final totalDuration = _effectiveTotalEnd.difference(_effectiveTotalStart);
        final isZoomed = displayEnd.difference(displayStart).inMicroseconds < totalDuration.inMicroseconds;

        return Stack(
          alignment: Alignment.centerRight,
          children: [
            MouseRegion(
              cursor: _cursor,
              onHover: (e) => _onHover(e, constraints.maxWidth),
              onExit: _onExit,
              child: GestureDetector(
                onPanStart: (d) => _onPanStart(d, constraints.maxWidth),
                onPanUpdate: (d) => _onPanUpdate(d, constraints.maxWidth),
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: _ScrubberPainter(
                    totalStartDate: _effectiveTotalStart,
                    totalEndDate: _effectiveTotalEnd,
                    displayStartDate: displayStart,
                    displayEndDate: displayEnd,
                    visibleStartDate: widget.visibleStartDate,
                    visibleEndDate: widget.visibleEndDate,
                    tasks: widget.tasks,
                    theme: theme,
                  ),
                  size: Size.fromHeight(constraints.maxHeight),
                ),
              ),
            ),
            if (isZoomed)
              IconButton(
                padding: const EdgeInsets.only(right: 8.0),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.zoom_out_map),
                iconSize: 20.0,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                tooltip: 'Reset Zoom',
                onPressed: () => widget.onWindowChanged(_effectiveTotalStart, _effectiveTotalEnd),
              ),
          ],
        );
      },
    );
  }
}

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
    final displayDurationMs = displayEndDate.difference(displayStartDate).inMilliseconds;
    if (displayDurationMs <= 0) return;

    double dateToX(DateTime date) {
      if (date.isBefore(displayStartDate)) return 0.0;
      if (date.isAfter(displayEndDate)) return size.width;
      final dateDurationMs = date.difference(displayStartDate).inMilliseconds;
      return (dateDurationMs / displayDurationMs) * size.width;
    }

    final taskPaint = Paint();
    for (final task in tasks.where((t) => !t.isTimeRangeHighlight)) {
      final startX = dateToX(task.start);
      final endX = dateToX(task.end);

      if (task.isOverlapIndicator) {
        taskPaint.color = theme.conflictBarColor;
      } else {
        taskPaint.color = (task.color ?? theme.barColorPrimary).withValues(alpha: 0.5);
      }

      canvas.drawRect(
        Rect.fromLTRB(startX, size.height * 0.25, endX, size.height * 0.75),
        taskPaint,
      );
    }

    final visibleStartX = dateToX(visibleStartDate);
    final visibleEndX = dateToX(visibleEndDate);

    final windowPaint = Paint()..color = theme.scrubberWindowColor;
    final borderPaint = Paint()
      ..color = theme.scrubberWindowBorderColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final windowRect = Rect.fromLTRB(visibleStartX, 0, visibleEndX, size.height);
    canvas.drawRect(windowRect, windowPaint);
    canvas.drawRect(windowRect, borderPaint);

    final handlePaint = Paint()..color = theme.scrubberWindowBorderColor;
    const handleWidth = 4.0;
    final leftHandleRect = Rect.fromLTWH(visibleStartX - handleWidth / 2, 0, handleWidth, size.height);
    final rightHandleRect = Rect.fromLTWH(visibleEndX - handleWidth / 2, 0, handleWidth, size.height);

    canvas.drawRect(leftHandleRect, handlePaint);
    canvas.drawRect(rightHandleRect, handlePaint);

    const fadeWidth = 20.0;
    final shadowColor = theme.textColor.withValues(alpha: 0.16);

    if (displayStartDate.isAfter(totalStartDate)) {
      final leftFadeRect = Rect.fromLTWH(0, 0, fadeWidth, size.height);
      final leftGradient = LinearGradient(
        colors: [shadowColor, shadowColor.withValues(alpha: 0)],
      );
      canvas.drawRect(leftFadeRect, Paint()..shader = leftGradient.createShader(leftFadeRect));
    }

    if (displayEndDate.isBefore(totalEndDate)) {
      final rightFadeRect = Rect.fromLTWH(size.width - fadeWidth, 0, fadeWidth, size.height);
      final rightGradient = LinearGradient(colors: [shadowColor.withValues(alpha: 0), shadowColor]);
      canvas.drawRect(rightFadeRect, Paint()..shader = rightGradient.createShader(rightFadeRect));
    }
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
