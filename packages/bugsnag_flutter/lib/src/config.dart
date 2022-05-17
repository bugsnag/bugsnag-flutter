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
