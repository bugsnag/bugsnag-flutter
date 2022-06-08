import 'dart:io';

import 'package:bugsnag_flutter/bugsnag_flutter.dart';

class Breadcrumb {
  static BugsnagBreadcrumb build(
    String method,
    Uri url,
    int requestContentLength,
    Stopwatch stopwatch,
    HttpClientResponse? response,
  ) {
    final responseContentLength = response?.contentLength;
    final status = (response == null)
        ? 'error'
        : response.statusCode < 400
            ? 'succeeded'
            : 'failed';
    return BugsnagBreadcrumb(
      'HttpClient request $status',
      metadata: {
        'duration': stopwatch.elapsed.inMilliseconds,
        'method': method,
        'url': url.toString().split('?').first,
        if (url.queryParameters.isNotEmpty) 'urlParams': url.queryParameters,
        if (requestContentLength > 0)
          'requestContentLength': requestContentLength,
        if (response != null) 'status': response.statusCode,
        if (responseContentLength != null)
          'responseContentLength': responseContentLength,
      },
      type: BugsnagBreadcrumbType.request,
    );
  }
}
