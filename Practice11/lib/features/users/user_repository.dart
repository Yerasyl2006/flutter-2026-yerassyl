import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  factory UserRepository.live({String host = 'jsonplaceholder.typicode.com'}) =>
      UserRepository(ApiClient(http.Client(), host: host));

  final ApiClient _api;

  void close() => _api.close();

  Future<List<User>> getAll() async {
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
