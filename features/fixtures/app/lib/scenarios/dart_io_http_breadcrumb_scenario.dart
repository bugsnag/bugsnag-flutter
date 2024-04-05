import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:bugsnag_flutter_dart_io_http_client/bugsnag_flutter_dart_io_http_client.dart' as dart_io;


class DartIoHttpBreadcrumbScenario extends Scenario {
  @override
  Future<void> run() async {
    dart_io.addSubscriber(bugsnag.networkInstrumentation);
    await bugsnag.start(
      enabledBreadcrumbTypes: {BugsnagEnabledBreadcrumbType.state},
      endpoints: endpoints,
    );

    var client = dart_io.HttpClient();
    try {
      final request = await client.getUrl(Uri.parse('https://example.com' + '?test=test'));
      await request.close();
    } finally {
      client.close();
    }
    await bugsnag.notify(Exception('DartIoHttpBreadcrumbScenario'), null);
  }
}
