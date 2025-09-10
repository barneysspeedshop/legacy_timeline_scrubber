
import 'package:flutter/material.dart';
import 'package:legacy_timeline_scrubber/legacy_timeline_scrubber.dart';

class TimelineViewModel extends ChangeNotifier {
  late DateTime _totalStartDate;
  late DateTime _totalEndDate;
  late DateTime _visibleStartDate;
  late DateTime _visibleEndDate;
  final List<LegacyGanttTask> _tasks = [];
  bool _useCustomTheme = false;
  late LegacyGanttTheme _customTheme;
  late LegacyGanttTheme _defaultTheme;

  DateTime get totalStartDate => _totalStartDate;
  DateTime get totalEndDate => _totalEndDate;
  DateTime get visibleStartDate => _visibleStartDate;
  DateTime get visibleEndDate => _visibleEndDate;
  List<LegacyGanttTask> get tasks => _tasks;
  bool get useCustomTheme => _useCustomTheme;

  LegacyGanttTheme get theme =>
      _useCustomTheme ? _customTheme : _defaultTheme;

  TimelineViewModel() {
    final now = DateTime.now();
    _totalStartDate = now.subtract(const Duration(days: 10));
    _totalEndDate = now.add(const Duration(days: 10));
    _visibleStartDate = now.subtract(const Duration(days: 2));
    _visibleEndDate = now.add(const Duration(days: 2));

    _tasks.addAll([
      LegacyGanttTask(
        id: '1',
        rowId: 'row1',
        start: now.subtract(const Duration(days: 5)),
        end: now.subtract(const Duration(days: 3)),
        name: 'Task 1',
        color: Colors.blue,
      ),
      LegacyGanttTask(
        id: '2',
        rowId: 'row1',
        start: now.subtract(const Duration(days: 2)),
        end: now.add(const Duration(days: 1)),
        name: 'Task 2',
        color: Colors.green,
      ),
      LegacyGanttTask(
        id: '3',
        rowId: 'row2',
        start: now.add(const Duration(days: 2)),
        end: now.add(const Duration(days: 5)),
        name: 'Task 3',
        color: Colors.orange,
      ),
    ]);

    _customTheme = LegacyGanttTheme(
      barColorPrimary: Colors.red,
      barColorSecondary: Colors.yellow,
      textColor: Colors.white,
      backgroundColor: Colors.grey.shade800,
      scrubberBackgroundColor: Colors.grey.shade900,
      scrubberWindowColor: Colors.red.withAlpha(51),
      scrubberWindowBorderColor: Colors.red,
    );
  }

  void init(BuildContext context) {
    _defaultTheme = LegacyGanttTheme.fromTheme(Theme.of(context));
  }

  void onWindowChanged(DateTime start, DateTime end) {
    _visibleStartDate = start;
    _visibleEndDate = end;
    notifyListeners();
  }

  void setUseCustomTheme(bool value) {
    _useCustomTheme = value;
    notifyListeners();
  }
}
