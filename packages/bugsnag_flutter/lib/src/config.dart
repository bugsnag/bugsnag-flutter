class EnabledErrorTypes {
  final bool unhandledExceptions;
  final bool crashes;
  final bool ooms;
  final bool thermalKills;
  final bool appHangs;
  final bool anrs;

  const EnabledErrorTypes({
    this.unhandledExceptions = true,
    this.crashes = true,
    this.ooms = true,
    this.thermalKills = true,
    this.appHangs = true,
    this.anrs = true,
  });

  dynamic toJson() => {
        'unhandledExceptions': unhandledExceptions,
        'crashes': crashes,
        'ooms': ooms,
        'thermalKills': thermalKills,
        'appHangs': appHangs,
        'anrs': anrs
      };

  static const EnabledErrorTypes all = EnabledErrorTypes();
}

class EndpointConfiguration {
  final String notify;
  final String sessions;

  const EndpointConfiguration(this.notify, this.sessions);

  dynamic toJson() => {'notify': notify, 'sessions': sessions};

  static const EndpointConfiguration bugsnag = EndpointConfiguration(
      'https://notify.bugsnag.com', 'https://sessions.bugsnag.com');
}

enum ThreadSendPolicy {
  always,
  unhandledOnly,
  never,
}

enum EnabledBreadcrumbType {
  navigation,
  request,
  process,
  log,
  user,
  state,
  error,
}
