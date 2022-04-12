import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App', () {
    test('from Android', () {
      final json = {
        'binaryArch': 'arm64',
        'buildUUID': 'test-7.5.3',
        'id': 'com.bugsnag.android.mazerunner',
        'releaseStage': 'mazerunner',
        'type': 'android',
        'version': '1.1.14',
        'versionCode': 34
      };

      final app = App.fromJson(json);
      expect(app.binaryArch, 'arm64');
      expect(app.buildUUID, 'test-7.5.3');
      expect(app.id, 'com.bugsnag.android.mazerunner');
      expect(app.releaseStage, 'mazerunner');
      expect(app.type, 'android');
      expect(app.version, '1.1.14');
      expect(app.versionCode, 34);

      expect(app.toJson(), json);
    });

    test('from Cocoa', () {
      final json = {
        'binaryArch': 'x86_64',
        'bundleVersion': '12301',
        'dsymUUIDs': ['AC9210F7-55B6-3C88-8BA5-3004AA1A1D4E'],
        'id': 'com.bugsnag.macOSTestApp',
        'releaseStage': 'development',
        'type': 'macOS',
        'version': '12.3'
      };

      final app = App.fromJson(json);
      expect(app.binaryArch, 'x86_64');
      expect(app.bundleVersion, '12301');
      expect(app.dsymUuids, ['AC9210F7-55B6-3C88-8BA5-3004AA1A1D4E']);
      expect(app.id, 'com.bugsnag.macOSTestApp');
      expect(app.releaseStage, 'development');
      expect(app.type, 'macOS');
      expect(app.version, '12.3');

      expect(app.toJson(), json);
    });
  });

  group('AppWithState', () {
    test('from Android', () {
      final json = {
        'binaryArch': 'arm64',
        'buildUUID': 'test-7.5.3',
        'duration': 45,
        'durationInForeground': 0,
        'id': 'com.bugsnag.android.mazerunner',
        'inForeground': true,
        'isLaunching': true,
        'releaseStage': 'mazerunner',
        'type': 'android',
        'version': '1.1.14',
        'versionCode': 34,
      };

      final app = AppWithState.fromJson(json);
      expect(app.binaryArch, 'arm64');
      expect(app.buildUUID, 'test-7.5.3');
      expect(app.duration, 45);
      expect(app.durationInForeground, 0);
      expect(app.id, 'com.bugsnag.android.mazerunner');
      expect(app.inForeground, true);
      expect(app.isLaunching, true);
      expect(app.releaseStage, 'mazerunner');
      expect(app.type, 'android');
      expect(app.version, '1.1.14');
      expect(app.versionCode, 34);

      expect(app.toJson(), json);
    });

    test('from Cocoa', () {
      final json = {
        'binaryArch': 'x86_64',
        'bundleVersion': '12301',
        'dsymUUIDs': ['AC9210F7-55B6-3C88-8BA5-3004AA1A1D4E'],
        'duration': 5,
        'durationInForeground': 5,
        'id': 'com.bugsnag.macOSTestApp',
        'inForeground': true,
        'isLaunching': true,
        'releaseStage': 'development',
        'type': 'macOS',
        'version': '12.3'
      };

      final app = AppWithState.fromJson(json);
      expect(app.binaryArch, 'x86_64');
      expect(app.bundleVersion, '12301');
      expect(app.dsymUuids, ['AC9210F7-55B6-3C88-8BA5-3004AA1A1D4E']);
      expect(app.duration, 5);
      expect(app.durationInForeground, 5);
      expect(app.id, 'com.bugsnag.macOSTestApp');
      expect(app.inForeground, true);
      expect(app.isLaunching, true);
      expect(app.releaseStage, 'development');
      expect(app.type, 'macOS');
      expect(app.version, '12.3');

      expect(app.toJson(), json);
    });
  });
}
