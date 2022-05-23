import 'package:bugsnag_flutter/bugsnag.dart';
import 'package:http/http.dart' as http;

class Breadcrumb {
  static BugsnagBreadcrumb build(
    dynamic client,
    http.BaseRequest request,
    Stopwatch stopwatch,
    http.BaseResponse? response,
  ) {
    final clientName = client.runtimeType.toString();
    final requestContentLength = request.contentLength;
    final responseContentLength = response?.contentLength;
    final status = (response == null)
        ? 'error'
        : response.statusCode < 400
            ? 'succeeded'
            : 'failed';
    return BugsnagBreadcrumb('$clientName request $status',
        metadata: {
          'duration': stopwatch.elapsed.inMilliseconds,
          'method': request.method,
          'url': request.url.toString().split('?').first,
          if (request.url.queryParameters.isNotEmpty)
            'urlParams': request.url.queryParameters,
          if (requestContentLength != null && requestContentLength != 0)
            'requestContentLength': requestContentLength,
          if (response != null) 'status': response.statusCode,
          if (responseContentLength != null)
            'responseContentLength': responseContentLength,
        },
        type: BreadcrumbType.request);
  }
}
