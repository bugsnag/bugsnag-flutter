import 'dart:convert';
import 'dart:io';

import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter_test/flutter_test.dart';

import '_expected_fixture_objects.dart';
import '_json_equals.dart';

void main() {
  group('Event', () {
    test('Android deserialization / serialization', () async {
      final expectedEvent = Event.fromJson(androidEventJson);

      final eventJsonFile =
          File('test/fixtures/android_event_serialization.json');
      final json = jsonDecode(await eventJsonFile.readAsString());

      final event = Event.fromJson(json);

      expect(event, jsonEquals(expectedEvent));
    });

    test('iOS deserialization / serialization', () async {
      final expectedEvent = Event.fromJson(iosEventJson);

      final eventJsonFile = File('test/fixtures/ios_event_serialization.json');
      final json = jsonDecode(await eventJsonFile.readAsString());

      final event = Event.fromJson(json);

      expect(event, jsonEquals(expectedEvent));
    });

    test('Event is mutable', () async {
      final event = Event.fromJson(iosEventJson);

      event.apiKey = 'replacement-api-key';
      event.unhandled = false;
      event.context = 'testing context';
      event.groupingHash = 'hash-for-breakfast';

      event.user.id = 'NULL';
      event.user.name = 'Bobby Tables';

      event.device.id = 'test-device-id';
      event.app.version = '0.0.0';

      event.featureFlags.addFeatureFlag('test-feature-flag');

      event.clearMetadata('app');
      event.clearMetadata('device');
      event.addMetadata('test-section', const {'test-metadata': 1234});

      // we both mutate each list, and replace it - both are valid changes

      event.threads.removeLast();
      event.threads = [event.threads.first];

      final error = event.errors.removeLast();
      error.message = 'my error message';
      error.stacktrace.removeRange(1, error.stacktrace.length);
      event.errors = [error];

      event.breadcrumbs.first.message = 'new message';
      event.breadcrumbs.removeLast();
      event.breadcrumbs = [event.breadcrumbs.first];

      final eventJson = event.toJson();
      expect(eventJson, jsonEquals(expectedModifiedEvent));
    });
  });
}

