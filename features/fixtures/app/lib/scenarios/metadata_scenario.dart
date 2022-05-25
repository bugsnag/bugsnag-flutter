import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:flutter/foundation.dart';

import 'scenario.dart';

class MetadataScenario extends Scenario {
  @override
  Future<void> run() async {
    final hasCallback = extraConfig?.contains('callback') == true;

    await startBugsnag();

    await bugsnag.addMetadata('custom', const {'key': 'value'});
    await Future.wait([
      bugsnag.addMetadata('custom', const {
        'numbers': 123,
        'bool': true,
        'string': 'message',
        'password': 'oops',
      }),
      bugsnag.addMetadata('custom', const {
        'to-be-removed': 'bad value here',
      }),
      bugsnag.addMetadata('old-section', const {
        'to-be-removed': 'bad value here',
      }),
    ]);

    await bugsnag.clearMetadata('custom', 'to-be-removed');
    await bugsnag.clearMetadata('old-section');

    final metadata = await bugsnag.getMetadata('custom');
    if (!mapEquals(metadata, expectedMetadata)) {
      throw AssertionError('expected $expectedMetadata but was $metadata');
    }

    try {
      throw Exception('metadata failure');
    } catch (err, stack) {
      await bugsnag.notify(
        err,
        stack,
        callback: hasCallback
            ? (event) {
                event.addMetadata('callback', const {'callbackRun': true});
                event.clearMetadata('custom', 'password');
                return true;
              }
            : null,
      );
    }
  }
}

const expectedMetadata = {
  'key': 'value',
  'numbers': 123,
  'bool': true,
  'string': 'message',
  'password': 'oops',
};
