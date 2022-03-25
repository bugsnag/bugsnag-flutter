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
}

class EndpointConfiguration {
  final String notify;
  final String sessions;

  const EndpointConfiguration(this.notify, this.sessions);

  dynamic toJson() => {'notify': notify, 'sessions': sessions};
}

enum ThreadSendPolicy {
  always,
  unhandledOnly,
  never,
}
