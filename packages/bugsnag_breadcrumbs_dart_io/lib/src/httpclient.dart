// ignore_for_file: annotate_overrides

import 'dart:async';
import 'dart:io';

import 'package:bugsnag_flutter/bugsnag_flutter.dart';

import 'breadcrumb.dart';

/// An HttpClient wrapper that logs requests as Bugsnag breadcrumbs.
abstract class BugsnagHttpClient implements HttpClient {
  factory BugsnagHttpClient([HttpClient? inner]) => _BugsnagHttpClient(inner);
}

class _BugsnagHttpClient implements BugsnagHttpClient {
  /// The wrapped client.
  final HttpClient _inner;

  _BugsnagHttpClient([HttpClient? inner]) : _inner = inner ?? HttpClient();

  void addCredentials(
          Uri url, String realm, HttpClientCredentials credentials) =>
      _inner.addCredentials(url, realm, credentials);

  void addProxyCredentials(String host, int port, String realm,
          HttpClientCredentials credentials) =>
      _inner.addProxyCredentials(host, port, realm, credentials);

  void close({bool force = false}) => _inner.close(force: force);

  set authenticate(
          Future<bool> Function(Uri url, String scheme, String? realm)? f) =>
      _inner.authenticate = f;

  set authenticateProxy(
          Future<bool> Function(
                  String host, int port, String scheme, String? realm)?
              f) =>
      _inner.authenticateProxy = f;

  bool get autoUncompress => _inner.autoUncompress;

  set autoUncompress(bool value) => _inner.autoUncompress = value;

  set badCertificateCallback(
          bool Function(X509Certificate cert, String host, int port)?
              callback) =>
      _inner.badCertificateCallback = callback;

  set connectionFactory(
          Future<ConnectionTask<Socket>> Function(
                  Uri url, String? proxyHost, int? proxyPort)?
              f) =>
      (_inner as dynamic).connectionFactory = f;

  Duration? get connectionTimeout => _inner.connectionTimeout;

  set connectionTimeout(Duration? value) => _inner.connectionTimeout = value;

  set findProxy(String Function(Uri url)? f) => _inner.findProxy = f;

  set keyLog(Function(String line)? callback) =>
      (_inner as dynamic).keyLog = callback;

  Duration get idleTimeout => _inner.idleTimeout;

  set idleTimeout(Duration value) => _inner.idleTimeout = value;

  int? get maxConnectionsPerHost => _inner.maxConnectionsPerHost;

  set maxConnectionsPerHost(int? value) => _inner.maxConnectionsPerHost = value;

  String? get userAgent => _inner.userAgent;

  set userAgent(String? value) => _inner.userAgent = value;

  // HTTP connection functions.

  Future<HttpClientRequest> delete(String host, int port, String path) =>
      _instrument('DELETE', Uri(host: host, port: port, path: path),
          () => _inner.delete(host, port, path));

  Future<HttpClientRequest> deleteUrl(Uri url) =>
      _instrument('DELETE', url, () => _inner.deleteUrl(url));

  Future<HttpClientRequest> get(String host, int port, String path) =>
      _instrument('GET', Uri(host: host, port: port, path: path),
          () => _inner.get(host, port, path));

  Future<HttpClientRequest> getUrl(Uri url) =>
      _instrument('GET', url, () => _inner.getUrl(url));

  Future<HttpClientRequest> head(String host, int port, String path) =>
      _instrument('HEAD', Uri(host: host, port: port, path: path),
          () => _inner.head(host, port, path));

  Future<HttpClientRequest> headUrl(Uri url) =>
      _instrument('HEAD', url, () => _inner.headUrl(url));

  Future<HttpClientRequest> open(
          String method, String host, int port, String path) =>
      _instrument(method, Uri(host: host, port: port, path: path),
          () => _inner.open(method, host, port, path));

  Future<HttpClientRequest> openUrl(String method, Uri url) =>
      _instrument(method, url, () => _inner.openUrl(method, url));

  Future<HttpClientRequest> patch(String host, int port, String path) =>
      _instrument('PATCH', Uri(host: host, port: port, path: path),
          () => _inner.patch(host, port, path));

  Future<HttpClientRequest> patchUrl(Uri url) =>
      _instrument('PATCH', url, () => _inner.patchUrl(url));

  Future<HttpClientRequest> post(String host, int port, String path) =>
      _instrument('POST', Uri(host: host, port: port, path: path),
          () => _inner.post(host, port, path));

  Future<HttpClientRequest> postUrl(Uri url) =>
      _instrument('POST', url, () => _inner.postUrl(url));

  Future<HttpClientRequest> put(String host, int port, String path) =>
      _instrument('PUT', Uri(host: host, port: port, path: path),
          () => _inner.put(host, port, path));

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
  await bugsnag.leaveBreadcrumb(
    breadcrumb.message,
    metadata: breadcrumb.metadata,
    type: breadcrumb.type,
  );
}
