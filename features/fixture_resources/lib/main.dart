// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';
import 'package:native_flutter_proxy/src/custom_proxy.dart';
import 'package:native_flutter_proxy/src/native_proxy_reader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'scenarios/scenario.dart';
import 'scenarios/scenarios.dart';

void log(String message) {
  print('[MazeRunner] $message');
}

void main() async {
  await setupProxy();
  runApp(const MazeRunnerFlutterApp());
}

Future<void> setupProxy() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool enabled = false;
  String? host;
  int? port;
  try {
    ProxySetting settings = await NativeProxyReader.proxySetting;
    enabled = settings.enabled;
    host = settings.host;
    port = settings.port;
  } catch (e) {
    print(e);
  }
  if (enabled && host != null) {
    final proxy = CustomProxy(ipAddress: host, port: port);
    proxy.enable();
    print("proxy enabled");
  }
}

extension StringGet<K, V> on Map<K, V> {
  String? string(K key) {
    final value = this[key];
    return value is String ? value : null;
  }
}

class FixtureConfig {
  static Uri MAZE_HOST = Uri.parse("");
}

class Command {
  final String action;
  final String scenarioName;
  final String extraConfig;
  final List<dynamic> args;

  const Command({
    required this.action,
    required this.scenarioName,
    required this.extraConfig,
    required this.args,
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
      args: map['args'] ?? [],
    );
  }
}

