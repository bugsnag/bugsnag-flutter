import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:bugsnag_flutter_http/src/breadcrumb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Breadcrumb', () {
    test('Successful POST request', () {
      const body = '{"hello":"world"}';
      final breadcrumb = Breadcrumb.build(
          http.Client(),
          http.Request('POST', Uri.parse('https://example.com/'))..body = body,
          Stopwatch()..start(),
          DummyResponse(200, contentLength: 123));
      expect(breadcrumb.type, BugsnagBreadcrumbType.request);
      expect(breadcrumb.message, 'IOClient request succeeded');
      expect(breadcrumb.metadata?['duration'], isNotNull);
      expect(breadcrumb.metadata?['method'], 'POST');
      expect(breadcrumb.metadata?['requestContentLength'], body.length);
      expect(breadcrumb.metadata?['responseContentLength'], 123);
      expect(breadcrumb.metadata?['status'], 200);
      expect(breadcrumb.metadata?['url'], 'https://example.com/');
      expect(breadcrumb.metadata?['urlParams'], isNull);
    });

    test('Request with URL params', () {
      final breadcrumb = Breadcrumb.build(
          http.Client(),
          http.Request('GET', Uri.parse('https://example.com?type=all')),
          Stopwatch()..start(),
          DummyResponse(200, contentLength: 123));
      expect(breadcrumb.metadata?['url'], 'https://example.com');
      expect(breadcrumb.metadata?['urlParams'], {'type': 'all'});
    });

    test('Request failed', () {
      final breadcrumb = Breadcrumb.build(
          http.Client(),
          http.Request('GET', Uri.parse('https://example.com?type=all')),
          Stopwatch()..start(),
          DummyResponse(400, contentLength: 213));
      expect(breadcrumb.message, 'IOClient request failed');
      expect(breadcrumb.metadata?['duration'], isNotNull);
      expect(breadcrumb.metadata?['status'], 400);
      expect(breadcrumb.metadata?['responseContentLength'], 213);
    });

    test('Request error', () {
      final breadcrumb = Breadcrumb.build(
          http.Client(),
          http.Request('GET', Uri.parse('https://example.com')),
          Stopwatch()..start(),
          null);
      expect(breadcrumb.message, 'IOClient request error');
      expect(breadcrumb.metadata?['duration'], isNotNull);
      expect(breadcrumb.metadata?['status'], isNull);
      expect(breadcrumb.metadata?['responseContentLength'], isNull);
    });
  });
}

class DummyResponse extends http.BaseResponse {
  DummyResponse(int statusCode,
      {int? contentLength,
      http.BaseRequest? request,
      Map<String, String> headers = const {},
      bool isRedirect = false,
      bool persistentConnection = true,
      String? reasonPhrase})
      : super(statusCode,
            contentLength: contentLength,
            request: request,
            headers: headers,
            isRedirect: isRedirect,
            persistentConnection: persistentConnection,
            reasonPhrase: reasonPhrase);
}
