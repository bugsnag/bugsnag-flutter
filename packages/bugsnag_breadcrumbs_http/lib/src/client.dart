import 'package:bugsnag_flutter/bugsnag_flutter.dart';
import 'package:http/http.dart' as http;

import 'breadcrumb.dart';

/// An HTTP client wrapper that logs requests as Bugsnag breadcrumbs.
class Client extends http.BaseClient {
  /// The wrapped client.
  final http.Client _inner;

  Client() : _inner = http.Client();

  Client.withClient(http.Client client) : _inner = client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _inner.send(request);
      await _requestFinished(request, stopwatch, response);
      return response;
    } catch (e) {
      await _requestFinished(request, stopwatch);
      rethrow;
    }
  }

  Future<void> _requestFinished(
    http.BaseRequest request,
    Stopwatch stopwatch, [
    http.StreamedResponse? response,
  ]) =>
      _leaveBreadcrumb(Breadcrumb.build(_inner, request, stopwatch, response));
}

Future _leaveBreadcrumb(BugsnagBreadcrumb breadcrumb) async =>
    bugsnag.leaveBreadcrumb(
      breadcrumb.message,
      metadata: breadcrumb.metadata,
      type: breadcrumb.type,
    );
