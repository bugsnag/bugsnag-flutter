import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'scenario.dart';

class GroupingDiscriminatorScenario extends Scenario {
  @override
  Future<void> run() async {
    await startBugsnag();
    await bugsnag.notify(Exception('GroupingDiscriminator-1'), StackTrace.current);
    bugsnag.setGroupingDiscriminator("Global GroupingDiscriminator");
    await bugsnag.notify(Exception('GroupingDiscriminator-2'), StackTrace.current);
    await bugsnag.notify(Exception('GroupingDiscriminator-3'), StackTrace.current,callback: (event) {
      event.groupingDiscriminator = "Callback GroupingDiscriminator";
      return true;
    });
  }
}