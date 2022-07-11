import 'dart:async';

import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/material.dart';

void main() async => bugsnag.attach(runApp: () => runApp(const MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bugsnag Flutter Example',
        initialRoute: '/',
        navigatorObservers: [BugsnagNavigatorObserver()],
        routes: {
          '/': (context) => const ExampleHomeScreen(),
          '/login': (context) => LoginScreen(),
        },
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
      bugsnag.leaveBreadcrumb('This is a custom breadcrumb from Flutter',
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
            ElevatedButton(
              onPressed: () async {
                final email = await Navigator.of(context).pushNamed('/login');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('User logged in as $email'),
                ));
              },
              child: const Text('Login (bugsnag.setUser)'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController _email = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              TextField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  bugsnag.setUser(email: _email.value.text);
                  bugsnag.leaveBreadcrumb('User has logged in');

                  Navigator.of(context).pop(_email.value.text);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
