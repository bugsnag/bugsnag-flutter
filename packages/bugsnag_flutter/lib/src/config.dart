import 'package:flutter/foundation.dart';

class EnabledErrorTypes {
  final bool unhandledJvmExceptions;
  final bool unhandledDartExceptions;
  final bool crashes;
  final bool ooms;
  final bool thermalKills;
  final bool appHangs;
  final bool anrs;

  const EnabledErrorTypes({
    this.unhandledJvmExceptions = true,
    this.unhandledDartExceptions = true,
    this.crashes = true,
    this.ooms = true,
    this.thermalKills = true,
    this.appHangs = true,
    this.anrs = true,
  });

  dynamic toJson() => {
        'unhandledExceptions': unhandledJvmExceptions,
        'crashes': crashes,
        'ooms': ooms,
        'thermalKills': thermalKills,
        'appHangs': appHangs,
        'anrs': anrs
      };

  static const EnabledErrorTypes all = EnabledErrorTypes();
}

/// Set the endpoints to send data to. By default we'll send error reports to
/// `https://notify.bugsnag.com`, and sessions to `https://sessions.bugsnag.com`,
/// but you can override this if you are using Bugsnag Enterprise to point
/// to your own Bugsnag endpoints.
class EndpointConfiguration {
  /// Configures the endpoint to which events should be sent
  final String notify;

  /// Configures the endpoint to which sessions should be sent
  final String sessions;

  const EndpointConfiguration(this.notify, this.sessions);

  dynamic toJson() => {'notify': notify, 'sessions': sessions};

  /// Default Bugsnag `EndpointConfiguration`
  static const EndpointConfiguration bugsnag = EndpointConfiguration(
      'https://notify.bugsnag.com', 'https://sessions.bugsnag.com');
}

/// In order to determine where a crash happens Bugsnag needs to know which
/// packages you consider to be part of your app (as opposed to a library).
///
/// [By default](ProjectPackages.detected) this is set according to the
/// underlying platform (iOS or Android) and an attempt is made to discover
/// the Dart package your application uses. This detection *will not work* if
/// you build using `--split-debug-info`.
///
/// See also:
/// - [Bugsnag.start]
/// - [ProjectPackages.detected]
class ProjectPackages {
  final bool _includeDefaults;
  final Set<String> _packageNames;

  const ProjectPackages._internal(this._packageNames, this._includeDefaults);

  /// Specify the exact list of packages to consider as part of the project.
  /// This should include packages from both Dart and any Java packages
  /// your application uses on Android.
  ///
  /// See also:
  /// - [withPlatformDefaults]
  const ProjectPackages.only(Set<String> packageNames)
      : this._internal(packageNames, false);

  /// Combine the given set of `packageNames` with whatever package names are
  /// appropriate on the current platform. This is useful when you are using
  /// `--split-debug-info` and only want to specify your Dart packages in
  /// [Bugsnag.start].
  ///
  /// See also:
  /// - [detected]
  /// - [Android Configuration.projectPackages](https://docs.bugsnag.com/platforms/android/configuration-options/#projectpackages)
  ProjectPackages.withPlatformDefaults(Set<String> packageNames)
      : this._internal(packageNames, true);

  /// Attempt to automatically detect all of the packages used by this
  /// application. This detection *will not work* if
  /// you build using `--split-debug-info`.
  ///
  /// When using `--split-debug-info` you should use [withPlatformDefaults] or
  /// [only] to specify your `projectPackages` manually.
  ProjectPackages.detected() : this._internal(_findProjectPackages(), true);

  dynamic toJson() => <String, dynamic>{
        'includeDefaults': _includeDefaults,
        'packageNames': List.from(_packageNames),
      };

  static Set<String> _findProjectPackages() {
    try {
      final frames = StackFrame.fromStackTrace(StackTrace.current);
      final lastBugsnag = frames.lastIndexWhere((f) =>
          f.packageScheme == 'package' && f.package == 'bugsnag_flutter');

      if (lastBugsnag != -1 && lastBugsnag < frames.length) {
        final package = frames[lastBugsnag + 1].package;
        if (package.isNotEmpty && package != 'null') {
          return {package};
        }
      }
    } catch (e) {
      // deliberately ignored, we return null
    }

    return const <String>{};
  }
}

/// Controls whether we should capture and serialize the state of all threads
/// at the time of an error.
///
/// This affects the thread capturing behaviour of the native layers of
/// iOS and Android.
enum ThreadSendPolicy {
  /// Threads should be captured for all events.
  always,

  /// Threads should be captured for unhandled events only.
  unhandledOnly,

  /// Threads should never be captured.
  never,
}

/// Types of [breadcrumbs](BugsnagBreadcrumb) that can be enabled or disabled by
/// setting `enabledBreadcrumbTypes` [Bugsnag.start]
enum EnabledBreadcrumbType {
  navigation,
  request,
  process,
  log,
  user,
  state,
  error,
}
