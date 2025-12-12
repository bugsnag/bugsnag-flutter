import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'scenario.dart';

class NullContextScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(endpoints: endpoints);
    await bugsnag.setContext(null);
    await bugsnag.notify(Exception(), null);
  }
}
