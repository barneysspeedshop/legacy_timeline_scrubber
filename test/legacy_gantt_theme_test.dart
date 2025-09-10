import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legacy_timeline_scrubber/src/models/legacy_gantt_theme.dart';

void main() {
  group('LegacyGanttTheme', () {
    final requiredTheme = LegacyGanttTheme(
      barColorPrimary: Colors.blue,
      barColorSecondary: Colors.green,
      textColor: Colors.white,
      backgroundColor: Colors.black,
    );

    test('constructor assigns required properties correctly', () {
      expect(requiredTheme.barColorPrimary, Colors.blue);
      expect(requiredTheme.barColorSecondary, Colors.green);
      expect(requiredTheme.textColor, Colors.white);
      expect(requiredTheme.backgroundColor, Colors.black);
    });

    test('constructor applies default values correctly', () {
      expect(requiredTheme.gridColor, const Color(0x33888888));
      expect(requiredTheme.summaryBarColor, const Color(0x33000000));
      expect(requiredTheme.conflictBarColor, const Color(0x80F44336));
      expect(requiredTheme.ghostBarColor, const Color(0xB32196F3));
      expect(requiredTheme.taskTextStyle, const TextStyle(fontSize: 14, color: Colors.white));
      expect(requiredTheme.showRowBorders, isFalse);
      expect(requiredTheme.rowBorderColor, isNull);
      expect(requiredTheme.dependencyLineColor, const Color(0xFF616161));
      expect(requiredTheme.timeRangeHighlightColor, const Color(0x0D000000));
      expect(requiredTheme.containedDependencyBackgroundColor, const Color(0x1A000000));
      expect(requiredTheme.emptySpaceHighlightColor, const Color(0x0F2196F3));
      expect(requiredTheme.emptySpaceAddIconColor, const Color(0xFF2196F3));
      expect(requiredTheme.barHeightRatio, 0.7);
      expect(requiredTheme.barCornerRadius, const Radius.circular(4.0));
      expect(requiredTheme.scrubberBackgroundColor, const Color(0xFF303030));
      expect(requiredTheme.scrubberWindowColor, const Color(0x332196F3));
      expect(requiredTheme.scrubberWindowBorderColor, const Color(0xFF1976D2));
      // Test axisTextStyle default logic
      expect(requiredTheme.axisTextStyle, TextStyle(fontSize: 12, color: requiredTheme.textColor));
    });

    test('constructor uses provided axisTextStyle', () {
      const customTextStyle = TextStyle(fontSize: 16, color: Colors.red);
      final theme = LegacyGanttTheme(
        barColorPrimary: Colors.blue,
        barColorSecondary: Colors.green,
        textColor: Colors.white,
        backgroundColor: Colors.black,
        axisTextStyle: customTextStyle,
      );
      expect(theme.axisTextStyle, customTextStyle);
    });

    test('copyWith creates a new instance with updated values', () {
      final updatedTheme = requiredTheme.copyWith(
        barColorPrimary: Colors.red,
        textColor: Colors.yellow,
        barHeightRatio: 0.8,
        scrubberWindowColor: Colors.purple,
      );

      expect(updatedTheme.barColorPrimary, Colors.red);
      expect(updatedTheme.barColorSecondary, requiredTheme.barColorSecondary);
      expect(updatedTheme.textColor, Colors.yellow);
      expect(updatedTheme.backgroundColor, requiredTheme.backgroundColor);
      expect(updatedTheme.barHeightRatio, 0.8);
      expect(updatedTheme.scrubberWindowColor, Colors.purple);
    });

    test('copyWith with no changes returns an equivalent theme', () {
      final copiedTheme = requiredTheme.copyWith();

      expect(copiedTheme.barColorPrimary, requiredTheme.barColorPrimary);
      expect(copiedTheme.barColorSecondary, requiredTheme.barColorSecondary);
      expect(copiedTheme.textColor, requiredTheme.textColor);
      expect(copiedTheme.backgroundColor, requiredTheme.backgroundColor);
      expect(copiedTheme.gridColor, requiredTheme.gridColor);
      expect(copiedTheme.summaryBarColor, requiredTheme.summaryBarColor);
      expect(copiedTheme.conflictBarColor, requiredTheme.conflictBarColor);
      expect(copiedTheme.ghostBarColor, requiredTheme.ghostBarColor);
      expect(copiedTheme.axisTextStyle, requiredTheme.axisTextStyle);
      expect(copiedTheme.taskTextStyle, requiredTheme.taskTextStyle);
      expect(copiedTheme.dependencyLineColor, requiredTheme.dependencyLineColor);
      expect(copiedTheme.timeRangeHighlightColor, requiredTheme.timeRangeHighlightColor);
      expect(copiedTheme.containedDependencyBackgroundColor, requiredTheme.containedDependencyBackgroundColor);
      expect(copiedTheme.emptySpaceHighlightColor, requiredTheme.emptySpaceHighlightColor);
      expect(copiedTheme.emptySpaceAddIconColor, requiredTheme.emptySpaceAddIconColor);
      expect(copiedTheme.barHeightRatio, requiredTheme.barHeightRatio);
      expect(copiedTheme.barCornerRadius, requiredTheme.barCornerRadius);
      expect(copiedTheme.showRowBorders, requiredTheme.showRowBorders);
      expect(copiedTheme.rowBorderColor, requiredTheme.rowBorderColor);
      expect(copiedTheme.scrubberBackgroundColor, requiredTheme.scrubberBackgroundColor);
      expect(copiedTheme.scrubberWindowColor, requiredTheme.scrubberWindowColor);
      expect(copiedTheme.scrubberWindowBorderColor, requiredTheme.scrubberWindowBorderColor);
    });

    group('fromTheme factory', () {
      test('creates a theme from ThemeData with text styles', () {
        final materialTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          textTheme: const TextTheme(
            bodySmall: TextStyle(fontSize: 10, color: Colors.grey),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
          ),
        );

        final ganttTheme = LegacyGanttTheme.fromTheme(materialTheme);

        expect(ganttTheme.barColorPrimary, materialTheme.colorScheme.primary);
        expect(ganttTheme.barColorSecondary, materialTheme.colorScheme.secondary);
        expect(ganttTheme.textColor, materialTheme.colorScheme.onSurface);
        expect(ganttTheme.backgroundColor, materialTheme.colorScheme.surface);
        expect(ganttTheme.gridColor, materialTheme.colorScheme.onSurface.withValues(alpha: 0.2));
        expect(ganttTheme.ghostBarColor, materialTheme.colorScheme.primary.withValues(alpha: 0.7));
        expect(ganttTheme.axisTextStyle, materialTheme.textTheme.bodySmall);
        expect(ganttTheme.taskTextStyle,
            materialTheme.textTheme.bodyMedium?.copyWith(color: materialTheme.colorScheme.onPrimary));
        expect(ganttTheme.scrubberBackgroundColor, materialTheme.colorScheme.surfaceContainerHighest);
        expect(ganttTheme.scrubberWindowColor, materialTheme.colorScheme.primaryContainer.withValues(alpha: 0.2));
        expect(ganttTheme.scrubberWindowBorderColor, materialTheme.colorScheme.primary);
      });

      test('uses default ThemeData text styles when none are provided in TextTheme', () {
        final materialTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          textTheme: const TextTheme(bodySmall: null, bodyMedium: null),
        );

        final ganttTheme = LegacyGanttTheme.fromTheme(materialTheme);

        // ThemeData populates null text styles with defaults.
        // The fromTheme factory should use these defaults.
        // The default for bodySmall has a fontSize of 12.
        expect(ganttTheme.axisTextStyle.fontSize, 12);
        expect(ganttTheme.axisTextStyle.color, materialTheme.colorScheme.onSurface);

        // The default for bodyMedium has a fontSize of 14.
        expect(ganttTheme.taskTextStyle.fontSize, 14);
        expect(ganttTheme.taskTextStyle.color, materialTheme.colorScheme.onPrimary);
      });
    });
  });
}