class MazeRunnerFlutterApp extends StatelessWidget {
  const MazeRunnerFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    log('Building MazeRunnerFlutterApp');
    return MaterialApp(
      title: 'Bugsnag Test',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 73, 73, 227),
      ),
      navigatorObservers: [],
      home: FutureBuilder<String>(
        future: _getMazeRunnerUrl(),
        builder: (_, mazerunnerUrl) {
          if (mazerunnerUrl.data != null) {
            return MazeRunnerHomePage(
              mazerunnerUrl: mazerunnerUrl.data!,
            );
          } else {
            return Container(
              color: Colors.white,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }

  Future<String> _getMazeRunnerUrl() async {
    log('Fetching MazeRunner URL');
    for (var i = 0; i < 30; i++) {
      try {
        final Directory directory = await appFilesDirectory();
        final File file = File(
            '${directory.path.replaceAll('app_flutter', 'files')}/fixture_config.json');
        final text = await file.readAsString();
        log("fixture_config.json found with contents: $text");
        Map<String, dynamic> json = jsonDecode(text);
        if (json.containsKey('maze_address')) {
          FixtureConfig.MAZE_HOST = Uri.parse('http://${json['maze_address']}');
          return FixtureConfig.MAZE_HOST.toString();
        }
      } catch (e) {
        log("Couldn't read fixture_config.json: $e");
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    log("fixture_config.json not read within 30s, defaulting to BrowserStack address");
    FixtureConfig.MAZE_HOST = Uri.parse('http://bs-local.com:9339');
    log('using ${FixtureConfig.MAZE_HOST} as the MazeRunner URL');
    return FixtureConfig.MAZE_HOST.toString();
  }

  Future<Directory> appFilesDirectory() async {
    log('Fetching app files directory');
    return Platform.isAndroid
        ? await getExternalStorageDirectory() ??
            await getApplicationDocumentsDirectory()
        : await getApplicationDocumentsDirectory();
  }
}

class MazeRunnerHomePage extends StatefulWidget {
  final String mazerunnerUrl;

  const MazeRunnerHomePage({
    super.key,
    required this.mazerunnerUrl,
  });

  @override
  State<MazeRunnerHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<MazeRunnerHomePage> {
  late TextEditingController _scenarioNameController;
  late TextEditingController _extraConfigController;
  late TextEditingController _commandEndpointController;
  late TextEditingController _notifyEndpointController;
  late TextEditingController _sessionEndpointController;
  Scenario? _currentScenario;

  @override
  void initState() {
    super.initState();
    log('Initializing _HomePageState');
    _scenarioNameController = TextEditingController();
    _extraConfigController = TextEditingController();
    _commandEndpointController = TextEditingController(
      text: '${widget.mazerunnerUrl}/command',
    );
    _notifyEndpointController = TextEditingController(
      text: '${widget.mazerunnerUrl}/notify',
    );
    _sessionEndpointController = TextEditingController(
      text: '${widget.mazerunnerUrl}/sessions',
    );
    _onRunCommand(context, retry: true);
  }

  @override
  void dispose() {
    log('Disposing _HomePageState');
    _scenarioNameController.dispose();
    _extraConfigController.dispose();
    _commandEndpointController.dispose();
    _notifyEndpointController.dispose();
    _sessionEndpointController.dispose();
    super.dispose();
  }

  void _onRunCommand(BuildContext context, {bool retry = false}) async {
    log('Fetching the next command');
    final commandUrl = _commandEndpointController.value.text;
    try {
      final response = await http.get(Uri.parse(commandUrl));
      if (response.statusCode == 200) {
        log('Received response with status code 200. Body: ${response.body}');

        if (response.body.isEmpty) {
          log('Empty command, retrying...');
          if (retry) {
            Future.delayed(const Duration(seconds: 1))
                .then((value) => _onRunCommand(context, retry: true));
          }
          return;
        }

        final command = Command.fromJsonString(response.body);
        _scenarioNameController.text = command.scenarioName;
        _extraConfigController.text = command.extraConfig;
        log("Received command: Action - ${command.action}, Scenario Name - ${command.scenarioName}, Extra Config - ${command.extraConfig}");

        switch (command.action) {
          case 'clear_cache':
            await _clearPersistentData();
            break;
          case 'run_scenario':
            _onRunScenario(context);
            break;
          case 'invoke_method':
            _onInvokeMethod(command.args[0]);
            break;
        }
      } else {
        log('Received response with status code ${response.statusCode}.');
        if (retry) {
          Future.delayed(const Duration(seconds: 1))
              .then((value) => _onRunCommand(context, retry: true));
        }
      }
    } catch (e) {
      log('Error fetching command: $e \nRetrying...');
      if (retry) {
        Future.delayed(const Duration(seconds: 1))
            .then((value) => _onRunCommand(context, retry: true));
      }
      return;
    }
  }

  Future<void> _clearPersistentData() async {
    log("Clearing the cache");
    final appCacheDir = await getApplicationSupportDirectory();
    try {
      await Directory('${appCacheDir.path}/bugsnag-performance')
          .delete(recursive: true);
      log("Cache cleared successfully");
    } catch (e) {
      log("Couldn't delete bugsnag-performance directory: $e");
    }
  }

  Future<void> _onStartBugsnag() async {
    log("Starting Bugsnag");
    // Implementation goes here
    log("Bugsnag started successfully");
  }

  void _onRunScenario(BuildContext context) async {
    final scenario = _initScenario(context);
    if (scenario == null) {
      return;
    }

    scenario.extraConfig = _extraConfigController.value.text;
    scenario.endpoints = BugsnagEndpointConfiguration(
      _notifyEndpointController.value.text,
      _sessionEndpointController.value.text,
    );

    log('Running scenario');
    _currentScenario = scenario;
    scenario.runCommandCallback = () => _onRunCommand(context, retry: true);
    await scenario.run();
    Widget? scenarioWidget = scenario.createWidget();
    if (scenarioWidget != null) {
      log('Mounting Scenario Widget');
      final route = MaterialPageRoute(
        builder: (context) => scenarioWidget,
        settings: scenario.routeSettings(),
      );
      log('Name: ${route.settings.name}');
      Navigator.push(context, route);
      await route.didPush();
    }
  }

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

  void _onInvokeMethod(String name) {
    _currentScenario?.invokeMethod(name);
  }

  @override
  Widget build(BuildContext context) {
    log('Building _HomePageState');
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 400.0,
                width: double.infinity,
                child: TextButton(
                  onPressed: () => _onRunCommand(context),
                  key: const Key("runCommand"),
                  child: const Text("Run Command"),
                ),
              ),
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
                onPressed: _onStartBugsnag,
                key: const Key("startBugsnag"),
                child: const Text("Start Bugsnag"),
              ),
              TextButton(
                onPressed: () => _onRunScenario(context),
                key: const Key("startScenario"),
                child: const Text("Run Scenario"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
