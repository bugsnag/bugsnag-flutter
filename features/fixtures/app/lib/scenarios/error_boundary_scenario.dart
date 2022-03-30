import 'dart:async';

import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/widgets.dart';
import 'package:flutter/material.dart';

class ErrorBoundaryWidgetScenario extends Scenario {
  // we use this to actually trigger a build() failure *after* our widget is mounted
  final _completer = Completer<bool>();

  @override
  Future<void> run() async {
    await startBugsnag();
    _completer.complete(true);
  }

  @override
  Widget? createWidget() {
    return _ErrorBoundaryScenarioScreen(_completer.future);
  }
}

class _ErrorBoundaryScenarioScreen extends StatelessWidget {
  final Future<bool> triggerError;

  const _ErrorBoundaryScenarioScreen(this.triggerError, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text('Outside the ErrorBoundary'),
            ErrorBoundary(
              child: BuildErrorWidget(triggerError),
              fallback: (context) => const Text('Fallback Widget'),
              errorContext: 'ErrorBoundary 1',
            ),
          ],
        ),
      ),
    );
  }
}

class BuildErrorWidget extends StatefulWidget {
  final Future<bool> triggerError;

  const BuildErrorWidget(this.triggerError, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BuildErrorWidgetState();
}

class _BuildErrorWidgetState extends State<BuildErrorWidget> {
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    widget.triggerError.then(
      (value) {
        setState(() => _isError = value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isError) {
      return ElevatedButton(
        onPressed: _setErrorState,
        child: const Text('Throw Error from Widget.build()'),
      );
    } else {
      throw Exception('I am a very bad widget.');
    }
  }

  void _setErrorState() {
    setState(() => _isError = true);
  }
}