const expectedModifiedEvent = {
  'apiKey': 'replacement-api-key',
  'exceptions': [
    {
      'message': 'my error message',
      'errorClass': 'NSInvalidArgumentException',
      'stacktrace': [
        {
          'method': '__exceptionPreprocess',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'isPC': true,
          'symbolAddress': '0x7fff20420a04',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff20420ae6'
        },
      ],
      'type': 'cocoa'
    }
  ],
  'threads': [
    {
      'errorReportingThread': true,
      'id': '0',
      'stacktrace': [
        {
          'method': '__exceptionPreprocess',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'isPC': true,
          'symbolAddress': '0x7fff20420a04',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff20420ae6'
        },
        {
          'method': 'objc_exception_throw',
          'machoVMAddress': '0x7fff20172000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/libobjc.A.dylib',
          'symbolAddress': '0x7fff20177e48',
          'machoUUID': '0ED2E6A3-D7FC-3A31-A1CA-6BE106521240',
          'machoLoadAddress': '0x7fff20172000',
          'frameAddress': '0x7fff20177e78'
        },
        {
          'method': '-[NSObject(NSObject) doesNotRecognizeSelector:]',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'symbolAddress': '0x7fff2042f673',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff2042f6f7'
        },
        {
          'method': '-[UIResponder doesNotRecognizeSelector:]',
          'machoVMAddress': '0x7fff23a99000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore',
          'symbolAddress': '0x7fff246c5a33',
          'machoUUID': '984E55B9-03C9-3D2A-95DC-3A5F434A4A71',
          'machoLoadAddress': '0x7fff23a99000',
          'frameAddress': '0x7fff246c5b57'
        },
        {
          'method': '___forwarding___',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'symbolAddress': '0x7fff20424a65',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff20425036'
        },
        {
          'method': '_CF_forwarding_prep_0',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'symbolAddress': '0x7fff20426ff0',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff20427068'
        },
        {
          'method': '__NSThreadPerformPerform',
          'machoVMAddress': '0x7fff2071b000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/Foundation.framework/Foundation',
          'symbolAddress': '0x7fff208581ee',
          'machoUUID': '5716A8B8-2769-3484-9FD8-196630050F5B',
          'machoLoadAddress': '0x7fff2071b000',
          'frameAddress': '0x7fff208582ba'
        },
        {
          'method':
              '__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'symbolAddress': '0x7fff2038f379',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff2038f38a'
        },
        {
          'method': '__CFRunLoopDoSource0',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'symbolAddress': '0x7fff2038f1ce',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff2038f282'
        },
        {
          'method': '__CFRunLoopDoSources0',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'symbolAddress': '0x7fff2038e66c',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff2038e764'
        },
        {
          'method': '__CFRunLoopRun',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'symbolAddress': '0x7fff20388bc1',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff20388f2f'
        },
        {
          'method': 'CFRunLoopRunSpecific',
          'machoVMAddress': '0x7fff2030f000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
          'symbolAddress': '0x7fff2038849f',
          'machoUUID': '8FC68AD0-5128-3700-9E63-F6F358B6321B',
          'machoLoadAddress': '0x7fff2030f000',
          'frameAddress': '0x7fff203886d6'
        },
        {
          'method': 'GSEventRunModal',
          'machoVMAddress': '0x7fff2bedb000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices',
          'symbolAddress': '0x7fff2beded28',
          'machoUUID': 'EFA60C9C-ACAF-3326-BDC5-4B361494A126',
          'machoLoadAddress': '0x7fff2bedb000',
          'frameAddress': '0x7fff2bededb3'
        },
        {
          'method': '-[UIApplication _run]',
          'machoVMAddress': '0x7fff23a99000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore',
          'symbolAddress': '0x7fff24690a7b',
          'machoUUID': '984E55B9-03C9-3D2A-95DC-3A5F434A4A71',
          'machoLoadAddress': '0x7fff23a99000',
          'frameAddress': '0x7fff24690e0b'
        },
        {
          'method': 'UIApplicationMain',
          'machoVMAddress': '0x7fff23a99000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/System/Library/PrivateFrameworks/UIKitCore.framework/UIKitCore',
          'symbolAddress': '0x7fff24695c57',
          'machoUUID': '984E55B9-03C9-3D2A-95DC-3A5F434A4A71',
          'machoLoadAddress': '0x7fff23a99000',
          'frameAddress': '0x7fff24695cbc'
        },
        {
          'method': '_mh_execute_header',
          'machoVMAddress': '0x100000000',
          'machoFile':
              '/Users/nick/Library/Developer/CoreSimulator/Devices/5AFE2FCA-EB57-45D2-A705-42F81D4031F3/data/Containers/Bundle/Application/B7477EE0-B11B-41B3-9A7A-FFEE9E28AA47/Bugsnag Test App.app/Bugsnag Test App',
          'symbolAddress': '0x10d2d0000',
          'machoUUID': 'F18A2C56-008C-3CC1-8BFF-4E79683FB1AB',
          'machoLoadAddress': '0x10d2d0000',
          'frameAddress': '0x10d2d1c70'
        },
        {
          'method': 'start',
          'machoVMAddress': '0x7fff20258000',
          'machoFile':
              '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/system/libdyld.dylib',
          'symbolAddress': '0x7fff202593e8',
          'machoUUID': '78F65EE7-1659-3B52-9FE5-FDD6C61BDCAA',
          'machoLoadAddress': '0x7fff20258000',
          'frameAddress': '0x7fff202593e9'
        }
      ],
      'type': 'cocoa'
    }
  ],
  'breadcrumbs': [
    {
      'timestamp': '2021-01-19T11:16:01.262Z',
      'name': 'new message',
      'type': 'state',
      'metaData': {},
    }
  ],
  'context': 'testing context',
  'groupingHash': 'hash-for-breakfast',
  'unhandled': false,
  'severity': 'error',
  'severityReason': {'type': 'unhandledException', 'unhandledOverridden': true},
  'projectPackages': [],
  'user': {'id': 'NULL', 'name': 'Bobby Tables'},
  'session': {
    'id': '5C5C6908-726F-4CCE-A081-23BDA1157911',
    'startedAt': '2021-01-19T11:16:01.259Z',
    'events': {'handled': 0, 'unhandled': 1}
  },
  'device': {
    'id': 'test-device-id',
    'orientation': 'portrait',
    'osName': 'iOS',
    'jailbroken': false,
    'osVersion': '14.3',
    'time': '2021-01-19T11:16:25.000Z',
    'locale': 'en_US',
    'runtimeVersions': {
      'osBuild': '19H114',
      'clangVersion': '12.0.0 (clang-1200.0.32.28)'
    },
    'freeMemory': 27904143360,
    'manufacturer': 'Apple',
    'freeDisk': 551348178944,
    'modelNumber': 'simulator',
    'model': 'iPod9,1',
    'totalMemory': 68715134976
  },
  'app': {
    'bundleVersion': '4',
    'durationInForeground': 24000,
    'dsymUUIDs': ['F18A2C56-008C-3CC1-8BFF-4E79683FB1AB'],
    'id': 'bugsnag.Bugsnag-Test-App',
    'inForeground': true,
    'isLaunching': false,
    'duration': 24000,
    'version': '0.0.0',
    'type': 'iOS',
    'releaseStage': 'development'
  },
  'featureFlags': [
    {'featureFlag': 'test-feature-flag'}
  ],
  'metaData': {
    'error': {
      'nsexception': {'name': 'NSInvalidArgumentException'},
      'reason':
          '-[ViewController someRandomMethod]: unrecognized selector sent to instance 0x7fbd4e51cc60',
      'type': 'nsexception',
      'address': 0
    },
    'user': {'id': '5ed88ab6980274562bcd9106bd03e17810da3e79'},
    'test-section': {'test-metadata': 1234}
  }
};
