library bugsnag_flutter_http;

import 'src/client.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

export 'src/client.dart';

Future<http.Response> head(Uri url, {Map<String, String>? headers}) =>
    _withClient((client) => client.head(url, headers: headers));

Future<http.Response> get(Uri url, {Map<String, String>? headers}) =>
    _withClient((client) => client.get(url, headers: headers));

Future<http.Response> post(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
    _withClient((client) =>
        client.post(url, headers: headers, body: body, encoding: encoding));

Future<http.Response> put(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
    _withClient((client) =>
        client.put(url, headers: headers, body: body, encoding: encoding));

Future<http.Response> patch(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
    _withClient((client) =>
        client.patch(url, headers: headers, body: body, encoding: encoding));

Future<http.Response> delete(Uri url,
        {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
    _withClient((client) =>
        client.delete(url, headers: headers, body: body, encoding: encoding));

Future<String> read(Uri url, {Map<String, String>? headers}) =>
    _withClient((client) => client.read(url, headers: headers));

Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) =>
    _withClient((client) => client.readBytes(url, headers: headers));

Future<T> _withClient<T>(Future<T> Function(Client) fn) async {
  var client = Client();
  try {
    return await fn(client);
  } finally {
    client.close();
  }
}
