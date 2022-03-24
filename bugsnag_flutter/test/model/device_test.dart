import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Device', () {
    test('from Android', () {
      final json = {
        'cpuAbi': ['arm64-v8a', 'armeabi-v7a', 'armeabi'],
        'id': 'b97e2a6b-65d6-4e9d-a010-aa737eae3d33',
        'jailbroken': false,
        'locale': 'en_US',
        'manufacturer': 'Google',
        'model': 'Pixel 5',
        'osName': 'android',
        'osVersion': '12',
        'runtimeVersions': {
          'androidApiLevel': '31',
          'osBuild': 'SP1A.210812.015'
        },
        'totalMemory': 7823929344
      };

      final device = Device.fromJson(json);
      expect(device.cpuAbi, ['arm64-v8a', 'armeabi-v7a', 'armeabi']);
      expect(device.id, 'b97e2a6b-65d6-4e9d-a010-aa737eae3d33');
      expect(device.jailbroken, false);
      expect(device.locale, 'en_US');
      expect(device.manufacturer, 'Google');
      expect(device.model, 'Pixel 5');
      expect(device.modelNumber, null);
      expect(device.osName, 'android');
      expect(device.osVersion, '12');
      expect(device.runtimeVersions,
          {'androidApiLevel': '31', 'osBuild': 'SP1A.210812.015'});
      expect(device.totalMemory, 7823929344);

      expect(device.toJson(), json);
    });

    test('from Cocoa', () {
      final json = {
        'id': '48decb8cf9f410c4c20e6f597070ee60b131a5c4',
        'jailbroken': false,
        'locale': 'en_GB',
        'manufacturer': 'Apple',
        'model': 'iPhone10,1',
        'modelNumber': 'D20AP',
        'osName': 'iOS',
        'osVersion': '13.5.1',
        'runtimeVersions': {
          'osBuild': '17F80',
          'clangVersion': '13.0.0 (clang-1300.0.29.30)'
        },
        'totalMemory': 68714848256
      };

      final device = Device.fromJson(json);
      expect(device.cpuAbi, null);
      expect(device.id, '48decb8cf9f410c4c20e6f597070ee60b131a5c4');
      expect(device.jailbroken, false);
      expect(device.locale, 'en_GB');
      expect(device.manufacturer, 'Apple');
      expect(device.model, 'iPhone10,1');
      expect(device.modelNumber, 'D20AP');
      expect(device.osName, 'iOS');
      expect(device.osVersion, '13.5.1');
      expect(device.runtimeVersions,
          {'osBuild': '17F80', 'clangVersion': '13.0.0 (clang-1300.0.29.30)'});
      expect(device.totalMemory, 68714848256);

      expect(device.toJson(), json);
    });
  });

  group('DeviceWithState', () {
    test('from Android', () {
      final json = {
        'cpuAbi': ['arm64-v8a', 'armeabi-v7a', 'armeabi'],
        'freeDisk': 112632418304,
        'freeMemory': 3759054848,
        'id': 'b97e2a6b-65d6-4e9d-a010-aa737eae3d33',
        'jailbroken': false,
        'locale': 'en_US',
        'manufacturer': 'Google',
        'model': 'Pixel 5',
        'orientation': 'portrait',
        'osName': 'android',
        'osVersion': '12',
        'runtimeVersions': {
          'androidApiLevel': '31',
          'osBuild': 'SP1A.210812.015'
        },
        'time': '2022-03-03T02:15:50.405Z',
        'totalMemory': 7823929344,
      };

      final device = DeviceWithState.fromJson(json);
      expect(device.cpuAbi, ['arm64-v8a', 'armeabi-v7a', 'armeabi']);
      expect(device.freeDisk, 112632418304);
      expect(device.freeMemory, 3759054848);
      expect(device.id, 'b97e2a6b-65d6-4e9d-a010-aa737eae3d33');
      expect(device.jailbroken, false);
      expect(device.locale, 'en_US');
      expect(device.manufacturer, 'Google');
      expect(device.model, 'Pixel 5');
      expect(device.modelNumber, null);
      expect(device.orientation, 'portrait');
      expect(device.osName, 'android');
      expect(device.osVersion, '12');
      expect(device.runtimeVersions,
          {'androidApiLevel': '31', 'osBuild': 'SP1A.210812.015'});
      expect(device.time, DateTime.utc(2022, 3, 3, 2, 15, 50, 405));
      expect(device.totalMemory, 7823929344);

      expect(device.toJson(), json);
    });

    test('from Cocoa', () {
      final json = {
        'freeDisk': 225370066944,
        'freeMemory': 34524872704,
        'id': '48decb8cf9f410c4c20e6f597070ee60b131a5c4',
        'jailbroken': false,
        'locale': 'en_GB',
        'manufacturer': 'Apple',
        'model': 'iPhone10,1',
        'modelNumber': 'D20AP',
        'orientation': 'portrait',
        'osName': 'iOS',
        'osVersion': '13.5.1',
        'runtimeVersions': {
          'osBuild': '17F80',
          'clangVersion': '13.0.0 (clang-1300.0.29.30)'
        },
        'time': '2022-03-09T13:20:45.518Z',
        'totalMemory': 68717121536,
      };

      final device = DeviceWithState.fromJson(json);
      expect(device.cpuAbi, null);
      expect(device.freeDisk, 225370066944);
      expect(device.freeMemory, 34524872704);
      expect(device.id, '48decb8cf9f410c4c20e6f597070ee60b131a5c4');
      expect(device.jailbroken, false);
      expect(device.locale, 'en_GB');
      expect(device.manufacturer, 'Apple');
      expect(device.model, 'iPhone10,1');
      expect(device.modelNumber, 'D20AP');
      expect(device.orientation, 'portrait');
      expect(device.osName, 'iOS');
      expect(device.osVersion, '13.5.1');
      expect(device.runtimeVersions,
          {'osBuild': '17F80', 'clangVersion': '13.0.0 (clang-1300.0.29.30)'});
      expect(device.time, DateTime.utc(2022, 3, 9, 13, 20, 45, 518));
      expect(device.totalMemory, 68717121536);

      expect(device.toJson(), json);
    });
  });
}
