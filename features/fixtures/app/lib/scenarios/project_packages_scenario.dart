import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'scenario.dart';

class ProjectPackagesScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      endpoints: endpoints,
      projectPackages: const ProjectPackages.withDefaults({'test_package'}),
    );
    await bugsnag.notify(Exception(), null);
  }
}
