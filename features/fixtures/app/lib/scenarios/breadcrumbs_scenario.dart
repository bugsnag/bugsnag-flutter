import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag.dart';

class BreadcrumbsScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      enabledBreadcrumbTypes: {EnabledBreadcrumbType.state},
      endpoints: endpoints,
    );

    await bugsnag.leaveBreadcrumb('Manual breadcrumb', metadata: {
      'foo': 'bar',
      'object': {'test': 'hello'}
    });

    final breadcrumbs = await bugsnag.getBreadcrumbs();
    expect(breadcrumbs[0].message, 'Bugsnag loaded');
    expect(breadcrumbs[0].type, BreadcrumbType.state);
    expect(breadcrumbs[1].message, 'Manual breadcrumb');
    expect(breadcrumbs[1].type, BreadcrumbType.manual);

    await bugsnag.notify(Exception('BreadcrumbsScenarioException'));
  }
}
