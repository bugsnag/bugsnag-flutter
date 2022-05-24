import 'dart:async';
import 'dart:io';

import 'package:bugsnag_flutter/bugsnag.dart';

import 'src/breadcrumb.dart';

/// An HttpClient wrapper that logs requests as Bugsnag breadcrumbs.
class BugsnagHttpClient implements HttpClient {
  /// The wrapped client.
  final HttpClient _inner;

  BugsnagHttpClient([HttpClient? inner]) : _inner = inner ?? HttpClient();

  @override
  void addCredentials(
          Uri url, String realm, HttpClientCredentials credentials) =>
      _inner.addCredentials(url, realm, credentials);

  @override
  void addProxyCredentials(String host, int port, String realm,
          HttpClientCredentials credentials) =>
      _inner.addProxyCredentials(host, port, realm, credentials);

  @override
  void close({bool force = false}) => _inner.close(force: force);

  @override
  set authenticate(
          Future<bool> Function(Uri url, String scheme, String? realm)? f) =>
      _inner.authenticate = f;

  @override
  set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String? realm)?
              f) =>
      _inner.authenticateProxy = f;

  @override
  bool get autoUncompress => _inner.autoUncompress;

  @override
  set autoUncompress(bool value) => _inner.autoUncompress = value;

  @override
  set badCertificateCallback(
          bool Function(X509Certificate cert, String host, int port)?
              callback) =>
      _inner.badCertificateCallback = callback;

  @override
  set connectionFactory(
          Future<ConnectionTask<Socket>> Function(
                  Uri url, String? proxyHost, int? proxyPort)?
              f) =>
      _inner.connectionFactory = f;

  @override
  Duration? get connectionTimeout => _inner.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) => _inner.connectionTimeout = value;

  @override
  set findProxy(String Function(Uri url)? f) => _inner.findProxy = f;

  @override
  set keyLog(Function(String line)? callback) => _inner.keyLog = callback;

  @override
  Duration get idleTimeout => _inner.idleTimeout;

  @override
  set idleTimeout(Duration value) => _inner.idleTimeout = value;

  @override
  int? get maxConnectionsPerHost => _inner.maxConnectionsPerHost;

  @override
  set maxConnectionsPerHost(int? value) => _inner.maxConnectionsPerHost = value;

  @override
  String? get userAgent => _inner.userAgent;

  @override
  set userAgent(String? value) => _inner.userAgent = value;

  // HTTP connection functions.

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _instrument('DELETE', Uri(host: host, port: port, path: path),
          () => _inner.delete(host, port, path));

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) =>
      _instrument('DELETE', url, () => _inner.deleteUrl(url));

  @override
  Future<HttpClientRequest> get(String host, int port, String path) =>
      _instrument('GET', Uri(host: host, port: port, path: path),
          () => _inner.get(host, port, path));

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      _instrument('GET', url, () => _inner.getUrl(url));

  @override
  Future<HttpClientRequest> head(String host, int port, String path) =>
      _instrument('HEAD', Uri(host: host, port: port, path: path),
          () => _inner.head(host, port, path));

  @override
  Future<HttpClientRequest> headUrl(Uri url) =>
      _instrument('HEAD', url, () => _inner.headUrl(url));

  @override
  Future<HttpClientRequest> open(
          String method, String host, int port, String path) =>
      _instrument(method, Uri(host: host, port: port, path: path),
          () => _inner.open(method, host, port, path));

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _instrument(method, url, () => _inner.openUrl(method, url));

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _instrument('PATCH', Uri(host: host, port: port, path: path),
          () => _inner.patch(host, port, path));

  @override
  Future<HttpClientRequest> patchUrl(Uri url) =>
      _instrument('PATCH', url, () => _inner.patchUrl(url));

  @override
  Future<HttpClientRequest> post(String host, int port, String path) =>
      _instrument('POST', Uri(host: host, port: port, path: path),
          () => _inner.post(host, port, path));

  @override
  Future<HttpClientRequest> postUrl(Uri url) =>
      _instrument('POST', url, () => _inner.postUrl(url));

  @override
  Future<HttpClientRequest> put(String host, int port, String path) =>
      _instrument('PUT', Uri(host: host, port: port, path: path),
          () => _inner.put(host, port, path));

  @override
  Future<HttpClientRequest> putUrl(Uri url) =>
      _instrument('PUT', url, () => _inner.putUrl(url));
}

Future<HttpClientRequest> _instrument(
  String method,
  Uri uri,
  Future<HttpClientRequest> Function() connect,
) async {
  final stopwatch = Stopwatch()..start();
  try {
    final request = await connect();
    runZoned(() async {
      _leaveBreadcrumb(Breadcrumb.build(
        request.method,
        request.uri,
        request.contentLength,
        stopwatch,
        await request.done,
      ));
    });
    return request;
  } catch (e) {
    _leaveBreadcrumb(Breadcrumb.build(method, uri, -1, stopwatch, null));
    rethrow;
  }
}

Future _leaveBreadcrumb(BugsnagBreadcrumb breadcrumb) async {
  print('${breadcrumb.message} ${breadcrumb.metadata}');
  await bugsnag.leaveBreadcrumb(
    breadcrumb.message,
    metadata: breadcrumb.metadata,
    type: breadcrumb.type,
  );
}
