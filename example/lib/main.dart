import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:bugsnag_flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bad_widget.dart';

void main() async => bugsnag.start(
      // Find your API key in the settings menu of your Bugsnag dashboard
      apiKey: 'add-your-api-key-here',
      runApp: () => runApp(const ExampleApp()),
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

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  static const _methodChannel = MethodChannel('com.bugsnag.example/channel');

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

  // Crashes in native code will be reported when Bugsnag is next started.
  void _nativeCrash() {
    final dynamicLibrary = Platform.isAndroid
        ? DynamicLibrary.open('libc.so')
        : DynamicLibrary.process();
    // Intentionally incorrect function definition + call that causes a crash
    final int Function(int arg) strlen = dynamicLibrary
        .lookup<NativeFunction<Int32 Function(Int32)>>('strlen')
        .asFunction();
    strlen(0);
  }

  Future<void> _anr() => _methodChannel.invokeMethod('anr');

  Future<void> _fatalAppHang() => _methodChannel.invokeMethod('fatalAppHang');

  Future<void> _oom() => _methodChannel.invokeMethod('oom');

  // Use leaveBreadcrumb() to log potentially useful events in order to
  // understand what happened in your app before each error.
  void _leaveBreadcrumb() async =>
      bugsnag.leaveBreadcrumb('This is a custom breadcrumb',
          // Additional data can be attached to breadcrumbs as metadata
          metadata: {'from': 'a', 'to': 'z'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bugsnag example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
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
              ErrorBoundary(
                child: const BadWidget(),
                fallback: (context) => const Text(
                  'A build() error has occurred and been reported',
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Native Errors',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              ElevatedButton(
                onPressed: _nativeCrash,
                child: const Text('Native crash'),
              ),
              if (Platform.isAndroid)
                ElevatedButton(
                  onPressed: _anr,
                  child: const Text('Application Not Responding (ANR)'),
                ),
              if (Platform.isIOS)
                ElevatedButton(
                  onPressed: _fatalAppHang,
                  child: const Text('Fatal App Hang'),
                ),
              if (Platform.isIOS)
                ElevatedButton(
                  onPressed: _oom,
                  child: const Text('Out Of Memory'),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
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
      ),
    );
  }
}
