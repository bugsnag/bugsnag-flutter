import 'package:bugsnag_flutter/src/client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_channel.dart';

void main() {
  final channel = MockChannelClientController();

  group('ChannelClient.isStarted', () {
    setUp(() {
      channel.reset();
    });

    test('ChannelClient has isStarted property that returns bool', () {
      final client = ChannelClient(true);
      
      // isStarted should be accessible and return a bool
      final isStarted = client.isStarted;
      expect(isStarted, isA<bool>());
      
      // Initially should be false
      expect(isStarted, isFalse);
    });

    test('ChannelClient.isStarted is false on new instances', () {
      final client1 = ChannelClient(true);
      final client2 = ChannelClient(false);
      
      expect(client1.isStarted, isFalse);
      expect(client2.isStarted, isFalse);
    });
  });
}



