import 'dart:async';

import 'package:MazeRunner/channels.dart';
import 'package:flutter/material.dart';

import 'packages.dart';
import 'scenarios/scenario.dart';
import 'scenarios/scenarios.dart';

void main() {
  runApp(const MazeRunnerFlutterApp());
}

class MazeRunnerFlutterApp extends StatelessWidget {
  const MazeRunnerFlutterApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bugsnag Test',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 73, 73, 227),
      ),
      home: const MazeRunnerHomePage(),
    );
  }
}

class MazeRunnerHomePage extends StatefulWidget {
  const MazeRunnerHomePage({Key? key}) : super(key: key);

  @override
  State<MazeRunnerHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<MazeRunnerHomePage> {
  late TextEditingController _scenarioNameController;
  late TextEditingController _extraConfigController;
  late TextEditingController _notifyEndpointController;
  late TextEditingController _sessionEndpointController;

  List<String> _packages = const [];

  @override
  void initState() {
    super.initState();
    _scenarioNameController = TextEditingController();
    _extraConfigController = TextEditingController();
    _notifyEndpointController = TextEditingController(
      text: const String.fromEnvironment(
        'bsg.endpoint.notify',
        defaultValue: 'http://bs-local.com:9339/notify',
      ),
    );
    _sessionEndpointController = TextEditingController(
      text: const String.fromEnvironment(
        'bsg.endpoint.session',
        defaultValue: 'http://bs-local.com:9339/session',
      ),
    );

    listPackages().then((value) {
      setState(() {
        _packages = value;
      });
    });
  }

  @override
  void dispose() {
    _scenarioNameController.dispose();
    _extraConfigController.dispose();
    _notifyEndpointController.dispose();
    _sessionEndpointController.dispose();

    super.dispose();
  }

  Future<void> _onStartBugsnag() async {
    final notifyEndpoint = _notifyEndpointController.value.text;
    final sessionEndpoint = _sessionEndpointController.value.text;

    await MazeRunnerChannels.startBugsnag(
      notifyEndpoint: notifyEndpoint,
      sessionEndpoint: sessionEndpoint,
    );
  }

  void _onStartScenario(BuildContext context) async {
    final scenario = _initScenario(context);
    if (scenario == null) {
      return;
    }

    final extraConfig = _extraConfigController.value.text;
    scenario.extraConfig = extraConfig;
    scenario.startBugsnag = _onStartBugsnag;
    await scenario.run();
  }

  Scenario? _initScenario(BuildContext context) {
    final name = _scenarioNameController.value.text;
    final scenarioIndex =
        scenarios.indexWhere((element) => element.name == name);

    if (scenarioIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot find Scenario $name. "
              "Has is been added to scenario.dart?"),
        ),
      );

      return null;
    }

    return scenarios[scenarioIndex].init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugsnag Test Fixture'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _scenarioNameController,
              key: const Key("scenarioName"),
              decoration: const InputDecoration(
                label: Text("Scenario Name"),
              ),
            ),
            TextField(
              controller: _extraConfigController,
              key: const Key("extraConfig"),
              decoration: const InputDecoration(
                label: Text("Extra Config"),
              ),
            ),
            TextField(
              controller: _notifyEndpointController,
              key: const Key("notifyEndpoint"),
              decoration: const InputDecoration(
                label: Text("Notify Endpoint"),
              ),
            ),
            TextField(
              controller: _sessionEndpointController,
              key: const Key("sessionEndpoint"),
              decoration: const InputDecoration(
                label: Text("Session Endpoint"),
              ),
            ),
            TextButton(
              child: const Text("Start Scenario"),
              onPressed: () => _onStartScenario(context),
              key: const Key("startScenario"),
            ),
            TextButton(
              child: const Text("Start Bugsnag"),
              onPressed: _onStartBugsnag,
              key: const Key("startBugsnag"),
            ),
            ListView(
              children: _packages.map((e) => Text("package: $e")).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
