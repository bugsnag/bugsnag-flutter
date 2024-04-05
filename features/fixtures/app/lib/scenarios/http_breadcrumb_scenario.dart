import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:bugsnag_http_client/bugsnag_http_client.dart' as http;

class HttpBreadcrumbScenario extends Scenario {
  @override
  Future<void> run() async {
    http.addSubscriber(bugsnag.networkInstrumentation);
    await bugsnag.start(
      enabledBreadcrumbTypes: {BugsnagEnabledBreadcrumbType.state},
      endpoints: endpoints,
    );
    await http.get(Uri.parse("http://www.google.com?test=test"));
    await bugsnag.notify(Exception('HttpBreadcrumbScenario'), null);
  }
}
