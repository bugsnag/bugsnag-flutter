abstract class Scenario {
  String? extraConfig;

  // this is a variable to allow it to be overwritten
  @Deprecated('to be replaced by the actual notifier API')
  // ignore: prefer_function_declarations_over_variables
  Future<void> Function() startBugsnag = () async {
    throw UnsupportedError('Scenario not properly initialised');
  };

  Future<void> run();
}
