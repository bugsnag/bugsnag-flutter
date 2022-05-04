import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'scenario.dart';

class NavigatorBreadcrumbScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();

    final observer = BugsnagNavigatorObserver(setContext: true);
    observer.didPush(
      MaterialPageRoute(
        builder: _testBuilder,
        settings: const RouteSettings(
          name: '/test-route',
          arguments: {'search': 'bugsnag'},
        ),
      ),
      null,
    );

    observer.didReplace(
      oldRoute: MaterialPageRoute(
        builder: _testBuilder,
        settings: const RouteSettings(name: '/test-route'),
      ),
      newRoute: CupertinoPageRoute(
        builder: _testBuilder,
        title: 'Cupertino Route',
      ),
    );

    try {
      throw Exception('test exception');
    } catch (error, stackTrace) {
      await bugsnag.notify(error, stackTrace);
    }
  }

  static Widget _testBuilder(BuildContext context) {
    return const Text('test');
  }
}
