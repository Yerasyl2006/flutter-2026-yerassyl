import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<Object?> get(Uri uri) => _request('GET', uri, 200);

  Future<Object?> post(Uri uri, String json) =>
      _request('POST', uri, 201, body: json);

  void close() => _client.close();

  Future<Object?> _request(
    String method,
    Uri uri,
    int expectedStatus, {
    String? body,
  }) async {
    final abort = Completer<void>();
    final request = http.AbortableRequest(
      method,
      uri,
      abortTrigger: abort.future,
    )..headers.addAll(_headers);

    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.bodyBytes = utf8.encode(body);
    }

    final response = await _send(
      () async => http.Response.fromStream(await _client.send(request)),
      onTimeout: abort.complete,
    );
    if (kDebugMode) {
      log(
        '${response.request?.method ?? method} '
        '${response.request?.url.path ?? uri.path} → ${response.statusCode}',
        name: 'api',
      );
    }

    _check(response, expectedStatus);
    return _decode(response);
  }

  Future<http.Response> _send(
    Future<http.Response> Function() call, {
    required void Function() onTimeout,
  }) async {
    try {
      return await call().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      onTimeout();
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response, int expectedStatus) {
    final status = response.statusCode;
    if (status == 401 || status == 403) {
      throw const UnauthorizedException();
    }
    if (status == 404) {
      throw const NotFoundException();
    }
    if (status >= 500) {
      throw ServerException(status);
    }
    if (status != expectedStatus) {
      throw BadResponseException('Expected HTTP $expectedStatus, got $status');
    }
  }

  Object? _decode(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException catch (error) {
      throw BadResponseException('Invalid JSON: ${error.message}');
    }
  }
}
