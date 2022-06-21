import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeCrashesScreen extends StatelessWidget {
  static const _methodChannel = MethodChannel('com.bugsnag.example/channel');

  const NativeCrashesScreen({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugsnag: Native Crashes'),
      ),
      body: Center(
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}
