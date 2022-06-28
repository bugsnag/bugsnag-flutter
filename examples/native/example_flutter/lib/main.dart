import 'dart:async';

import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';

void main() async => bugsnag.attach(runApp: () => runApp(const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        title: 'Bugsnag Flutter Example',
        home: ExampleHomeScreen(),
      );
}

class ExampleHomeScreen extends StatelessWidget {
  const ExampleHomeScreen({Key? key}) : super(key: key);

  // Unhandled exceptions will automatically be detected and reported.
  // They are displayed with an 'Error' severity on the dashboard.
  void _unhandledFlutterError() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugsnag Flutter Module'),
      ),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Unhandled Errors',
                style: Theme.of(context).textTheme.headline6,
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
                primary: Colors.redAccent.shade200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Breadcrumbs',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            ElevatedButton(
              onPressed: _leaveBreadcrumb,
              child: const Text('Leave a breadcrumb'),
            ),
          ],
        ),
      ),
    );
  }
}
