import 'app_hang_scenario.dart';
import 'attach_bugsnag_scenario.dart';
import 'breadcrumbs_scenario.dart';
import 'detect_enabled_errors.dart';
import 'discard_classes_scenario.dart';
import 'error_handler_scenario.dart';
import 'feature_flags_scenario.dart';
import 'ffi_crash_scenario.dart';
import 'handled_exception_scenario.dart';
import 'last_run_info_scenario.dart';
import 'manual_sessions_scenario.dart';
import 'metadata_scenario.dart';
import 'native_crash_scenario.dart';
import 'native_project_packages_scenario.dart';
import 'navigation_breadcrumbs_scenario.dart';
import 'on_error_scenario.dart';
import 'project_packages_scenario.dart';
import 'release_stage_scenario.dart';
import 'scenario.dart';
import 'start_bugsnag_scenario.dart';
import 'throw_exception_scenario.dart';
import 'unhandled_exception_scenario.dart';
import 'http_breadcrumb_scenario.dart';
import 'dart_io_http_breadcrumb_scenario.dart';

class ScenarioInfo<T extends Scenario> {
  const ScenarioInfo(this.name, this.init);

  final String name;
  final Scenario Function() init;
}

// Flutter obfuscation *requires* that we specify the name as a raw String in order to match the runtime class
final List<ScenarioInfo<Scenario>> scenarios = [
  ScenarioInfo('AppHangScenario', () => AppHangScenario()),
  ScenarioInfo('AttachBugsnagScenario', () => AttachBugsnagScenario()),
  ScenarioInfo('BreadcrumbsScenario', () => BreadcrumbsScenario()),
  ScenarioInfo(
      'DetectEnabledErrorsScenario', () => DetectEnabledErrorsScenario()),
  ScenarioInfo('DiscardClassesScenario', () => DiscardClassesScenario()),
  ScenarioInfo('ErrorHandlerScenario', () => ErrorHandlerScenario()),
  ScenarioInfo('FeatureFlagsScenario', () => FeatureFlagsScenario()),
  ScenarioInfo('FFICrashScenario', () => FFICrashScenario()),
  ScenarioInfo('HandledExceptionScenario', () => HandledExceptionScenario()),
  ScenarioInfo('LastRunInfoScenario', () => LastRunInfoScenario()),
  ScenarioInfo('ManualSessionsScenario', () => ManualSessionsScenario()),
  ScenarioInfo('MetadataScenario', () => MetadataScenario()),
  ScenarioInfo('NativeCrashScenario', () => NativeCrashScenario()),
  ScenarioInfo(
      'NativeProjectPackagesScenario', () => NativeProjectPackagesScenario()),
  ScenarioInfo(
      'NavigatorBreadcrumbScenario', () => NavigatorBreadcrumbScenario()),
  ScenarioInfo('OnErrorScenario', () => OnErrorScenario()),
  ScenarioInfo('ProjectPackagesScenario', () => ProjectPackagesScenario()),
  ScenarioInfo('ReleaseStageScenario', () => ReleaseStageScenario()),
  ScenarioInfo('StartBugsnagScenario', () => StartBugsnagScenario()),
  ScenarioInfo('ThrowExceptionScenario', () => ThrowExceptionScenario()),
  ScenarioInfo(
      'UnhandledExceptionScenario', () => UnhandledExceptionScenario()),
  ScenarioInfo("HttpBreadcrumbScenario", () => HttpBreadcrumbScenario()),
  ScenarioInfo("DartIoHttpBreadcrumbScenario", () => DartIoHttpBreadcrumbScenario()),
];
