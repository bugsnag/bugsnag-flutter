import 'package:MazeRunner/scenarios/scenario.dart';
import 'package:bugsnag_flutter/bugsnag.dart';

class BreadcrumbsScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      enabledBreadcrumbTypes: {BreadcrumbType.state},
      endpoints: endpoints,
    );

    bugsnag.addOnBreadcrumb(ignoreAllBreadcrumbs);
    bugsnag.removeOnBreadcrumb(ignoreAllBreadcrumbs);

    bugsnag.addOnBreadcrumb((breadcrumb) {
      if (breadcrumb.message.contains('ignore')) {
        return false;
      }
      breadcrumb.message += ' from Flutter';
      return true;
    });

    await bugsnag.leaveBreadcrumb('Manual breadcrumb', metadata: {
      'foo': 'bar',
      'object': {'test': 'hello'}
    });

    await bugsnag.leaveBreadcrumb('This breadcrumb should be ignored');

    final breadcrumbs = await bugsnag.getBreadcrumbs();
    expect(breadcrumbs[0].message, 'Bugsnag loaded');
    expect(breadcrumbs[0].type, BreadcrumbType.state);
    expect(breadcrumbs[1].message, 'Manual breadcrumb from Flutter');
    expect(breadcrumbs[1].type, BreadcrumbType.manual);

    await bugsnag.notify(Exception('BreadcrumbsScenarioException'));
  }

  bool ignoreAllBreadcrumbs(Breadcrumb _) => false;
}
