class EnabledErrorTypes {
  final bool unhandledExceptions;
  final bool crashes;
  final bool ooms;
  final bool thermalKills;
  final bool appHangs;
  final bool anrs;

  const EnabledErrorTypes(this.unhandledExceptions, this.crashes, this.ooms,
      this.thermalKills, this.appHangs, this.anrs);

  dynamic toJson() => {
        'unhandledExceptions': unhandledExceptions,
        'crashes': crashes,
        'ooms': ooms,
        'thermalKills': thermalKills,
        'appHangs': appHangs,
        'anrs': anrs
      };

  static const EnabledErrorTypes all =
      EnabledErrorTypes(true, true, true, true, true, true);
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
