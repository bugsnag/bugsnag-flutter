import 'dart:async';
import 'package:bugsnag_flutter_dart_io_http_client/bugsnag_flutter_dart_io_http_client.dart' as dart_io;
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;
import 'package:bugsnag_example/native_crashes.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';

void main() async {
  http.addSubscriber(bugsnag.networkInstrumentation);
  dart_io.addSubscriber(bugsnag.networkInstrumentation);
  await bugsnag.start(
    // Find your API key in the settings menu of your Bugsnag dashboard
    apiKey: 'add_your_api_key_here',
    // Specify in-project packages if you have multiple or are splitting debug info in your build (--split-debug-info)
    projectPackages: const BugsnagProjectPackages.only({'bugsnag_example'}),
    // onError callbacks can be used to modify or reject certain events
    onError: [
      (event) {
        if (event.unhandled) {
          // Metadata can be added on a per-event basis
          event.addMetadata('info', const {'hint': 'Example'});
        }
        // Return `true` to allow or `false` to prevent sending the event.
        return true;
      }
    ],
  );
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [BugsnagNavigatorObserver()],
      initialRoute: '/',
      routes: {
        '/': (context) => const ExampleHomeScreen(),
        '/native-crashes': (context) => const NativeCrashesScreen(),
      },
    );
  }
}

class ExampleHomeScreen extends StatelessWidget {
  const ExampleHomeScreen({Key? key}) : super(key: key);

  // Unhandled exceptions will automatically be detected and reported.
  // They are displayed with an 'Error' severity on the dashboard.
  void _unhandledFlutterError() async {
    throw Exception('Unhandled Exception');
  }

  // Exceptions thrown asynchronously are also automatically reported.
  void _asyncUnhandledFlutterError() async {
    await Future.delayed(const Duration(milliseconds: 1));
    throw Exception('Async Exception on Timer');
  }

  // Handled exceptions can be manually reported to Bugsnag using notify().
  // These will have a 'Warning' severity on the dashboard.
  void _handledException() async {
    try {
      throw Exception('handled exception');
    } catch (e, stack) {
      await bugsnag.notify(e, stack);
    }
  }

  // Use leaveBreadcrumb() to log potentially useful events in order to
  // understand what happened in your app before each error.
  void _leaveBreadcrumb() async =>
      bugsnag.leaveBreadcrumb('This is a custom breadcrumb',
          // Additional data can be attached to breadcrumbs as metadata
          metadata: {'from': 'a', 'to': 'z'});

  // Use the bugsnag_flutter_http package to automatically capture breadcrumbs
  // for network requests:
  //   import 'package:bugsnag_flutter_http/bugsnag_flutter_http.dart' as http;
  void _networkSuccess() async => http.get(Uri.parse('https://example.com'));

  void _networkFailure() async =>
      http.post(Uri.parse('https://example.com/invalid'));

  void _networkError() async =>
      http.get(Uri.parse('https://example.invalid')).ignore();

  void _networkDartIoHttpClient() async {
    var client = dart_io.HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('https://example.com'));
      await request.close();
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugsnag example app'),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Unhandled Errors',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ElevatedButton(
              onPressed: _unhandledFlutterError,
              child: const Text('Unhandled Error'),
            ),
            ElevatedButton(
              onPressed: _asyncUnhandledFlutterError,
              child: const Text('Async Unhandled Error'),
            ),
            ElevatedButton(
              onPressed: _handledException,
              child: const Text('Notify Handled Error'),
            ),
            ElevatedButton(
              child: const Text('Native Errors'),
              onPressed: () {
                Navigator.pushNamed(context, '/native-crashes');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Breadcrumbs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ElevatedButton(
              onPressed: _leaveBreadcrumb,
              child: const Text('Leave a breadcrumb'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Network Breadcrumbs',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ElevatedButton(
              onPressed: _networkSuccess,
              child: const Text('Http Success'),
            ),
            ElevatedButton(
              onPressed: _networkFailure,
              child: const Text('Http Failure'),
            ),
            ElevatedButton(
              onPressed: _networkError,
              child: const Text('Http Error'),
            ),
            ElevatedButton(
              onPressed: _networkDartIoHttpClient,
              child: const Text('Dart Io Success'),
            ),
          ],
        ),
      ),
    );
  }
}
