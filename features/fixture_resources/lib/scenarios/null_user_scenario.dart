import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'scenario.dart';

class NullUserScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(endpoints: endpoints);
    await bugsnag.setUser(id: null, email: null, name: null);
    await bugsnag.notify(Exception(), null);
  }
}
