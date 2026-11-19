import 'dart:convert';

import '../../core/env.dart';
import '../../core/storage/local_data.dart';
import 'user.dart';

class UsersCache {
  const UsersCache({this.host = Env.defaultHost});

  final String host;

  String? get _scope =>
      host == Env.defaultHost ? null : Uri.encodeComponent(host);

  Future<void> save(List<User> users) => writeUsersJson(
    jsonEncode([for (final user in users) user.toJson()]),
    scope: _scope,
  );

  Future<List<User>?> load() async {
    final json = await readUsersJson(scope: _scope);
    if (json == null) return null;
    final data = jsonDecode(json) as List<dynamic>;
    return [
      for (final item in data) User.fromJson(item as Map<String, dynamic>),
    ];
  }
}
