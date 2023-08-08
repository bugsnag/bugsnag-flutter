// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:MazeRunner/channels.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'scenarios/scenario.dart';
import 'scenarios/scenarios.dart';

void log(String message) {
  print('[MazeRunner] $message');
}

void main() {
  runApp(const MazeRunnerFlutterApp());
}

extension StringGet<K, V> on Map<K, V> {
  String? string(K key) {
    final value = this[key];
    return value is String ? value : null;
  }
}

/// Represents a MazeRunner command
class Command {
  final String action;
  final String scenarioName;
  final String extraConfig;

  const Command({
    required this.action,
    required this.scenarioName,
    required this.extraConfig,
  });

  factory Command.fromJsonString(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    if (map['action'] == null) {
      throw Exception('MazeRunner commands must have an action');
    }
    return Command(
      action: map.string('action')!,
      scenarioName: map.string('scenario_name') ?? '',
      extraConfig: map.string('extra_config') ?? '',
    );
  }
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
      home: FutureBuilder<String>(
        future: Future(() async {
          for (var i = 0; i < 30; i++) {
            try {
              final Directory directory = await appFilesDirectory();
              final File file = File('${directory.path.replaceAll('app_flutter', 'files')}/fixture_config.json');
              final text = await file.readAsString();
              print("fixture_config.json found with contents: $text");
              Map<String, dynamic> json = jsonDecode(text);
              if (json.containsKey('maze_address')) {
                print("fixture_config.json found with contents: $text");
                return json['maze_address'];
              }
            } catch (e) {
              print("Couldn't read fixture_config.json: $e");
            }
            await Future.delayed(const Duration(seconds: 1));
          }
          print("fixture_config.json not read within 30s, defaulting to BrowserStack address");
          return 'bs-local.com:9339';
        }),
        builder: (_, mazerunnerUrl) {
          if (mazerunnerUrl.data != null) {
            return MazeRunnerHomePage(mazerunnerUrl: mazerunnerUrl.data!,);
          } else {
            return Container(color: Colors.white, child: const Center(child: CircularProgressIndicator()));
          }
      }),
    );
  }

  Future<Directory> appFilesDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

}

class MazeRunnerHomePage extends StatefulWidget {
  final String mazerunnerUrl;
  const MazeRunnerHomePage({Key? key, required this.mazerunnerUrl,}) : super(key: key);

  @override
  State<MazeRunnerHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<MazeRunnerHomePage> {
  late TextEditingController _scenarioNameController;
  late TextEditingController _extraConfigController;
  late TextEditingController _commandEndpointController;
  late TextEditingController _notifyEndpointController;
  late TextEditingController _sessionEndpointController;
  bool didTapRunCommand = false;

  @override
  void initState() {
    super.initState();
    _scenarioNameController = TextEditingController();
    _extraConfigController = TextEditingController();
    _commandEndpointController = TextEditingController(
      text: 'http://${widget.mazerunnerUrl}/command',
    );
    _notifyEndpointController = TextEditingController(
      text: 'http://${widget.mazerunnerUrl}/notify',
    );
    _sessionEndpointController = TextEditingController(
      text: 'http://${widget.mazerunnerUrl}/sessions',
    );
  }

  @override
  void dispose() {
    _scenarioNameController.dispose();
    _extraConfigController.dispose();
    _commandEndpointController.dispose();
    _notifyEndpointController.dispose();
    _sessionEndpointController.dispose();

    super.dispose();
  }

  /// Fetches the next command
  void _onRunCommand(BuildContext context) async {
    setState(() {
      didTapRunCommand = true;
    });
    log('Fetching the next command');
    final commandUrl = _commandEndpointController.value.text;
    final commandStr = await MazeRunnerChannels.getCommand(commandUrl);
    log('The command is: $commandStr');

    final command = Command.fromJsonString(commandStr);
    _scenarioNameController.text = command.scenarioName;
    _extraConfigController.text = command.extraConfig;

    switch (command.action) {
      case 'start_bugsnag':
        _onStartBugsnag();
        break;

      case 'run_scenario':
        _onRunScenario(context);
        break;
    }
  }

  /// Starts Bugsnag
  Future<void> _onStartBugsnag() async {
    log('Starting Bugsnag');
    await bugsnag.start(endpoints: _endpoints());
  }

  /// Runs a scenario, starting bugsnag first
  void _onRunScenario(BuildContext context) async {
    final scenario = _initScenario(context);
    if (scenario == null) {
      return;
    }

    await scenario.clearPersistentData();

    scenario.endpoints = _endpoints();
    scenario.extraConfig = _extraConfigController.value.text;

    Widget? scenarioWidget = scenario.createWidget();
    if (scenarioWidget != null) {
      log('Mounting Scenario Widget');
      final route = MaterialPageRoute(builder: (context) => scenarioWidget);
      Navigator.push(context, route);
      await route.didPush();
    }

    log('Running scenario');
    await scenario.run();
  }

  /// Initializes a scenario
  Scenario? _initScenario(BuildContext context) {
    final name = _scenarioNameController.value.text;
    log('Initializing scenario: $name');
    final scenarioIndex =
        scenarios.indexWhere((element) => element.name == name);

    if (scenarioIndex == -1) {
      log('Cannot find Scenario $name. Has it been added to scenarios.dart?');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot find Scenario $name. Has it been added to scenarios.dart?',
          ),
        ),
      );

      return null;
    }

    return scenarios[scenarioIndex].init();
  }

  BugsnagEndpointConfiguration _endpoints() => BugsnagEndpointConfiguration(
        _notifyEndpointController.value.text,
        _sessionEndpointController.value.text,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 400.0,
                  width: double.infinity,
                  color: didTapRunCommand ? Colors.blue : Colors.yellow,
                  child: TextButton(
                    child: const Text("Run Command"),
                    onPressed: () => _onRunCommand(context),
                    key: const Key("runCommand"),
                  )),
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
                controller: _commandEndpointController,
                key: const Key("commandEndpoint"),
                decoration: const InputDecoration(
                  label: Text("Command Endpoint"),
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
                child: const Text("Start Bugsnag"),
                onPressed: _onStartBugsnag,
                key: const Key("startBugsnag"),
              ),
              TextButton(
                child: const Text("Run Scenario"),
                onPressed: () => _onRunScenario(context),
                key: const Key("startScenario"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
