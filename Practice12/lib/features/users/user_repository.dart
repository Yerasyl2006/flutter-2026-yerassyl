import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/storage/secure_store.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

class UserRepository {
  UserRepository(this._api, {UsersCache cache = const UsersCache()})
    : _cache = cache;

  factory UserRepository.live(SecureStore store) =>
      UserRepository(ApiClient(http.Client(), store));

  final ApiClient _api;
  final UsersCache _cache;

  void close() => _api.close();

  Future<UsersResult> getAll() async {
    try {
      final fresh = await _fetch();
      await _cache.save(fresh);
      return (items: fresh, fromCache: false);
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;
      return (items: saved, fromCache: true);
    }
  }

  Future<List<User>> _fetch() async {
    const path = '/users';
    final body = await _api.get(Uri.https(_api.host, path));
    if (body is! List) {
      throw const BadResponseException('/users: expected a JSON array');
    }
    return [
      for (var index = 0; index < body.length; index++)
        _user(body[index], '$path[$index]'),
    ];
  }

  Future<User> getById(int id) async {
    final path = '/users/$id';
    return _user(await _api.get(Uri.https(_api.host, path)), path);
  }

  Future<User> create(User draft) async {
    const path = '/users';
    final body = await _api.post(
      Uri.https(_api.host, path),
      jsonEncode(draft.toJson()),
    );
    return _user(body, 'POST $path');
  }

  User _user(Object? data, String path) {
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } on TypeError catch (error) {
      throw BadResponseException('$path: $error');
    } on FormatException catch (error) {
      throw BadResponseException('$path: ${error.message}');
    }
  }
}
