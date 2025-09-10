# Legacy Timeline Scrubber

[![Pub Version](https://img.shields.io/pub/v/legacy_timeline_scrubber)](https://pub.dev/packages/legacy_timeline_scrubber)
[![Test Coverage](https://img.shields.io/badge/coverage-96%25-brightgreen)
[![Live Demo](https://img.shields.io/badge/live-demo-brightgreen)](https://barneysspeedshop.github.io/legacy_timeline_scrubber/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter widget that provides a timeline scrubber for a Gantt chart. It allows you to visualize tasks and navigate through a timeline.

---

## About the Name

The name `legacy_timeline_scrubber` is a tribute to the package's author, Patrick Legacy. It does not imply that the package is outdated or unmaintained. In fact, it is a modern, actively developed, and highly capable solution for building production-ready Flutter applications.

---

![example](https://raw.githubusercontent.com/barneysspeedshop/legacy_timeline_scrubber/main/example.gif)

---

## Features

*   Display tasks on a timeline.
*   Scrub through the timeline to change the visible date range.
*   Customize the appearance of the scrubber and tasks.
*   Zoom in and out of the timeline.

## Getting started

To use this package, add `legacy_timeline_scrubber` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  legacy_timeline_scrubber: ^1.0.0
```

## Usage

Here is a simple example of how to use the `LegacyGanttTimelineScrubber` widget:

```dart
import 'package:flutter/material.dart';
import 'package:legacy_timeline_scrubber/legacy_timeline_scrubber.dart';
import 'package:legacy_timeline_scrubber/src/models/legacy_gantt_task.dart';

class MyTimeline extends StatefulWidget {
  @override
  _MyTimelineState createState() => _MyTimelineState();
}

class _MyTimelineState extends State<MyTimeline> {
  late DateTime totalStartDate;
  late DateTime totalEndDate;
  late DateTime visibleStartDate;
  late DateTime visibleEndDate;
  final List<LegacyGanttTask> tasks = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    totalStartDate = now.subtract(const Duration(days: 10));
    totalEndDate = now.add(const Duration(days: 10));
    visibleStartDate = now.subtract(const Duration(days: 2));
    visibleEndDate = now.add(const Duration(days: 2));

    tasks.addAll([
      LegacyGanttTask(
        id: '1',
        rowId: 'row1',
        start: now.subtract(const Duration(days: 5)),
        end: now.subtract(const Duration(days: 3)),
        name: 'Task 1',
      ),
    ]);
  }

  void onWindowChanged(DateTime start, DateTime end) {
    setState(() {
      visibleStartDate = start;
      visibleEndDate = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: LegacyGanttTimelineScrubber(
        totalStartDate: totalStartDate,
        totalEndDate: totalEndDate,
        visibleStartDate: visibleStartDate,
        visibleEndDate: visibleEndDate,
        onWindowChanged: onWindowChanged,
        tasks: tasks,
      ),
    );
  }
}
```

## Example Project

This package includes an example project that demonstrates the features of the `LegacyGanttTimelineScrubber`.

To run the example project:

1.  Clone the repository.
2.  Navigate to the `example` directory:

    ```bash
    cd example
    ```

3.  Get the dependencies:

    ```bash
    flutter pub get
    ```

4.  Run the app:

    ```bash
    flutter run
    ```

## Additional information

This package is currently under development. Contributions are welcome. Please file any issues or feature requests on the GitHub repository.