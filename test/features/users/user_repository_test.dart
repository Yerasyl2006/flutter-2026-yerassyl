import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/core/storage/secure_store.dart';
import 'package:users_api/features/users/user_repository.dart';

import '../../fixtures/user_one_json.dart';

void main() {
  test('numeric lat in the users list becomes BadResponseException', () async {
    final invalidJson = userOneJson.replaceFirst('"-37.3159"', '-37.3159');
    final repo = _repository((_) async => http.Response('[$invalidJson]', 200));
    await expectLater(
      repo.getAll(),
      throwsA(
        isA<BadResponseException>().having(
          (error) => error.detail,
          'detail',
          '/users[0]: lat is not a String',
        ),
      ),
    );
  });

  group('HTTP repository error mapping', () {
    test('404 becomes NotFoundException', () async {
      final repo = _repository(
        (_) async => http.Response('{"error":"gone"}', 404),
      );
      await expectLater(repo.getById(99), throwsA(isA<NotFoundException>()));
    });

    test('500 becomes ServerException', () async {
      final repo = _repository((_) async => http.Response('', 500));
      await expectLater(repo.getById(99), throwsA(isA<ServerException>()));
    });

    test('SocketException becomes NoConnectionException', () async {
      final repo = _repository(
        (_) async => throw const SocketException('down'),
      );
      await expectLater(
        repo.getById(99),
        throwsA(isA<NoConnectionException>()),
      );
    });
  });
}

UserRepository _repository(
  Future<http.Response> Function(http.Request) handle,
) {
  final api = ApiClient(MockClient(handle), const _TestStore());
  addTearDown(api.close);
  return HttpUserRepository(api);
}

class _TestStore extends SecureStore {
  const _TestStore();

  @override
  Future<String?> readToken() async => null;
}
