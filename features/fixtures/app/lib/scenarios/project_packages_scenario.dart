import 'package:bugsnag_flutter/bugsnag.dart';

import 'scenario.dart';

class ProjectPackagesScenario extends Scenario {
  @override
  Future<void> run() async {
    await bugsnag.start(
      endpoints: endpoints,
      projectPackages: ProjectPackages.withPlatformDefaults(const {'app'}),
    );
    await bugsnag.notify(Exception(), null);
  }
}
