import 'dart:convert';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';
import 'users_cache.dart';

typedef UsersResult = ({List<User> items, bool fromCache});

abstract interface class UserRepository {
  Future<UsersResult> getAll();
  Future<User> getById(int id);
  Future<User> create(User draft);
}

class HttpUserRepository implements UserRepository {
  HttpUserRepository(this._api, {UsersCache cache = const UsersCache()})
    : _cache = cache;

  final ApiClient _api;
  final UsersCache _cache;

  @override
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

  @override
  Future<User> getById(int id) async {
    final path = '/users/$id';
    return _user(await _api.get(Uri.https(_api.host, path)), path);
  }

  @override
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
      if (data case {
        'address': {'geo': final Map geo},
      } when geo['lat'] is! String) {
        throw BadResponseException('$path: lat is not a String');
      }
      throw BadResponseException('$path: $error');
    } on FormatException catch (error) {
      throw BadResponseException('$path: ${error.message}');
    }
  }
}
