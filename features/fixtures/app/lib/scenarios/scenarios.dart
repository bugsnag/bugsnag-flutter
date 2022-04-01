import 'attach_bugsnag_scenario.dart';
import 'breadcrumbs_scenario.dart';
import 'error_boundary_scenario.dart';
import 'error_handler_scenario.dart';
import 'feature_flags_scenario.dart';
import 'ffi_crash_scenario.dart';
import 'handled_exception_scenario.dart';
import 'last_run_info_scenario.dart';
import 'manual_sessions_scenario.dart';
import 'native_crash_scenario.dart';
import 'scenario.dart';
import 'start_bugsnag_scenario.dart';
import 'throw_exception_scenario.dart';

class ScenarioInfo<T extends Scenario> {
  const ScenarioInfo(this.name, this.init);

  final String name;
  final Scenario Function() init;
}

// Flutter obfuscation *requires* that we specify the name as a raw String in order to match the runtime class
const List<ScenarioInfo<Scenario>> scenarios = [
  ScenarioInfo('AttachBugsnagScenario', AttachBugsnagScenario.new),
  ScenarioInfo('BreadcrumbsScenario', BreadcrumbsScenario.new),
  ScenarioInfo('ErrorHandlerScenario', ErrorHandlerScenario.new),
  ScenarioInfo('FeatureFlagsScenario', FeatureFlagsScenario.new),
  ScenarioInfo('FFICrashScenario', FFICrashScenario.new),
  ScenarioInfo('HandledExceptionScenario', HandledExceptionScenario.new),
  ScenarioInfo('LastRunInfoScenario', LastRunInfoScenario.new),
  ScenarioInfo('ManualSessionsScenario', ManualSessionsScenario.new),
  ScenarioInfo('NativeCrashScenario', NativeCrashScenario.new),
  ScenarioInfo('StartBugsnagScenario', StartBugsnagScenario.new),
  ScenarioInfo('ThrowExceptionScenario', ThrowExceptionScenario.new),
  ScenarioInfo('ErrorBoundaryWidgetScenario', ErrorBoundaryWidgetScenario.new),
];
