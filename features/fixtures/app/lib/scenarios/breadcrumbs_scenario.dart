import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag.dart';

class BreadcrumbsScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      enabledBreadcrumbTypes: {BreadcrumbType.state},
      endpoints: endpoints,
    );

    await bugsnag.leaveBreadcrumb('Manual breadcrumb from Flutter', metadata: {
      'foo': 'bar',
      'object': {'test': 'hello'}
    });

    final breadcrumbs = await bugsnag.getBreadcrumbs();
    expect(breadcrumbs[0].message, 'Bugsnag loaded');
    expect(breadcrumbs[0].type, BreadcrumbType.state);
    expect(breadcrumbs[1].message, 'Manual breadcrumb from Flutter');
    expect(breadcrumbs[1].type, BreadcrumbType.manual);

    await bugsnag.notify(Exception('BreadcrumbsScenarioException'));
  }
}

void expect(dynamic actual, dynamic expected) {
  if (actual != expected) {
    throw AssertionError('Expected \'$expected\' but got \'$actual\'');
  }
}