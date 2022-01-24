import 'package:MazeRunner/channels.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _scenarioNameController = TextEditingController();
    _extraConfigController = TextEditingController();
    _notifyEndpointController = TextEditingController(
      text: 'http://bs-local.com:9339/notify',
    );
    _sessionEndpointController = TextEditingController(
      text: 'http://bs-local.com:9339/session',
    );
  }

  @override
  void dispose() {
    _scenarioNameController.dispose();
    _extraConfigController.dispose();
    _notifyEndpointController.dispose();
    _sessionEndpointController.dispose();

    super.dispose();
  }

  void _onStartBugsnag(BuildContext context) async {
    await MazeRunnerChannels.startBugsnag();
  }

  void _onStartScenario(BuildContext context) async {
    await _initScenario(context)?.run();
  }

  Scenario? _initScenario(BuildContext context) {
    final name = _scenarioNameController.value.text;
    final extraConfig = _extraConfigController.value.text;
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

    return scenarios[scenarioIndex].init(extraConfig);
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
              onPressed: () => _onStartBugsnag(context),
              key: const Key("startBugsnag"),
            ),
          ],
        ),
      ),
    );
  }
}
