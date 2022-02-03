import 'scenario.dart';

import 'throw_exception_scenario.dart';
import 'native_crash_scenario.dart';
import 'ffi_crash_scenario.dart';

class ScenarioInfo<T extends Scenario> {
  const ScenarioInfo(this.name, this.init);

  final String name;
  final Scenario Function() init;
}

// Flutter obfuscation *requires* that we specify the name as a raw String in order to match the runtime class
const List<ScenarioInfo<Scenario>> scenarios = [
  ScenarioInfo("ThrowExceptionScenario", ThrowExceptionScenario.new),
  ScenarioInfo("NativeCrashScenario", NativeCrashScenario.new),
  ScenarioInfo("FFICrashScenario", FFICrashScenario.new),
];
