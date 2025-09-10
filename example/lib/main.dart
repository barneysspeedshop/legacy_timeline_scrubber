import 'package:flutter/material.dart';
import 'package:legacy_timeline_scrubber/legacy_timeline_scrubber.dart';
import 'package:provider/provider.dart';
import 'timeline_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => TimelineViewModel()..init(context),
      child: MaterialApp(
        title: 'Legacy Timeline Scrubber Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData.dark(),
        home: const MyHomePage(),
      ),
    );
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) => Consumer<TimelineViewModel>(
      builder: (context, viewModel, child) => Scaffold(
          appBar: AppBar(
            title: const Text('Legacy Timeline Scrubber Example'),
            actions: [
              Switch(
                value: viewModel.useCustomTheme,
                onChanged: (value) {
                  viewModel.setUseCustomTheme(value);
                },
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Use Custom Theme'),
              ),
            ],
          ),
          body: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                  'Visible Window: ${viewModel.visibleStartDate} - ${viewModel.visibleEndDate}'),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: LegacyGanttTimelineScrubber(
                  totalStartDate: viewModel.totalStartDate,
                  totalEndDate: viewModel.totalEndDate,
                  visibleStartDate: viewModel.visibleStartDate,
                  visibleEndDate: viewModel.visibleEndDate,
                  onWindowChanged: viewModel.onWindowChanged,
                  tasks: viewModel.tasks,
                  theme: viewModel.theme,
                ),
              ),
            ],
          ),
        ),
    );
}