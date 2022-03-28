import 'dart:async';

import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bugsnag.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  void _unhandledFlutterError() {
    throw Exception('Unhandled Exception');
  }

  void _asyncUnhandledFlutterError() async {
    await Future.delayed(const Duration(milliseconds: 1));
    throw Exception('Async Exception on Timer');
  }

  void _handledException() async {
    try {
      throw Exception('handled exception');
    } catch (e) {
      await bugsnag.notify(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                'Unhandled Errors',
                style: Theme.of(context).textTheme.headline6,
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
            ],
          ),
        ),
      ),
    );
  }
}
