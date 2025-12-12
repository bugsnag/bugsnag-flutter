import 'dart:ffi'; // For FFI
import 'dart:io'; // For Platform.isX

import 'scenario.dart';

class FFICrashScenario extends Scenario {
  static final DynamicLibrary nativeCrashes = Platform.isAndroid
      ? DynamicLibrary.open('libffi_crashes.so')
      : DynamicLibrary.process();

  final void Function() nullDereference = nativeCrashes
      .lookup<NativeFunction<Void Function()>>('null_dereference')
      .asFunction();

  @override
  Future<void> run() async {
    await startBugsnag();
    nullDereference();
  }
}
